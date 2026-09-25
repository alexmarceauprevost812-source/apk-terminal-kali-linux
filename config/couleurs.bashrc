# magie-couleurs : plus de couleurs quand on tape une commande
# (ls, grep, diff, man, less, compilateur, erreurs en rouge…)
# Chargé depuis ~/.bashrc, dans Termux comme dans Kali. « couleurs off » pour couper.

couleurs() {
  case "${1:-}" in
    off) mkdir -p "$HOME/.magie"; touch "$HOME/.magie/couleurs-off"; echo "✔ Couleurs coupées (nouvelle session)" ;;
    on)  rm -f "$HOME/.magie/couleurs-off"; echo "✔ Couleurs activées (nouvelle session)" ;;
    *)   echo "Usage : couleurs on|off" ;;
  esac
}

[ -f "$HOME/.magie/couleurs-off" ] && return 0

export CLICOLOR=1
export LESS='-R'                                  # less garde les couleurs
export GCC_COLORS='error=01;31:warning=01;33:note=01;36:caret=01;32:locus=01:quote=01'

# Couleurs des fichiers et dossiers (ls, eza, tab-complétion)
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b 2>/dev/null)"
fi
export GREP_COLORS='mt=1;38;2;50;255;0:fn=36:ln=33:se=90'   # correspondances en vert lime

# Pages de manuel (man) et less en couleurs
export LESS_TERMCAP_mb=$'\e[1;31m'   # clignotant -> rouge
export LESS_TERMCAP_md=$'\e[1;38;2;50;255;0m'   # titres en vert lime
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;36m'   # soulignés en cyan
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;30;43m' # surbrillance
export LESS_TERMCAP_se=$'\e[0m'

# Commandes courantes en couleur
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
diff --color=auto /dev/null /dev/null >/dev/null 2>&1 && alias diff='diff --color=auto'
if ! command -v eza >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
fi
command -v ip >/dev/null 2>&1 && ip -c link >/dev/null 2>&1 && alias ip='ip -c'
command -v dmesg >/dev/null 2>&1 && alias dmesg='dmesg --color=always'

# Après chaque commande : ✖ rouge avec le code si elle a échoué (une seule fois par commande)
__magie_statut() {
  local code=$?
  local num="${HISTCMD:-0}"
  if [ "$code" -ne 0 ] && [ "$num" != "${__magie_dernier:-}" ]; then
    printf '\033[1;31m✖ La commande a échoué (code %s)\033[0m\n' "$code"
  fi
  __magie_dernier="$num"
  return "$code"
}
case ";${PROMPT_COMMAND:-};" in
  *__magie_statut*) ;;
  *) PROMPT_COMMAND="__magie_statut${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac
