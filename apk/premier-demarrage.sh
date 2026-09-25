#!/data/data/com.termux/files/usr/bin/bash
# Premier démarrage de l'APK « Terminal Magique ».
MAGIE="/data/data/com.termux/files/usr/share/magie"

# Thème, barre de touches spéciales, raccourcis et commandes (sans Internet)
bash "$MAGIE/install.sh" --config-seulement >/dev/null 2>&1
termux-reload-settings >/dev/null 2>&1

printf '\033[1;38;2;50;255;0m'
cat <<'TXT'

   ╔══════════════════════════════════════════════╗
   ║      🐉  TERMINAL KALI LINUX — BIENVENUE       ║
   ╚══════════════════════════════════════════════╝

   Déjà prêt : thème noir / blanc / vert lime, touches Ctrl / Alt /
   Échap / Tab / flèches au-dessus du clavier, commandes « kali »
   et « magie ».

   Étape suivante (Wi-Fi conseillé, ~1 Go) : installer Kali Linux
   (image officielle) AVEC ses outils déjà prêts — nmap, sqlmap,
   hydra, nikto, john, metasploit… — et le terminal avancé.

TXT
printf '\033[0m'
read -rp "   Installer Kali Linux maintenant ? (O/n) " rep
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
echo -e "\033[1;38;2;50;255;0m   Fermez et rouvrez l'appli : Kali Linux s'ouvrira directement.\033[0m"
