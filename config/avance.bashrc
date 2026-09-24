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
