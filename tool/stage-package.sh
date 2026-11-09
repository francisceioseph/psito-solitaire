#!/bin/bash
# Monta em <raiz> os arquivos que todo pacote instala, a partir do bundle de release.
# Quem chama é o build-deb.sh e o build-rpm.sh.
# Uso: tool/stage-package.sh <raiz>
set -e

cd "$(dirname "$0")/.."

ROOT="${1:?uso: tool/stage-package.sh <raiz>}"
ID=org.psito.solitaire
NAME=psito-solitaire
BUNDLE=build/linux/x64/release/bundle

mkdir -p "$ROOT/usr/bin" "$ROOT/usr/lib/$NAME" \
    "$ROOT/usr/share/applications" \
    "$ROOT/usr/share/icons/hicolor/512x512/apps" \
    "$ROOT/usr/share/doc/$NAME"

cp -r "$BUNDLE/." "$ROOT/usr/lib/$NAME/"
ln -s "../lib/$NAME/psito_solitaire" "$ROOT/usr/bin/psito_solitaire"
cp "$ID.desktop" "$ROOT/usr/share/applications/"
cp icon.png "$ROOT/usr/share/icons/hicolor/512x512/apps/$ID.png"
cp LICENSE THIRD_PARTY_LICENSES.md README.md "$ROOT/usr/share/doc/$NAME/"
cp assets/LICENSE.md "$ROOT/usr/share/doc/$NAME/ART-LICENSE.md"
cp assets/fonts/OFL.txt "$ROOT/usr/share/doc/$NAME/"
# Os textos das licenças do que foi compilado, que o Flutter junta no bundle
gunzip -c "$BUNDLE/data/flutter_assets/NOTICES.Z" > "$ROOT/usr/share/doc/$NAME/NOTICES"
