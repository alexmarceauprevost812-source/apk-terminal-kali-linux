# Terminal Linux Magique — lancé à chaque ouverture de session (etc/profile.d).
# Au tout premier démarrage : applique le thème et propose d'installer les IA.
if [ ! -f "$HOME/.magie/.premier-demarrage" ] && [ -t 0 ] && [ -t 1 ]; then
  mkdir -p "$HOME/.magie"
  touch "$HOME/.magie/.premier-demarrage"
  bash /data/data/com.termux/files/usr/share/magie/apk/premier-demarrage.sh
fi

# Suivi des mises à jour : vérifie l'existence d'une nouvelle APK au plus une fois par jour.
if [ -t 1 ] && command -v magie-update >/dev/null 2>&1; then
  __magie_marqueur="$HOME/.magie/.derniere-verif"
  if [ ! -f "$__magie_marqueur" ] || [ -z "$(find "$__magie_marqueur" -mtime -1 2>/dev/null)" ]; then
    touch "$__magie_marqueur"
    ( magie-update --check 2>/dev/null & )
  fi
  unset __magie_marqueur
fi
