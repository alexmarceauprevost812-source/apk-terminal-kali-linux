# magie-theme : fond noir, écriture blanche, nom d'utilisateur vert lime (style Kali)
#   ┌──(root㉿kali)-[~]
#   └─#
if grep -qi '^ID=kali' /etc/os-release 2>/dev/null; then __magie_hote=kali; else __magie_hote=android; fi
__magie_lime='\[\e[1;38;2;50;255;0m\]'   # vert lime #32FF00
__magie_blanc='\[\e[0;97m\]'             # blanc
__magie_gras='\[\e[1;97m\]'              # blanc gras
PS1="${__magie_blanc}┌──(${__magie_lime}\u㉿${__magie_hote}${__magie_blanc})-[${__magie_gras}\w${__magie_blanc}]\n└─${__magie_lime}\\\$${__magie_blanc} "
unset PS0 __magie_hote __magie_lime __magie_blanc __magie_gras
