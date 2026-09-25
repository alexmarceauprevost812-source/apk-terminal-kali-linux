# magie-kali-auto : ouvre directement Kali Linux dans chaque nouvelle session.
# « exit » revient au terminal Android ; « kali auto off » désactive.
if [ -f "$HOME/.magie/kali-auto" ] && [ -z "${MAGIE_TERMUX:-}" ] && [ -t 0 ] && command -v kali >/dev/null 2>&1; then
  kali
fi
