#!/usr/bin/env python3
"""Serveur local pour l'interface graphique du Terminal Magique.

Sert les fichiers de web/ (index.html, style.css, app.js) et deux API :
  GET  /api/guide     -> liste des outils du guide (config/kali-guide.txt)
  GET  /api/reglages  -> état des réglages (modèle local, Claude configuré ?)
  POST /api/reglages  -> enregistre la clé API Claude et/ou le modèle
  POST /api/chat      -> {source: "local"|"claude", message: "..."} -> {reponse}

Ne dépend que de la bibliothèque standard Python (aucune installation requise).
Ne s'exécute que sur 127.0.0.1 : rien n'est exposé au reste du réseau.
"""
import http.server
import json
import os
import re
import ssl
import subprocess
import sys
import urllib.error
import urllib.request

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
HOME = os.path.expanduser("~")
DOSSIER = os.path.join(HOME, ".magie")
PREFIX = os.environ.get("PREFIX", "/data/data/com.termux/files/usr")

MODELE_ACTIF_FICHIER = os.path.join(DOSSIER, "modele_actif")
CLAUDE_CLE_FICHIER = os.path.join(DOSSIER, "claude-api-key")
CLAUDE_MODELE_FICHIER = os.path.join(DOSSIER, "claude-modele")
CLAUDE_MODELE_DEFAUT = "claude-sonnet-4-5"


def trouver_fichier(nom_relatif, candidats_extra=()):
    candidats = [
        os.path.join(PREFIX, "share", "magie", nom_relatif),
        os.path.join("/usr/local/share/magie", nom_relatif),
        os.path.join(DOSSIER, nom_relatif),
        os.path.join(SCRIPT_DIR, "..", nom_relatif),
    ]
    candidats.extend(candidats_extra)
    for c in candidats:
        if os.path.isfile(c):
            return c
    return None


def lire(chemin, defaut=""):
    try:
        with open(chemin, "r", encoding="utf-8") as f:
            return f.read().strip()
    except OSError:
        return defaut


def ecrire_prive(chemin, contenu):
    os.makedirs(os.path.dirname(chemin), exist_ok=True)
    with open(chemin, "w", encoding="utf-8") as f:
        f.write(contenu)
    os.chmod(chemin, 0o600)


def modele_local_actif():
    return lire(MODELE_ACTIF_FICHIER, "llama3.2:3b")


def parser_guide():
    chemin = trouver_fichier(os.path.join("config", "kali-guide.txt"))
    if not chemin:
        return []
    outils = []
    courant = None
    with open(chemin, "r", encoding="utf-8") as f:
        for ligne in f:
            ligne = ligne.rstrip("\n")
            if ligne.startswith("@"):
                parts = [p.strip() for p in ligne[1:].split("|")]
                nom = parts[0] if len(parts) > 0 else ""
                cat = parts[1] if len(parts) > 1 else ""
                res = parts[2] if len(parts) > 2 else ""
                courant = {"nom": nom, "categorie": cat, "resume": res, "exemples": []}
                outils.append(courant)
            elif courant is not None and ligne.startswith("$"):
                cmd = re.sub(r"^\$\s*", "", ligne)
                cmd = re.sub(r"\s{2,}#.*$", "", cmd)
                courant["exemples"].append(cmd.strip())
    return outils


def appeler_ollama(message):
    modele = modele_local_actif()
    try:
        r = subprocess.run(
            ["ollama", "run", modele, message],
            capture_output=True, text=True, timeout=120,
        )
    except FileNotFoundError:
        return None, "Ollama n'est pas installé. Dans le terminal : magie installer-ia"
    except subprocess.TimeoutExpired:
        return None, "L'IA locale a pris trop de temps à répondre. Réessayez."
    if r.returncode != 0:
        return None, "Erreur de l'IA locale : " + (r.stderr.strip()[:300] or "inconnue")
    return r.stdout.strip(), None


def appeler_claude(message):
    cle = lire(CLAUDE_CLE_FICHIER)
    if not cle:
        return None, "Aucune clé API Claude enregistrée. Onglet Réglages pour l'ajouter."
    modele = lire(CLAUDE_MODELE_FICHIER, CLAUDE_MODELE_DEFAUT) or CLAUDE_MODELE_DEFAUT
    corps = json.dumps({
        "model": modele,
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": message}],
    }).encode("utf-8")
    requete = urllib.request.Request(
        "https://api.anthropic.com/v1/messages",
        data=corps,
        headers={
            "content-type": "application/json",
            "x-api-key": cle,
            "anthropic-version": "2023-06-01",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(requete, timeout=60) as rep:
            data = json.loads(rep.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        try:
            detail = json.loads(e.read().decode("utf-8"))
            msg = detail.get("error", {}).get("message", str(e))
        except Exception:
            msg = str(e)
        return None, "Erreur Claude (" + str(e.code) + ") : " + msg
    except urllib.error.URLError as e:
        return None, "Impossible de joindre Claude — vérifiez votre connexion Internet."
    contenu = data.get("content", [])
    texte = "".join(b.get("text", "") for b in contenu if b.get("type") == "text")
    return texte.strip() or "(réponse vide)", None


class Handler(http.server.BaseHTTPRequestHandler):
    server_version = "TerminalMagique/1.0"

    def log_message(self, format, *args):
        pass  # silence les logs sur stdout

    def _json(self, obj, code=200):
        corps = json.dumps(obj).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(corps)))
        self.end_headers()
        self.wfile.write(corps)

    def _fichier_statique(self, nom):
        chemin = os.path.join(SCRIPT_DIR, nom)
        if not os.path.isfile(chemin):
            self.send_error(404)
            return
        types = {".html": "text/html", ".css": "text/css", ".js": "application/javascript"}
        ext = os.path.splitext(nom)[1]
        with open(chemin, "rb") as f:
            corps = f.read()
        self.send_response(200)
        self.send_header("Content-Type", types.get(ext, "application/octet-stream") + "; charset=utf-8")
        self.send_header("Content-Length", str(len(corps)))
        self.end_headers()
        self.wfile.write(corps)

    def do_GET(self):
        if self.path in ("/", "/index.html"):
            self._fichier_statique("index.html")
        elif self.path in ("/style.css", "/app.js"):
            self._fichier_statique(self.path.lstrip("/"))
        elif self.path == "/api/guide":
            self._json(parser_guide())
        elif self.path == "/api/reglages":
            self._json({
                "modele_local": modele_local_actif(),
                "claude_modele": lire(CLAUDE_MODELE_FICHIER, CLAUDE_MODELE_DEFAUT),
                "claude_configuree": bool(lire(CLAUDE_CLE_FICHIER)),
            })
        else:
            self.send_error(404)

    def do_POST(self):
        longueur = int(self.headers.get("Content-Length", 0))
        brut = self.rfile.read(longueur) if longueur else b"{}"
        try:
            payload = json.loads(brut.decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            self._json({"erreur": "Requête invalide."}, 400)
            return

        if self.path == "/api/chat":
            message = (payload.get("message") or "").strip()
            source = payload.get("source") or "local"
            if not message:
                self._json({"erreur": "Message vide."}, 400)
                return
            if source == "claude":
                reponse, erreur = appeler_claude(message)
            else:
                reponse, erreur = appeler_ollama(message)
            if erreur:
                self._json({"erreur": erreur})
            else:
                self._json({"reponse": reponse})
        elif self.path == "/api/reglages":
            cle = (payload.get("claude_cle") or "").strip()
            modele = (payload.get("claude_modele") or "").strip()
            try:
                if cle:
                    ecrire_prive(CLAUDE_CLE_FICHIER, cle)
                if modele:
                    ecrire_prive(CLAUDE_MODELE_FICHIER, modele)
                self._json({"ok": True})
            except OSError as e:
                self._json({"ok": False, "erreur": str(e)}, 500)
        else:
            self.send_error(404)


def main():
    port = int(os.environ.get("APPLICATION_PORT", "8765"))
    serveur = http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print("Serveur Terminal Magique sur http://127.0.0.1:%d" % port, flush=True)
    try:
        serveur.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
