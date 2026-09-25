<#
  installer-kali-windows.ps1
  Installe Kali Linux sur Windows 10/11 via WSL2, avec ses outils et le thème
  du projet (fond noir, écriture blanche, nom d'utilisateur vert lime).

  Utilisation :
    1. Ouvrez PowerShell en tant qu'administrateur
       (menu Démarrer → tapez "powershell" → clic droit → Exécuter en tant qu'administrateur)
    2. Autorisez le script pour cette session :
         Set-ExecutionPolicy -Scope Process Bypass -Force
    3. Lancez :
         .\installer-kali-windows.ps1
#>

Write-Host ""
Write-Host "  ==============================================" -ForegroundColor Green
Write-Host "     Kali Linux sur Windows (WSL2) - installateur" -ForegroundColor Green
Write-Host "  ==============================================" -ForegroundColor Green
Write-Host ""

# 1. Vérifier les droits administrateur
$estAdmin = ([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent()
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $estAdmin) {
  Write-Host "X  Lancez ce script dans PowerShell EN ADMINISTRATEUR." -ForegroundColor Red
  Write-Host "   (menu Demarrer > powershell > clic droit > Executer en tant qu'administrateur)"
  return
}

# 2. Installer WSL + Kali
Write-Host "-> Installation de WSL et de Kali Linux..." -ForegroundColor Yellow
Write-Host "   Si Windows demande un redemarrage, redemarrez puis relancez ce script."
wsl --install --no-distribution
wsl --set-default-version 2 | Out-Null
wsl --install -d kali-linux

Write-Host ""
Write-Host "  --------------------------------------------------------" -ForegroundColor Green
Write-Host "  Kali est en cours d'installation." -ForegroundColor Green
Write-Host "  Une fenetre Kali va s'ouvrir et vous demander de creer" -ForegroundColor Green
Write-Host "  un nom d'utilisateur et un mot de passe. Faites-le," -ForegroundColor Green
Write-Host "  puis DANS la fenetre Kali, collez cette seule ligne :" -ForegroundColor Green
Write-Host ""
Write-Host '    wget -qO- https://raw.githubusercontent.com/alexmarceauprevost812-source/apk-terminal-kali-linux/main/windows/configurer-kali.sh | bash' -ForegroundColor Cyan
Write-Host ""
Write-Host "  Elle installe les outils Kali et le theme (noir / blanc /" -ForegroundColor Green
Write-Host "  nom d'utilisateur vert lime). Fermez puis rouvrez Kali ensuite." -ForegroundColor Green
Write-Host "  --------------------------------------------------------" -ForegroundColor Green
Write-Host ""
Write-Host "Pour rouvrir Kali plus tard : tapez  kali-linux  dans le menu Demarrer,"
Write-Host "ou  wsl -d kali-linux  dans un terminal."
