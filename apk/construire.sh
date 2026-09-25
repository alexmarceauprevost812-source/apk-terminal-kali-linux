#!/usr/bin/env bash
# ============================================================================
#  Construit l'APK « Terminal Magique » à partir du code source de Termux.
#  - nom de l'appli : Terminal Magique
#  - couleurs par défaut : fond noir, texte blanc (le vert lime vient de l'invite)
#  - les commandes magie / ia / magie-installer et le thème sont intégrés
#    à l'environnement Linux de base (bootstrap) de l'APK
#  Prérequis : Java 17, SDK Android (ANDROID_HOME), zip, git.
#  Usage : bash apk/construire.sh   → APK dans sortie-apk/
# ============================================================================
set -euo pipefail

RACINE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERMUX_DEPOT="https://github.com/termux/termux-app.git"
TERMUX_COMMIT="084d709fbf23ea83b5cb85fd3d795c775be06676"
NOM_APPLI="Terminal Magique"
TRAVAIL="$RACINE/build-apk"
SORTIE="$RACINE/sortie-apk"
VERSION="${VERSION_MAGIE:-1.0.0}"

echo "==> 1. Récupération du code source de Termux ($TERMUX_COMMIT)"
rm -rf "$TRAVAIL"
git init -q "$TRAVAIL/termux-app"
cd "$TRAVAIL/termux-app"
git fetch -q --depth 1 "$TERMUX_DEPOT" "$TERMUX_COMMIT"
git checkout -q FETCH_HEAD

echo "==> 2. Personnalisation (nom)"
sed -i "s|<string name=\"application_name\">&TERMUX_APP_NAME;</string>|<string name=\"application_name\">$NOM_APPLI</string>|" \
  app/src/main/res/values/strings.xml
grep -q "<string name=\"application_name\">$NOM_APPLI</string>" app/src/main/res/values/strings.xml

# Couleurs par défaut de Termux déjà voulues : fond noir 0xff000000, texte blanc 0xffffffff
grep -q "0xffffffff, 0xff000000, 0xffffffff};" \
  terminal-emulator/src/main/java/com/termux/terminal/TerminalColorScheme.java

export TERMUX_PACKAGE_VARIANT=apt-android-7
export TERMUX_APP_VERSION_NAME="0.118.0+magie.$VERSION"
export TERMUX_APK_VERSION_TAG="terminal-magique-$VERSION"

echo "==> 3. Téléchargement de l'environnement Linux de base (bootstrap)"
./gradlew -q :app:downloadBootstraps

echo "==> 4. Ajout des fichiers magiques dans le bootstrap"
AJOUT="$TRAVAIL/ajout"
rm -rf "$AJOUT"
mkdir -p "$AJOUT/bin" "$AJOUT/share/magie" "$AJOUT/etc/profile.d"
cp "$RACINE"/bin/* "$AJOUT/bin/"
cp -r "$RACINE/bin" "$RACINE/config" "$RACINE/apk" "$RACINE/install.sh" "$AJOUT/share/magie/"
rm -f "$AJOUT/share/magie/apk/construire.sh"
cp "$RACINE/apk/zz-magie.sh" "$AJOUT/etc/profile.d/zz-magie.sh"

for zipf in app/src/main/cpp/bootstrap-*.zip; do
  ancien="$(sha256sum "$zipf" | cut -d' ' -f1)"
  (cd "$AJOUT" && zip -qr "$OLDPWD/$zipf" .)
  nouveau="$(sha256sum "$zipf" | cut -d' ' -f1)"
  grep -q "$ancien" app/build.gradle
  sed -i "s/$ancien/$nouveau/" app/build.gradle
  echo "    $(basename "$zipf") : $ancien → $nouveau"
done

echo "==> 5. Compilation de l'APK"
./gradlew -q assembleDebug

echo "==> 6. Copie des APK"
rm -rf "$SORTIE"
mkdir -p "$SORTIE"
for abi in arm64-v8a universal; do
  cp "app/build/outputs/apk/debug/termux-app_${TERMUX_APK_VERSION_TAG}_${abi}.apk" \
     "$SORTIE/terminal-magique-${VERSION}-${abi}.apk"
done
(cd "$SORTIE" && sha256sum ./*.apk > sha256sums.txt)
ls -lh "$SORTIE"
echo "✔ APK prêts dans $SORTIE"
