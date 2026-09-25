# 🐉 Kali Linux sur Windows (WSL2)

Sur un PC Windows, l'APK Android ne s'installe pas. Utilisez plutôt **WSL2**,
qui fait tourner un **vrai Kali Linux** dans Windows — les mêmes outils, en plus rapide.

## Méthode automatique

1. Menu Démarrer → tapez `powershell` → **clic droit → Exécuter en tant qu'administrateur**.
2. Collez :
   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass -Force
   irm https://raw.githubusercontent.com/alexmarceauprevost812-source/apk-terminal-kali-linux/main/windows/installer-kali-windows.ps1 | iex
   ```
3. Suivez les indications à l'écran. Kali vous demandera de créer un nom d'utilisateur
   et un mot de passe, puis vous collerez **dans la fenêtre Kali** :
   ```bash
   wget -qO- https://raw.githubusercontent.com/alexmarceauprevost812-source/apk-terminal-kali-linux/main/windows/configurer-kali.sh | bash
   ```
   Cela installe les outils Kali et le thème (noir / blanc / nom d'utilisateur vert lime).
4. Fermez puis rouvrez Kali.

## Méthode manuelle

```powershell
wsl --install
wsl --install -d kali-linux
```

Puis dans Kali :
```bash
sudo apt update && sudo apt install -y kali-linux-headless   # tous les outils
```

## Rouvrir Kali

Tapez **`kali-linux`** dans le menu Démarrer, ou `wsl -d kali-linux` dans un terminal.

## Notes

- Windows 10 (2004+) ou Windows 11, en 64 bits.
- WSL2 donne un vrai noyau Linux : contrairement à l'APK (proot sans root),
  vous avez `sudo` et davantage d'outils fonctionnent.
- N'utilisez les outils de sécurité que sur vos propres appareils et réseaux,
  ou avec une autorisation écrite.
