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

# Icône de l'application : si apk/icone.png existe, elle remplace l'icône par défaut.
if [ -f "$RACINE/apk/icone.png" ]; then
  echo "==> 2b. Icône personnalisée (apk/icone.png)"
  python3 -c "import PIL" 2>/dev/null || pip install --quiet --break-system-packages Pillow 2>/dev/null || pip install --quiet Pillow
  RES="app/src/main/res" python3 - "$RACINE/apk/icone.png" <<'PY'
import os, sys
from PIL import Image, ImageDraw
src = Image.open(sys.argv[1]).convert("RGBA")
res = os.environ["RES"]
tailles = {"mdpi":48, "hdpi":72, "xhdpi":96, "xxhdpi":144, "xxxhdpi":192}
def carre(im, n):
    im = im.copy(); im.thumbnail((n, n), Image.LANCZOS)
    fond = Image.new("RGBA", (n, n), (0, 0, 0, 255))
    fond.paste(im, ((n-im.width)//2, (n-im.height)//2), im)
    return fond
def rond(im, n):
    base = carre(im, n)
    masque = Image.new("L", (n, n), 0)
    ImageDraw.Draw(masque).ellipse((0, 0, n-1, n-1), fill=255)
    sortie = Image.new("RGBA", (n, n), (0, 0, 0, 0)); sortie.paste(base, (0, 0), masque)
    return sortie
for d, n in tailles.items():
    dossier = f"{res}/mipmap-{d}"; os.makedirs(dossier, exist_ok=True)
    carre(src, n).save(f"{dossier}/ic_launcher.png")
    rond(src, n).save(f"{dossier}/ic_launcher_round.png")
    # Avant-plan de l'icône adaptative (zone de sécurité : image centrée à ~66%)
    fg = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    vign = src.copy(); vign.thumbnail((int(n*0.66), int(n*0.66)), Image.LANCZOS)
    fg.paste(vign, ((n-vign.width)//2, (n-vign.height)//2), vign)
    fg.save(f"{dossier}/ic_launcher_foreground.png")
# Icône adaptative (Android 8+) : fond noir + notre image en avant-plan
for nom in ("ic_launcher", "ic_launcher_round"):
    with open(f"{res}/mipmap-anydpi-v26/{nom}.xml", "w") as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                '    <background android:drawable="@android:color/black"/>\n'
                '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
                '</adaptive-icon>\n')
print("Icône appliquée.")
PY
fi

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
# Version installée (pour le suivi des mises à jour)
printf '%s\n' "$VERSION" > "$AJOUT/share/magie/VERSION"

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
