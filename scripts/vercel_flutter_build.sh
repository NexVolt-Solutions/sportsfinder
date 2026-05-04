#!/usr/bin/env bash
# Vercel Linux build: install Flutter (not on PATH by default) and emit web assets to build/web.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER_DIR="${ROOT}/.flutter"
if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
flutter config --no-analytics
flutter precache --web
flutter pub get
flutter build web --release
