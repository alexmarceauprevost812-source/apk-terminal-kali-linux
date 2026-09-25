#!/usr/bin/env bash
# configurer-kali.sh — à lancer DANS Kali (WSL) sur Windows.
# Installe les outils Kali et applique le thème du projet
# (fond noir, écriture blanche, nom d'utilisateur vert lime).
set -uo pipefail

lime='\033[1;38;2;50;255;0m'; jaune='\033[1;33m'; fin='\033[0m'
DEPOT="https://raw.githubusercontent.com/alexmarceauprevost812-source/apk-terminal-kali-linux/main"

if ! grep -qi '^ID=kali' /etc/os-release 2>/dev/null; then
  echo "Ce script est prévu pour Kali Linux (WSL). Ouvrez Kali puis relancez-le."
  exit 1
fi

echo -e "${lime}➜ Mise à jour de Kali…${fin}"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade

echo -e "${lime}➜ Installation des outils Kali (nmap, sqlmap, hydra, metasploit…)…${fin}"
echo -e "${jaune}   (pour TOUS les outils : sudo apt install kali-linux-headless)${fin}"
OUTILS="$(curl -fsSL "$DEPOT/config/kali-outils.txt" 2>/dev/null \
          | grep -vE '^\s*#|^\s*$' | tr '\n' ' ')"
[ -z "$OUTILS" ] && OUTILS="nmap sqlmap hydra nikto john hashcat metasploit-framework curl wget git"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $OUTILS

echo -e "${lime}➜ Application du thème (noir / blanc / nom d'utilisateur vert lime)…${fin}"
if ! grep -q "magie-theme" "$HOME/.bashrc" 2>/dev/null; then
  { echo; curl -fsSL "$DEPOT/config/theme.bashrc"; } >> "$HOME/.bashrc"
fi

echo -e "${lime}✔ Terminé ! Fermez puis rouvrez Kali pour voir le thème.${fin}"
echo "   Exemples d'outils : nmap, sqlmap, hydra, msfconsole"
