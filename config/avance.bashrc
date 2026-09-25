# magie-avance : confort d'un terminal Linux avancé

# Historique : grand, partagé entre les sessions, sans doublons
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize autocd cdspell globstar 2>/dev/null
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Autocomplétion (Tab) des commandes, options, paquets, git…
[ -r "$PREFIX/share/bash-completion/bash_completion" ] && . "$PREFIX/share/bash-completion/bash_completion"

# fzf : Ctrl+R = recherche floue dans l'historique, Ctrl+T = chercher un fichier
[ -r "$PREFIX/share/fzf/key-bindings.bash" ] && . "$PREFIX/share/fzf/key-bindings.bash"
[ -r "$PREFIX/share/fzf/completion.bash" ] && . "$PREFIX/share/fzf/completion.bash"

# zoxide : « z dossier » saute vers un dossier déjà visité
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# Outils modernes quand ils sont installés
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -la --icons=auto --group-directories-first --git'
  alias arbre='eza --tree --level=2 --icons=auto'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
fi
command -v bat >/dev/null 2>&1 && alias voir='bat --paging=never'
command -v nvim >/dev/null 2>&1 && { alias vim='nvim'; export EDITOR=nvim; } || export EDITOR=nano
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias maj='pkg update && pkg upgrade -y'
alias ip-locale="ifconfig 2>/dev/null | grep -w inet"

# Français toujours (messages du terminal en français quand c'est possible).
# LANGUAGE est une simple préférence : sans danger même si la locale FR n'existe pas.
export LANGUAGE=fr_FR:fr
# On ne force LANG/LC_ALL au français que si cette locale est réellement disponible,
# sinon bash afficherait « cannot set locale » à chaque commande.
if locale -a 2>/dev/null | grep -qiE '^fr_FR\.utf-?8$'; then
  export LANG=fr_FR.UTF-8
  export LC_ALL=fr_FR.UTF-8
fi

# Fausses commandes : message en ROUGE, avec une aide en français.
command_not_found_handle() {
  local cmd="$1"
  printf '\033[1;31m✖ Commande introuvable : %s\033[0m\n' "$cmd" >&2
  printf '\033[1;33m➜ Cherchez un outil :\033[0m guide %s   \033[1;33mou\033[0m   catalogue %s\n' "$cmd" "$cmd" >&2
  printf '\033[1;33m➜ Pour l'\''installer :\033[0m catalogue installer %s\n' "$cmd" >&2
  return 127
}

# Gérer les sessions : fermer (= « poubelle ») la session en cours.
alias fermer='exit'
alias poubelle='exit'
# Sessions tmux (plusieurs terminaux) : lister et en supprimer.
sessions() {
  if ! command -v tmux >/dev/null 2>&1; then echo "tmux n'est pas installé."; return 1; fi
  echo -e "\033[1;33mSessions ouvertes (tmux) :\033[0m"
  tmux ls 2>/dev/null || echo "  (aucune)"
  echo
  echo "  fermer            → fermer la session actuelle (comme la poubelle 🗑)"
  echo "  tmux new -s NOM   → ouvrir une nouvelle session nommée"
  echo "  tmux kill-session -t NOM   → supprimer une session"
  echo "  tmux kill-server  → supprimer TOUTES les sessions tmux"
}
