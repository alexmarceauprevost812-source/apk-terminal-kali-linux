// Terminal Magique — interface graphique (chat + guide), 100 % locale.
// Parle au serveur local (bin/application) qui relaie vers Ollama et/ou Claude.

(function () {
  "use strict";

  // Service worker minimal (aucune mise en cache) : sert uniquement à rendre
  // l'installation possible si l'utilisateur le souhaite ; jamais imposé.
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("sw.js").catch(() => {});
  }

  // --- Installer sur l'écran d'accueil (toujours optionnel) ---------------
  let evenementInstall = null;
  const boutonEntete = document.getElementById("bouton-installer");
  const boutonReglages = document.getElementById("installer-reglages");
  const statutInstall = document.getElementById("installer-statut");

  window.addEventListener("beforeinstallprompt", (ev) => {
    ev.preventDefault();
    evenementInstall = ev;
    boutonEntete.hidden = false;
    boutonReglages.hidden = false;
  });

  async function proposerInstallation() {
    if (!evenementInstall) return;
    boutonEntete.hidden = true;
    boutonReglages.hidden = true;
    evenementInstall.prompt();
    const choix = await evenementInstall.userChoice;
    if (choix.outcome !== "accepted") {
      // L'utilisateur a refusé — on redonne le choix plus tard.
      boutonEntete.hidden = false;
      boutonReglages.hidden = false;
    }
    evenementInstall = null;
  }
  boutonEntete.addEventListener("click", proposerInstallation);
  boutonReglages.addEventListener("click", proposerInstallation);

  window.addEventListener("appinstalled", () => {
    boutonEntete.hidden = true;
    boutonReglages.hidden = true;
    if (statutInstall) statutInstall.textContent = "✔ Installée — retrouvez-la sur votre écran d'accueil.";
  });

  const onglets = document.querySelectorAll(".onglet");
  const vues = { chat: "vue-chat", guide: "vue-guide", reglages: "vue-reglages" };

  onglets.forEach((bouton) => {
    bouton.addEventListener("click", () => {
      onglets.forEach((b) => b.classList.remove("actif"));
      bouton.classList.add("actif");
      Object.values(vues).forEach((id) => document.getElementById(id).classList.remove("actif"));
      document.getElementById(vues[bouton.dataset.onglet]).classList.add("actif");
      if (bouton.dataset.onglet === "guide" && !guideCharge) chargerGuide();
    });
  });

  // --- Choix de la source d'IA --------------------------------------------
  let sourceActive = "local";
  document.querySelectorAll(".pilule").forEach((p) => {
    p.addEventListener("click", () => {
      document.querySelectorAll(".pilule").forEach((x) => x.classList.remove("actif"));
      p.classList.add("actif");
      sourceActive = p.dataset.source;
    });
  });

  // --- Coloration syntaxique simple, sans dépendance externe --------------
  const MOTS_CLES = [
    "if","else","elif","fi","then","do","done","for","while","case","esac","in",
    "function","return","def","class","import","from","const","let","var","echo",
    "print","exec","true","false","null","None","try","except","break","continue"
  ];
  function echapper(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }
  function colorerCode(code) {
    let s = echapper(code);
    s = s.replace(/(#.*$|\/\/.*$)/gm, '<span class="tok-commentaire">$1</span>');
    s = s.replace(/("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')/g, '<span class="tok-chaine">$1</span>');
    s = s.replace(/\b(\d+(?:\.\d+)?)\b/g, '<span class="tok-nombre">$1</span>');
    const motsRe = new RegExp("\\b(" + MOTS_CLES.join("|") + ")\\b", "g");
    s = s.replace(motsRe, '<span class="tok-mot-cle">$1</span>');
    s = s.replace(/\b([a-zA-Z_][\w-]*)(?=\()/g, '<span class="tok-fonction">$1</span>');
    return s;
  }

  // Rendu minimal markdown : blocs ```code```, `code` en ligne, gras/italique.
  function rendreMessage(texte) {
    const conteneur = document.createElement("div");
    const morceaux = texte.split(/```([\s\S]*?)```/g);
    morceaux.forEach((morceau, i) => {
      if (i % 2 === 1) {
        const lignes = morceau.split("\n");
        if (lignes[0] && !lignes[0].includes(" ")) lignes.shift();
        const pre = document.createElement("pre");
        const code = document.createElement("code");
        code.innerHTML = colorerCode(lignes.join("\n").trim());
        pre.appendChild(code);
        conteneur.appendChild(pre);
      } else if (morceau.trim()) {
        const p = document.createElement("div");
        let html = echapper(morceau);
        html = html.replace(/`([^`]+)`/g, '<code>$1</code>');
        html = html.replace(/\*\*([^*]+)\*\*/g, "<b>$1</b>");
        p.innerHTML = html;
        conteneur.appendChild(p);
      }
    });
    return conteneur;
  }

  // --- Chat -----------------------------------------------------------------
  const messages = document.getElementById("messages");
  const form = document.getElementById("form-chat");
  const saisie = document.getElementById("saisie");
  const envoyer = document.getElementById("envoyer");

  function ajouterMessage(qui, texte) {
    const div = document.createElement("div");
    div.className = "message " + qui;
    const bulle = document.createElement("div");
    bulle.className = "bulle";
    bulle.appendChild(rendreMessage(texte));
    div.appendChild(bulle);
    messages.appendChild(div);
    messages.scrollTop = messages.scrollHeight;
    return bulle;
  }
  function ajouterErreur(texte) {
    const div = document.createElement("div");
    div.className = "message erreur";
    div.innerHTML = '<div class="bulle">' + echapper(texte) + "</div>";
    messages.appendChild(div);
    messages.scrollTop = messages.scrollHeight;
  }

  saisie.addEventListener("input", () => {
    saisie.style.height = "auto";
    saisie.style.height = Math.min(saisie.scrollHeight, 120) + "px";
  });

  form.addEventListener("submit", async (ev) => {
    ev.preventDefault();
    const texte = saisie.value.trim();
    if (!texte) return;
    ajouterMessage("utilisateur", texte);
    saisie.value = "";
    saisie.style.height = "auto";
    envoyer.disabled = true;
    const attente = ajouterMessage("ia", "…");

    try {
      const rep = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ source: sourceActive, message: texte }),
      });
      const data = await rep.json();
      attente.innerHTML = "";
      if (data.erreur) {
        attente.appendChild(rendreMessage("⚠️ " + data.erreur));
      } else {
        attente.appendChild(rendreMessage(data.reponse || "(réponse vide)"));
      }
    } catch (e) {
      attente.innerHTML = "";
      attente.appendChild(rendreMessage("⚠️ Impossible de joindre le serveur local. Réessayez."));
    } finally {
      envoyer.disabled = false;
      messages.scrollTop = messages.scrollHeight;
    }
  });

  // --- Guide ------------------------------------------------------------
  let guideCharge = false;
  let outilsGuide = [];
  async function chargerGuide() {
    guideCharge = true;
    const liste = document.getElementById("guide-liste");
    liste.textContent = "Chargement…";
    try {
      const rep = await fetch("/api/guide");
      outilsGuide = await rep.json();
      afficherGuide(outilsGuide);
    } catch (e) {
      liste.textContent = "Guide indisponible.";
    }
  }
  function afficherGuide(outils) {
    const liste = document.getElementById("guide-liste");
    liste.innerHTML = "";
    outils.forEach((o) => {
      const carte = document.createElement("div");
      carte.className = "outil-carte";
      let html = '<span class="outil-nom">' + echapper(o.nom) + '</span>' +
        '<span class="outil-cat">[' + echapper(o.categorie) + ']</span>' +
        '<div class="outil-resume">' + echapper(o.resume) + '</div>';
      (o.exemples || []).forEach((ex) => {
        html += '<code class="outil-exemple">' + echapper(ex) + '</code>';
      });
      carte.innerHTML = html;
      liste.appendChild(carte);
    });
  }
  document.getElementById("guide-recherche").addEventListener("input", (ev) => {
    const q = ev.target.value.toLowerCase();
    afficherGuide(outilsGuide.filter((o) =>
      (o.nom + " " + o.categorie + " " + o.resume).toLowerCase().includes(q)));
  });

  // --- Réglages : clé Claude ----------------------------------------------
  fetch("/api/reglages").then((r) => r.json()).then((d) => {
    document.getElementById("modele-local").textContent = d.modele_local || "—";
    if (d.claude_modele) document.getElementById("claude-modele").value = d.claude_modele;
    if (d.claude_configuree) {
      document.getElementById("claude-cle").placeholder = "(déjà enregistrée)";
    }
  }).catch(() => {});

  document.getElementById("claude-enregistrer").addEventListener("click", async () => {
    const cle = document.getElementById("claude-cle").value.trim();
    const modele = document.getElementById("claude-modele").value.trim();
    const statut = document.getElementById("claude-statut");
    statut.textContent = "Enregistrement…";
    try {
      const rep = await fetch("/api/reglages", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ claude_cle: cle, claude_modele: modele }),
      });
      const d = await rep.json();
      statut.textContent = d.ok ? "✔ Enregistré." : "⚠️ " + (d.erreur || "échec");
      document.getElementById("claude-cle").value = "";
    } catch (e) {
      statut.textContent = "⚠️ Serveur injoignable.";
    }
  });
})();
