#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-./Industrial World}"
RELEASE_PATH="${2:-release}"
LOG_FILE="$RELEASE_PATH/logs/smoke_tests.log"

mkdir -p "$RELEASE_PATH/logs"

echo "Iniciando pruebas básicas del proyecto..." | tee "$LOG_FILE"

required_files=(
  "$PROJECT_PATH/project.godot"
  "$PROJECT_PATH/scenes/world.tscn"
  "$PROJECT_PATH/scenes/man_player.tscn"
  "$PROJECT_PATH/scripts/man_player.gd"
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    echo "[OK] Archivo encontrado: $file" | tee -a "$LOG_FILE"
  else
    echo "[ERROR] Falta archivo requerido: $file" | tee -a "$LOG_FILE"
    exit 1
  fi
done

echo "Pruebas básicas completadas correctamente." | tee -a "$LOG_FILE"