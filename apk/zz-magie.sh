# Terminal Linux Magique — lancé à chaque ouverture de session (etc/profile.d).
# Au tout premier démarrage : applique le thème et propose d'installer les IA.
if [ ! -f "$HOME/.magie/.premier-demarrage" ] && [ -t 0 ] && [ -t 1 ]; then
  mkdir -p "$HOME/.magie"
  touch "$HOME/.magie/.premier-demarrage"
  bash /data/data/com.termux/files/usr/share/magie/apk/premier-demarrage.sh
fi

# Suivi des mises à jour : vérifie l'existence d'une nouvelle APK à chaque ouverture.
if [ -t 1 ] && command -v magie-update >/dev/null 2>&1; then
  ( magie-update --check 2>/dev/null & )
fi
