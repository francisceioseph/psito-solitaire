#!/bin/bash
# Compila e monta o pacote .rpm para o Fedora, sem sudo. As dependências vão à mão, sem
# o AutoReq, porque o Flutter abre o EGL e o GLES na hora de desenhar e porque o rpm
# procuraria dentro do bundle por bibliotecas que já vêm nele.
# Uso: tool/build-rpm.sh [pasta de saída, padrão build/rpm] [--no-build]
set -e

cd "$(dirname "$0")/.."

OUT="$(realpath -m "${1:-build/rpm}")"
VERSION="$(sed -n 's/^version: \([^+]*\).*/\1/p' pubspec.yaml)"
NAME=psito-solitaire

[ "$2" = "--no-build" ] || flutter build linux --release

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
tool/stage-package.sh "$WORK/stage"

cat > "$WORK/$NAME.spec" <<SPEC
%global debug_package %{nil}
%global __os_install_post %{nil}
%global _build_id_links none

Name: $NAME
Version: $VERSION
Release: 1
Summary: Classic solitaire card game with cockatiels
License: Apache-2.0
URL: https://francisceioseph.github.io/psito-solitaire/
AutoReqProv: no
Requires: gtk3
Requires: glib2 >= 2.80
Requires: mesa-libEGL
Requires: mesa-libGLES
Recommends: mesa-dri-drivers

%description
A Klondike solitaire with illustrated cockatiel cards.
No ads, no telemetry and no account.

%install
cp -a "$WORK/stage/." %{buildroot}/

%files
/usr/bin/psito_solitaire
/usr/lib/$NAME
/usr/share/applications/org.psito.solitaire.desktop
/usr/share/icons/hicolor/512x512/apps/org.psito.solitaire.png
/usr/share/doc/$NAME
SPEC

mkdir -p "$OUT"
rpmbuild -bb "$WORK/$NAME.spec" --target x86_64 \
    --define "_topdir $WORK/rpmbuild" \
    --define "_rpmdir $OUT" \
    --define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" >/dev/null 2>&1
echo "$OUT/$NAME-$VERSION-1.x86_64.rpm"
