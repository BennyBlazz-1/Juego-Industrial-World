#!/usr/bin/env bash
set -euo pipefail

RELEASE_PATH="${1:-release}"
LOG_FILE="$RELEASE_PATH/logs/verify_release_artifacts.log"

mkdir -p "$RELEASE_PATH/logs"

echo "Verificando artefactos del entorno de liberación..." | tee "$LOG_FILE"

required_dirs=(
  "$RELEASE_PATH/logs"
  "$RELEASE_PATH/build"
  "$RELEASE_PATH/build/web"
  "$RELEASE_PATH/build/temp"
  "$RELEASE_PATH/deploy"
)

for dir in "${required_dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "[OK] Carpeta encontrada: $dir" | tee -a "$LOG_FILE"
  else
    echo "[ERROR] Falta carpeta requerida: $dir" | tee -a "$LOG_FILE"
    exit 1
  fi
done

echo "La verificación del entorno de liberación fue exitosa." | tee -a "$LOG_FILE"