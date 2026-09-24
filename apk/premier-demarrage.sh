#!/data/data/com.termux/files/usr/bin/bash
# Premier démarrage de l'APK « Terminal Magique ».
MAGIE="/data/data/com.termux/files/usr/share/magie"

# Thème, barre de touches spéciales, raccourcis et commandes (sans Internet)
bash "$MAGIE/install.sh" --config-seulement >/dev/null 2>&1
termux-reload-settings >/dev/null 2>&1

printf '\033[1;32m'
cat <<'TXT'

   ╔══════════════════════════════════════════════╗
   ║     🐧  TERMINAL LINUX AVANCÉ — BIENVENUE      ║
   ╚══════════════════════════════════════════════╝

   Déjà prêt : thème noir / vert lime, touches Ctrl / Alt / Échap /
   Tab / flèches au-dessus du clavier, commandes « magie ».

   Étape suivante (Wi-Fi conseillé, ~1 Go) : installer les outils
   d'un terminal avancé — tmux, neovim, git, ssh, python, nodejs,
   clang, fzf, ripgrep, btop, nmap… — et Linux Debian complet.

TXT
printf '\033[0m'
read -rp "   Installer le terminal avancé maintenant ? (O/n) " rep
case "$rep" in
  n|N|non|NON)
    echo "   Plus tard, tapez :  magie-installer"
    exit 0 ;;
esac

read -rp "   Ajouter aussi le moteur d'IA gratuite hors-ligne (Ollama) ? (o/N) " ia
case "$ia" in
  o|O|oui|OUI|y|Y) bash "$MAGIE/install.sh" ;;
  *) bash "$MAGIE/install.sh" --sans-ia
     echo "   Pour ajouter l'IA plus tard :  pkg install ollama && magie installer-ia" ;;
esac
echo
echo -e "\033[1;32m   Fermez et rouvrez l'appli (ou tapez « exit ») pour tout activer.\033[0m"
