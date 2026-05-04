#!/usr/bin/env bash
# Vercel Linux build: install Flutter (not on PATH by default) and emit web assets to build/web.
set -euxo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER_DIR="${ROOT}/.flutter"
FLUTTER_VERSION="3.41.6"
if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]] || [[ "$("${FLUTTER_DIR}/bin/flutter" --version 2>/dev/null | awk '/Flutter / {print $2; exit}')" != "${FLUTTER_VERSION}" ]]; then
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git --branch "${FLUTTER_VERSION}" --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
# Vercel CI can run commands under different users/worktrees; mark repo as safe for git operations Flutter performs internally.
git config --global --add safe.directory "${FLUTTER_DIR}" || true
flutter --version
flutter doctor -v
flutter config --no-analytics --enable-web
flutter precache --web
flutter pub get
flutter build web --release
