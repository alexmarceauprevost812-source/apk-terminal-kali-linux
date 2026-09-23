#!/data/data/com.termux/files/usr/bin/bash
# ============================================================================
#  Terminal Linux Magique — installateur pour Termux (Samsung Galaxy S25 Ultra)
#  Installe : outils Linux, Debian complet (proot), IA locales gratuites (Ollama)
#  Usage :  bash install.sh            (installation complète)
#           bash install.sh --no-debian (sans la distribution Debian)
# ============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
INSTALL_DEBIAN=1
for arg in "$@"; do
  case "$arg" in
    --no-debian) INSTALL_DEBIAN=0 ;;
  esac
done

violet='\033[1;35m'; vert='\033[1;32m'; jaune='\033[1;33m'; rouge='\033[1;31m'; fin='\033[0m'
etape() { printf "\n${violet}✨ %s${fin}\n" "$*"; }
ok()    { printf "${vert}✔ %s${fin}\n" "$*"; }
info()  { printf "${jaune}➜ %s${fin}\n" "$*"; }
erreur(){ printf "${rouge}✖ %s${fin}\n" "$*" >&2; }

if [ ! -d /data/data/com.termux ]; then
  erreur "Ce script doit être lancé dans l'application Termux sur Android."
  erreur "Voir README.md pour installer Termux (F-Droid ou GitHub)."
  exit 1
fi

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

etape "2/6 Installation des outils Linux"
pkg install -y \
  git curl wget openssh python nodejs clang make cmake \
  nano vim htop tmux zip unzip jq ncurses-utils \
  proot-distro termux-api fastfetch 2>/dev/null \
  || pkg install -y git curl wget python nodejs nano htop tmux jq proot-distro
ok "Outils Linux installés"

etape "3/6 Accès au stockage du téléphone"
if [ ! -d "$HOME/storage" ]; then
  info "Android va demander l'autorisation d'accès aux fichiers : acceptez."
  termux-setup-storage || true
fi
ok "Stockage configuré (~/storage)"

etape "4/6 Installation du moteur d'IA locale (Ollama)"
if ! command -v ollama >/dev/null 2>&1; then
  pkg install -y ollama
fi
ok "Ollama installé : $(ollama --version 2>/dev/null | head -n1 || echo 'ok')"

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

etape "6/6 Thème noir / vert lime et commandes magiques"
mkdir -p "$HOME/.termux"
[ -f "$HOME/.termux/colors.properties" ] && cp "$HOME/.termux/colors.properties" "$HOME/.termux/colors.properties.bak"
cp "$REPO_DIR/config/colors.properties" "$HOME/.termux/colors.properties"
if ! grep -q "magie-theme" "$HOME/.bashrc" 2>/dev/null; then
  { echo; cat "$REPO_DIR/config/theme.bashrc"; } >> "$HOME/.bashrc"
fi
DEBIAN_BASHRC="$PREFIX/var/lib/proot-distro/installed-rootfs/debian/root/.bashrc"
if [ -f "$DEBIAN_BASHRC" ] && ! grep -q "magie-theme" "$DEBIAN_BASHRC"; then
  { echo; cat "$REPO_DIR/config/theme.bashrc"; } >> "$DEBIAN_BASHRC"
fi
termux-reload-settings 2>/dev/null || true
ok "Thème appliqué (fond noir, texte vert lime, saisie en blanc)"

for f in "$REPO_DIR"/bin/*; do
  install -m 755 "$f" "$PREFIX/bin/$(basename "$f")"
done
mkdir -p "$HOME/.magie"
cp "$REPO_DIR/config/modeles.txt" "$HOME/.magie/modeles.txt"

if ! grep -q "magie-bienvenue" "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" <<'EOF'

# magie-bienvenue : message d'accueil du Terminal Linux Magique
command -v fastfetch >/dev/null 2>&1 && fastfetch --logo small 2>/dev/null
echo -e "\033[1;35m🪄 Tapez 'magie' pour le menu, ou 'ia \"votre question\"'\033[0m"
EOF
fi
ok "Commandes installées : magie, ia"

cat <<EOF

$(printf "${vert}")🎉 Installation terminée !$(printf "${fin}")

  magie                 → menu magique (IA, Linux, outils)
  magie modeles         → télécharger des IA gratuites
  ia "Bonjour !"        → poser une question à l'IA
  magie linux           → entrer dans Debian

Première étape conseillée :  magie installer-ia
(télécharge une IA légère de ~2 Go, recommandée pour le S25 Ultra)

EOF
