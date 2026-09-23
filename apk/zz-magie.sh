# Terminal Linux Magique — lancé à chaque ouverture de session (etc/profile.d).
# Au tout premier démarrage : applique le thème et propose d'installer les IA.
if [ ! -f "$HOME/.magie/.premier-demarrage" ] && [ -t 0 ] && [ -t 1 ]; then
  mkdir -p "$HOME/.magie"
  touch "$HOME/.magie/.premier-demarrage"
  bash /data/data/com.termux/files/usr/share/magie/apk/premier-demarrage.sh
fi
