#!/data/data/com.termux/files/usr/bin/bash
# Premier démarrage de l'APK « Terminal Magique ».
MAGIE="/data/data/com.termux/files/usr/share/magie"

bash "$MAGIE/install.sh" --config-seulement >/dev/null 2>&1

printf '\033[1;32m'
cat <<'TXT'

   ╔══════════════════════════════════════════════╗
   ║   🪄  BIENVENUE DANS LE TERMINAL MAGIQUE  🪄   ║
   ╚══════════════════════════════════════════════╝

   Le thème et les commandes « magie » et « ia » sont prêts.

   Étape suivante (Wi-Fi conseillé, ~1 Go) :
     outils Linux + Debian + moteur d'IA Ollama.
   Ensuite, « magie installer-ia » télécharge une IA gratuite.

TXT
printf '\033[0m'
read -rp "   Installer maintenant ? (O/n) " rep
case "$rep" in
  n|N|non|NON)
    echo "   Plus tard, tapez :  magie-installer" ;;
  *)
    bash "$MAGIE/install.sh"
    echo
    read -rp "   Télécharger maintenant l'IA gratuite recommandée (llama3.2:3b, ~2 Go) ? (O/n) " rep2
    case "$rep2" in
      n|N|non|NON) echo "   Plus tard, tapez :  magie installer-ia" ;;
      *) magie telecharger llama3.2:3b ;;
    esac ;;
esac
