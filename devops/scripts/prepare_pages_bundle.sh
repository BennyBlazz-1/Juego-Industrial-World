#!/usr/bin/env bash
set -euo pipefail

RELEASE_PATH="${1:-release}"
SOURCE_FILE="$RELEASE_PATH/build/web/index.html"
DEPLOY_DIR="$RELEASE_PATH/deploy"
LOG_FILE="$RELEASE_PATH/logs/prepare_pages_bundle.log"

mkdir -p "$DEPLOY_DIR"
mkdir -p "$RELEASE_PATH/logs"

echo "Preparando paquete final de despliegue..." | tee "$LOG_FILE"

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "[ERROR] No existe el archivo fuente para despliegue: $SOURCE_FILE" | tee -a "$LOG_FILE"
  exit 1
fi

cp "$SOURCE_FILE" "$DEPLOY_DIR/index.html"

echo "[OK] Paquete de despliegue listo en $DEPLOY_DIR/index.html" | tee -a "$LOG_FILE"