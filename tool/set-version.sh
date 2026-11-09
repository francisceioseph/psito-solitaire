#!/bin/bash
# Grava a versão no pubspec. Quem chama é o semantic-release, no CI.
# Uso: tool/set-version.sh <versão>
set -e

cd "$(dirname "$0")/.."

VERSION="${1:?uso: tool/set-version.sh <versão>}"
sed -i "s/^version: .*/version: $VERSION/" pubspec.yaml
sed -i "s/^const appVersion = .*/const appVersion = '$VERSION';/" lib/src/version.dart
