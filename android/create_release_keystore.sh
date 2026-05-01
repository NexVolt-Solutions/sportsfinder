#!/usr/bin/env bash
# Creates android/upload-keystore.jks for release signing. Not committed (gitignored).
set -euo pipefail
cd "$(dirname "$0")"
JKS="upload-keystore.jks"
if [[ -f "$JKS" ]]; then
  echo "Refusing to overwrite existing $JKS. Remove it first or pick another name."
  exit 1
fi

echo "This will create $JKS in $(pwd)"
echo "You will be prompted for keystore password, key password, and certificate details (name, org, etc.)."
echo ""
keytool -genkeypair -v \
  -keystore "$JKS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -storetype PKCS12

echo ""
echo "Next steps:"
echo "  1. cp key.properties.example key.properties"
echo "  2. Edit key.properties: set storePassword and keyPassword to match keytool."
echo "  3. ./gradlew :app:signingReport  → add release SHA-1/256 to Firebase (com.sportfinding.app)"
echo "  4. flutter build appbundle   (or apk)"
