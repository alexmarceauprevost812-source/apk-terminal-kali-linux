# 🐉 Terminal Magique — le vrai terminal Kali Linux sur une APK Android

Une **APK** qui met un vrai **Kali Linux** dans le **Samsung Galaxy S25 Ultra**
(et tout Android 7+ en ARM64), **sans root**. Kali s'ouvre directement au lancement de l'appli.
Des IA gratuites hors-ligne sont disponibles en option.

- 🐉 **Vrai Kali Linux** : l'image officielle `kalilinux/kali-rolling`, installée via `proot-distro`,
  **avec ses outils déjà prêts** (nmap, sqlmap, hydra, nikto, john, metasploit…)
- 🐧 **Terminal Android** en plus : bash et `pkg` (des milliers de logiciels)
- ⌨ **Terminal avancé** : barre de touches Ctrl / Alt / Échap / Tab / flèches, plusieurs sessions,
  autocomplétion, recherche floue dans l'historique (fzf), tmux, serveur SSH
- 🧰 **Outils installés** : neovim, vim, micro, nano, git, ssh, rsync, python, nodejs, clang,
  make, cmake, ripgrep, fd, bat, eza, zoxide, btop, htop, jq, nmap, dnsutils…
- 🎨 **Thème** : fond **noir**, écriture **blanche**, nom d'utilisateur **vert lime**
- 🤖 **IA gratuites (option)** : Llama 3.2, Gemma 3, Qwen, Phi-4, DeepSeek R1, Mistral… via Ollama

---

## 1. Installer l'APK « Terminal Magique » (recommandé)

1. Sur le téléphone, ouvrez la page **Releases** du dépôt :
   <https://github.com/alexmarceauprevost812-source/apk-terminal-kali-linux/releases/latest>
2. Téléchargez **`terminal-magique-…-arm64-v8a.apk`** (pour le S25 Ultra).
3. Ouvrez le fichier et autorisez « Installer des applis inconnues » si Android le demande.
4. Lancez **Terminal Magique** : le thème, la barre de touches spéciales et les commandes
   `kali` et `magie` sont déjà dedans. L'appli propose ensuite d'installer **Kali Linux**
   et les outils du terminal avancé (~1 Go, Wi-Fi conseillé), puis, **en option**, le moteur d'IA.
5. Ensuite, **chaque nouvelle session ouvre directement Kali Linux** :

   ```
   ┌──(root㉿kali)-[~]
   └─# apt install <paquet>
   ```

   `exit` revient au terminal Android ; `kali auto off` désactive l'ouverture automatique.

> ⚠️ L'APK est basée sur Termux (même nom de paquet `com.termux`) :
> **désinstallez Termux s'il est déjà installé** avant d'installer Terminal Magique.
> Play Protect peut afficher un avertissement (appli hors Play Store) : choisissez « Installer quand même ».
> Les modules Termux:API / Termux:Widget de F-Droid ne sont pas compatibles avec cette APK
> (signature différente).

Si vous refusez l'installation au premier lancement, tapez plus tard `magie-installer`
(ou seulement `kali` pour installer Kali).

### Comment l'APK est construite

`apk/construire.sh` télécharge le code source officiel de Termux (version figée),
change le nom de l'appli, ajoute nos scripts dans
l'environnement Linux de base, puis compile l'APK. Le workflow GitHub Actions
`.github/workflows/apk.yml` le lance à chaque modification de la branche `main`
et publie les APK dans **Releases** (on peut aussi le lancer à la main depuis l'onglet Actions).

### Mises à jour (sans tout retélécharger)

Vos données — **Kali Linux, les outils installés et l'IA** — ne sont **pas** dans l'APK :
elles vivent dans l'espace de l'application. On peut donc corriger les bugs **sans rien
perdre et sans tout recommencer**.

- **`magie-update`** : corrige et met à jour les **commandes** (`magie`, `kali`, `guide`,
  `catalogue`, `bureau`, `ia`…) directement depuis GitHub. **Kali, les outils et l'IA sont
  conservés.** C'est la façon normale de recevoir les corrections — pas besoin de réinstaller.
- **`magie maj`** : fait tout — paquets Termux, commandes de l'app, puis Kali (`kali maj`).
- À chaque ouverture, l'app vérifie s'il existe une version plus récente et propose
  `magie-update`.

**Mettre à jour l'APK elle-même** (rare : seulement pour un changement de l'application,
comme l'icône) : téléchargez la nouvelle APK et **installez-la PAR-DESSUS l'ancienne**.
⚠️ **Ne désinstallez pas** l'application avant : désinstaller efface Kali, les outils et
l'IA. Installer par-dessus garde tout. (On ne désinstalle Termux qu'une seule fois, avant
le tout premier install, s'il est déjà présent.)

Le numéro de version installé est dans `share/magie/VERSION`.

## 2. Autre méthode : Termux + script

Si vous préférez l'appli Termux officielle
([F-Droid](https://f-droid.org/packages/com.termux/) ou
[GitHub](https://github.com/termux/termux-app/releases), pas le Play Store), ouvrez-la et collez :

```bash
pkg install -y git && git clone https://github.com/alexmarceauprevost812-source/apk-terminal-kali-linux.git && cd apk-terminal-kali-linux && bash install.sh
```

L'installateur met Termux à jour, installe les outils Linux (git, python, nodejs, clang,
vim, htop, tmux…), donne accès aux fichiers du téléphone, installe **Kali Linux** et **Ollama**,
applique le thème et installe les commandes `kali`, `magie` et `ia`.
Options : `--sans-kali` (sans Kali), `--sans-ia` (sans le moteur d'IA).

## 3. (Option) Télécharger une IA gratuite

```bash
magie installer-ia
```

| Pack    | Modèles                                       | Taille  |
|---------|-----------------------------------------------|---------|
| Léger ⭐ | `llama3.2:3b`                                 | ~2 Go   |
| Complet | `llama3.2:3b` + `gemma3:4b` + `qwen2.5-coder:3b` | ~7 Go   |
| Mini    | `llama3.2:1b`                                 | ~1,3 Go |

Autres IA disponibles avec `magie modeles` : `qwen2.5:3b`, `phi4-mini`,
`deepseek-r1:1.5b`, `moondream` (photos), `mistral:7b`… ou n'importe quel
modèle de <https://ollama.com/library>.

> 💡 Le S25 Ultra (12 Go de RAM) fait tourner confortablement les modèles de 1 à 4 milliards
> de paramètres, et jusqu'à 7-8 milliards plus lentement.

## 4. Le terminal avancé

| Action | Comment |
|--------|---------|
| Touches spéciales | barre au-dessus du clavier : `ESC` `TAB` `CTRL` `ALT` flèches `HOME` `END` `PGUP` `PGDN` |
| Ctrl + touche | **Volume bas** + touche (ex. Vol↓ + C = Ctrl+C) |
| Plusieurs terminaux | glisser depuis le bord gauche → *New session*, ou `Ctrl+Alt+C` |
| Écran coupé en deux | `tmux` puis `Ctrl+B` `%` |
| Historique | `Ctrl+R` (recherche floue fzf) |
| Aller dans un dossier | `z nom` (zoxide) |
| Éditer un fichier | `nvim`, `micro` ou `nano` |
| Installer un logiciel | `apt install nom` (dans Kali) ou `pkg install nom` (terminal Android) |
| Accès depuis un PC | `magie ssh` puis `ssh -p 8022 …` depuis le PC |
| Aide-mémoire | `magie raccourcis` |

Réglages : `config/termux.properties` (copié dans `~/.termux/`) et `config/avance.bashrc`.

## 5. Utilisation

```bash
magie                         # menu interactif
kali                          # entrer dans Kali Linux
magie ssh                     # serveur SSH pour se connecter depuis un PC
ia                            # discussion avec l'IA (/bye pour quitter)
ia "Explique-moi Linux"       # réponse rapide
ia -m gemma3:4b "Bonjour"     # choisir une autre IA
cat notes.txt | ia "résume"   # l'IA lit un fichier
magie serveur                 # API IA sur http://127.0.0.1:11434
magie aide                    # toutes les commandes
```

`magie serveur` permet aussi d'utiliser vos IA dans des applis Android graphiques
compatibles Ollama.

## 🐉 Kali Linux

| Commande | Effet |
|----------|-------|
| `kali` | entrer dans Kali Linux (l'installe au premier lancement) |
| `exit` | revenir au terminal Android |
| `kali maj` | mettre Kali à jour (`apt full-upgrade`) |
| `kali outils` | (ré)installer les outils Kali de base |
| `kali outils complet` | installer **tous** les outils (`kali-linux-headless`, plusieurs Go) |
| `kali auto on` / `kali auto off` | ouvrir (ou non) Kali à chaque nouvelle session |
| `kali -- commande` | lancer une commande dans Kali depuis Android |
| `kali installer` | (ré)installer Kali |

Kali est installé à partir de l'image Docker officielle `kalilinux/kali-rolling`.
Dès la première installation, **une sélection d'outils est installée automatiquement**
(voir `config/kali-outils.txt`) : `nmap`, `sqlmap`, `hydra`, `nikto`, `whatweb`, `dirb`,
`wpscan`, `john`, `hashcat`, `metasploit-framework`, etc. Ils sont donc déjà prêts
à la première ouverture de Kali.

Pour tout ajouter (l'ensemble d'outils standard), tapez `kali outils complet`
(métapaquet `kali-linux-headless`).

> ℹ️ Sans root, Kali tourne dans `proot` : certaines fonctions qui exigent le noyau ou la
> carte Wi-Fi (mode moniteur, scans réseau bruts) ne sont pas disponibles.
> Utilisez les outils de sécurité uniquement sur vos propres appareils et réseaux,
> ou avec une autorisation écrite.

## 📚 Catalogue des outils (par catégorie)

Comme sur <https://www.kali.org/tools/>, les outils sont **classés par catégorie**
(Collecte d'informations, Applications web, Mots de passe, Sans fil, Exploitation,
Forensique…). On parcourt, on lit ce que fait chaque outil, et on l'installe.

```bash
catalogue          # menu des catégories → choisir → installer
catalogue web      # cherche « web » dans tout le catalogue
catalogue installer nmap sqlmap   # installe directement
```

(aussi `kali catalogue` et l'option 2 du menu `magie`.) La liste est dans
`config/kali-catalogue.txt`. Depuis une catégorie, tapez les numéros à installer,
ou `g <outil>` pour ouvrir le guide.

## 📖 Guide des outils

Chaque outil est expliqué : à quoi il sert, en une phrase simple, avec un exemple.

```bash
guide            # la liste de tous les outils avec un résumé
guide nmap       # fiche détaillée d'un outil + exemples
guide web        # cherche « web » dans les noms, catégories et résumés
```

(aussi `kali guide` et l'option 3 du menu `magie`). La liste se modifie dans
`config/kali-guide.txt`.

## 🧑‍💻 L'IA écrit et exécute la commande pour vous

Pour un débutant qui ne sait pas encore taper la bonne commande : décrivez en français
ce que vous voulez faire, l'IA propose **une seule commande** avec une explication,
et **rien ne s'exécute sans votre accord**.

```bash
ia commande "trouve les appareils connectés sur mon wifi"
ia commande "installe nmap"
ia commande "montre-moi l'espace disque restant"
```

(aussi `magie commande "..."` et l'option 12 du menu `magie`.) La commande proposée
s'affiche en **bleu ciel**, avec un `(O/n)` pour confirmer. Si la commande semble
risquée (effacer des fichiers, formater…), une confirmation renforcée est demandée
(il faut taper le mot « oui » en entier). Si vous répondez « n » ou appuyez sur
Entrée, rien n'est exécuté.

> 💡 Ça marche aussi pour apprendre à utiliser un outil déjà téléchargé :
> `ia commande "comment scanner mon réseau avec nmap"` explique et propose la commande.

## 🛠️ Claude Code (assistant officiel d'Anthropic)

En plus de l'IA locale gratuite ci-dessus, vous pouvez installer **Claude Code**,
l'outil officiel d'Anthropic en ligne de commande — plus puissant pour coder,
lire et modifier des fichiers, gérer un projet.

```bash
claude-code            # l'installe (une fois) puis l'ouvre
claude-code installer  # (ré)installer / mettre à jour
```

(aussi `magie claude` et l'option 16 du menu `magie`.) Une fois installé, la vraie
commande s'appelle **`claude`**.

> ⚠️ Différence avec « ia » : Claude Code a besoin d'**Internet** et d'un **compte
> Anthropic / Claude** (abonnement Pro ou Max, ou une clé API) — ce n'est pas gratuit
> ni hors-ligne comme l'IA locale. À la première ouverture, il demande de vous
> connecter dans le navigateur.
>
> ℹ️ Installez-le depuis le **terminal Android** (pas depuis Kali) : tapez `exit`
> si vous êtes dans Kali.

## 🇫🇷 Toujours en français

Tout le terminal parle français, y compris les IA :

- **Claude Code** (`claude-code`) : répond et écrit toujours en français (Québec), même
  question posée dans une autre langue. La règle est ajoutée automatiquement dans
  `~/.claude/CLAUDE.md` et rappelée à chaque lancement (`--append-system-prompt`).
- **Kali Linux** : la commande `kali francais` installe la locale `fr_FR.UTF-8` et
  l'active à chaque ouverture de session dans Kali. Elle est appliquée automatiquement
  à l'installation de Kali, et rappelée à chaque `kali maj`.
- **L'IA locale** (`ia`) : une copie du modèle actif est créée une seule fois avec la
  consigne « réponds toujours en français » intégrée (`ollama create`), puis réutilisée
  — aucun re-téléchargement, juste une configuration locale.

Pour l'activer sur un téléphone déjà installé : `magie-update`, puis `kali francais`
(seulement si Kali est installé — sinon rien à faire de plus, c'est automatique).

## 🖥️ Bureau graphique (comme un ordinateur)

L'APK peut afficher un **vrai bureau Kali (XFCE)** — barre des tâches, menu, fenêtres —
sur le téléphone, via un affichage VNC.

```bash
bureau installer   # installe le bureau XFCE dans Kali (~1 à 2 Go, une seule fois)
bureau             # démarre le bureau et indique comment l'afficher
bureau arreter     # arrête le bureau
```

Pour **voir** le bureau : installez une appli **VNC Viewer** (gratuite, Play Store),
ouvrez-la et connectez-vous à **`localhost:1`** (mot de passe choisi à l'installation).

**Icônes sur le bureau** (comme un ordinateur) : à l'installation, le bureau reçoit des
icônes cliquables — **Terminal Kali**, **Catalogue outils**, **Guide des outils**,
**Fichiers**, et **Navigateur Web** s'il est installé. Pour les recréer : `bureau icones`.
Le bouton pour ouvrir le bureau est l'option 5 du menu `magie` (ou la commande `bureau`).

**Fond d'écran :** un fond thématique (noir / vert lime) est appliqué automatiquement.
Pour mettre **votre propre image** :

```bash
bureau fond ~/storage/dcim/ma-photo.jpg   # une photo du téléphone
bureau fond                               # revenir au fond par défaut
```

(Vos photos sont dans `~/storage/dcim` ou `~/storage/downloads`. Le fond se met à jour
tout de suite si le bureau tourne, sinon au prochain démarrage.)

> 💡 Un écran de téléphone reste petit pour un bureau : c'est plus confortable en
> connectant le téléphone à un écran (DeX sur le S25 Ultra) ou en affichant depuis un PC.

## 🎨 Thème

| Élément                     | Couleur          |
|-----------------------------|------------------|
| Fond                        | noir `#000000`   |
| Écriture                    | blanc `#FFFFFF`  |
| Nom d'utilisateur (`root㉿kali`) et `$` / `#` | vert lime `#32FF00` |
| Curseur                     | blanc            |

Fichiers : `config/colors.properties` (couleurs du terminal, copiées dans `~/.termux/`)
et `config/theme.bashrc` (invite de commande style Kali, appliquée dans Kali et dans Android).
L'ancien thème est sauvegardé dans `~/.termux/colors.properties.bak`.

## 💻 Sur un PC Windows ?

L'APK est pour Android. Sur Windows, installez un **vrai Kali Linux** via WSL2 :
voir **[windows/README.md](windows/README.md)** (installation automatique, mêmes outils
et même thème noir / blanc / nom d'utilisateur vert lime).

## Pourquoi les IA ne sont pas « dans l'APK » ?

Un modèle d'IA pèse de 1 à 5 Go : l'intégrer à l'APK la rendrait énorme et figée.
Ici, les IA sont **prêtes à télécharger** en une commande depuis le terminal,
et restent ensuite **100 % hors-ligne** sur le téléphone.

## Structure

```
install.sh              installateur
bin/magie               menu magique
bin/kali                terminal Kali Linux (installation, mise à jour, auto)
bin/guide               guide : ce que fait chaque outil Kali
bin/catalogue           catalogue des outils par catégorie (installe)
bin/bureau              bureau graphique XFCE (via VNC)
bin/ia                  question rapide à l'IA / « ia commande » (propose + exécute)
bin/claude-code         installe et lance Claude Code (officiel Anthropic)
bin/magie-installer     installation complète (depuis l'APK)
bin/magie-update        met à jour l'app et vérifie la nouvelle APK
config/termux.properties barre de touches, raccourcis, historique
config/avance.bashrc    autocomplétion, fzf, zoxide, alias
config/kali-auto.bashrc ouvre Kali à chaque nouvelle session
config/kali-outils.txt  outils Kali installés automatiquement
config/kali-guide.txt   guide (rôle + exemples) de chaque outil
config/kali-catalogue.txt outils classés par catégorie (kali.org/tools)
config/fond-ecran.png   fond d'écran par défaut du bureau
apk/icone.png           (optionnel) icône de l'application
apk/construire.sh       construit l'APK Terminal Magique
apk/premier-demarrage.sh accueil au premier lancement de l'APK
apk/zz-magie.sh         déclenche l'accueil (etc/profile.d)
.github/workflows/apk.yml compilation automatique + Releases
config/modeles.txt      liste des IA gratuites proposées
config/colors.properties thème : fond noir, écriture blanche
config/theme.bashrc     invite style Kali, nom d'utilisateur vert lime
```
