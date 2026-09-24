#!/data/data/com.termux/files/usr/bin/bash
# ============================================================================
#  Terminal Linux Magique — installateur pour Termux (Samsung Galaxy S25 Ultra)
#  Installe : terminal Linux avancé (outils, éditeurs, réseau, dev), Debian complet
#             (proot) et, en option, des IA locales gratuites (Ollama)
#  Usage :  bash install.sh            (installation complète)
#           bash install.sh --no-debian (sans la distribution Debian)
#           bash install.sh --sans-ia   (sans le moteur d'IA)
#           bash install.sh --config-seulement (thème + commandes, sans téléchargement)
# ============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
INSTALL_DEBIAN=1
INSTALL_IA=1
CONFIG_SEULEMENT=0
for arg in "$@"; do
  case "$arg" in
    --no-debian) INSTALL_DEBIAN=0 ;;
    --sans-ia) INSTALL_IA=0 ;;
    --config-seulement) CONFIG_SEULEMENT=1 ;;
  esac
done

violet='\033[1;35m'; vert='\033[1;32m'; jaune='\033[1;33m'; rouge='\033[1;31m'; fin='\033[0m'
etape() { printf "\n${violet}✨ %s${fin}\n" "$*"; }
ok()    { printf "${vert}✔ %s${fin}\n" "$*"; }
info()  { printf "${jaune}➜ %s${fin}\n" "$*"; }
erreur(){ printf "${rouge}✖ %s${fin}\n" "$*" >&2; }

# Installe une liste de paquets ; si un paquet manque, installe les autres un par un.
installer_paquets() {
  if ! pkg install -y "$@"; then
    for p in "$@"; do
      pkg install -y "$p" >/dev/null 2>&1 || info "Paquet indisponible, ignoré : $p"
    done
  fi
}

if [ ! -d /data/data/com.termux ]; then
  erreur "Ce script doit être lancé dans l'application Termux sur Android."
  erreur "Voir README.md pour installer Termux (F-Droid ou GitHub)."
  exit 1
fi

if [ "$CONFIG_SEULEMENT" -eq 0 ]; then
cat <<'EOF'

   ╔══════════════════════════════════════════════╗
   ║   🪄  TERMINAL LINUX MAGIQUE  +  IA GRATUITES  ║
   ║        Samsung Galaxy S25 Ultra · Termux     ║
   ╚══════════════════════════════════════════════╝

EOF

etape "1/6 Mise à jour des paquets"
yes | pkg update -y || true
yes | pkg upgrade -y || true
ok "Paquets à jour"

etape "2/6 Installation du terminal Linux avancé"
info "Base et confort du shell"
installer_paquets bash-completion coreutils findutils grep sed gawk file which tree \
  man less ncurses-utils procps psmisc lsof zip unzip p7zip tar
info "Outils modernes du terminal"
installer_paquets tmux fzf ripgrep fd bat eza zoxide btop htop jq fastfetch
info "Éditeurs de texte"
installer_paquets nano vim neovim micro
info "Réseau"
installer_paquets curl wget openssh rsync net-tools dnsutils nmap traceroute whois
info "Programmation"
installer_paquets git python nodejs clang make cmake pkg-config
info "Android et Linux complet"
installer_paquets termux-tools termux-api proot-distro
ok "Terminal avancé installé"

etape "3/6 Accès au stockage du téléphone"
if [ ! -d "$HOME/storage" ]; then
  info "Android va demander l'autorisation d'accès aux fichiers : acceptez."
  termux-setup-storage || true
fi
ok "Stockage configuré (~/storage)"

if [ "$INSTALL_IA" -eq 1 ]; then
  etape "4/6 Installation du moteur d'IA locale (Ollama)"
  if ! command -v ollama >/dev/null 2>&1; then
    pkg install -y ollama || info "Ollama indisponible pour le moment (réessayez : pkg install ollama)"
  fi
  command -v ollama >/dev/null 2>&1 && ok "Ollama installé : $(ollama --version 2>/dev/null | head -n1 || echo 'ok')"
else
  etape "4/6 Moteur d'IA ignoré (--sans-ia)"
fi

if [ "$INSTALL_DEBIAN" -eq 1 ]; then
  etape "5/6 Installation de Debian (Linux complet, sans root)"
  if proot-distro list 2>/dev/null | grep -q "debian.*installed\|Installed.*debian"; then
    ok "Debian déjà installé"
  else
    proot-distro install debian || info "Debian déjà présent ou installation ignorée"
  fi
  ok "Lancez Debian avec :  magie linux"
else
  etape "5/6 Debian ignoré (--no-debian)"
fi
fi # fin des étapes 1 à 5 (sautées avec --config-seulement)

etape "6/6 Thème noir / vert lime, touches spéciales et commandes"
mkdir -p "$HOME/.termux"
for fichier in colors.properties termux.properties; do
  if [ -f "$HOME/.termux/$fichier" ] && ! cmp -s "$HOME/.termux/$fichier" "$REPO_DIR/config/$fichier"; then
    cp "$HOME/.termux/$fichier" "$HOME/.termux/$fichier.bak"
  fi
  cp "$REPO_DIR/config/$fichier" "$HOME/.termux/$fichier"
done
if ! grep -q "magie-avance" "$HOME/.bashrc" 2>/dev/null; then
  { echo; cat "$REPO_DIR/config/avance.bashrc"; } >> "$HOME/.bashrc"
fi
if ! grep -q "magie-theme" "$HOME/.bashrc" 2>/dev/null; then
  { echo; cat "$REPO_DIR/config/theme.bashrc"; } >> "$HOME/.bashrc"
fi
DEBIAN_BASHRC="$PREFIX/var/lib/proot-distro/installed-rootfs/debian/root/.bashrc"
if [ -f "$DEBIAN_BASHRC" ] && ! grep -q "magie-theme" "$DEBIAN_BASHRC"; then
  { echo; cat "$REPO_DIR/config/theme.bashrc"; } >> "$DEBIAN_BASHRC"
fi
termux-reload-settings 2>/dev/null || true
ok "Thème, barre de touches spéciales et raccourcis appliqués"

for f in "$REPO_DIR"/bin/*; do
  install -m 755 "$f" "$PREFIX/bin/$(basename "$f")"
done
mkdir -p "$HOME/.magie"
cp "$REPO_DIR/config/modeles.txt" "$HOME/.magie/modeles.txt"

if ! grep -q "magie-bienvenue" "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" <<'EOF'

# magie-bienvenue : message d'accueil du Terminal Linux Magique
command -v fastfetch >/dev/null 2>&1 && fastfetch --logo small 2>/dev/null
echo -e "\033[1;32m🐧 Terminal Linux avancé — tapez 'magie' pour le menu ('magie aide' pour tout voir)\033[0m"
EOF
fi
ok "Commandes installées : magie, ia, magie-installer"

[ "$CONFIG_SEULEMENT" -eq 1 ] && exit 0

cat <<EOF

$(printf "${vert}")🎉 Installation terminée !$(printf "${fin}")

  magie                 → menu (Linux, outils, IA)
  magie linux           → entrer dans Debian (apt install …)
  tmux                  → plusieurs fenêtres dans un terminal
  nvim, micro, nano     → éditeurs de texte
  Ctrl+R                → recherche dans l'historique (fzf)
  magie installer-ia    → (option) télécharger une IA gratuite

Fermez et rouvrez l'appli pour activer la barre de touches et le thème.

EOF
