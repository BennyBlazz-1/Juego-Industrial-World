#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-./Industrial World}"
RELEASE_PATH="${2:-release}"

OUTPUT_DIR="$RELEASE_PATH/build/web"
LOG_FILE="$RELEASE_PATH/logs/export_web.log"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$RELEASE_PATH/logs"

echo "Generando estructura de despliegue..." | tee "$LOG_FILE"

if [[ ! -f "$PROJECT_PATH/project.godot" ]]; then
  echo "[ERROR] No se encontró project.godot en $PROJECT_PATH" | tee -a "$LOG_FILE"
  exit 1
fi

cat > "$OUTPUT_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Industrial World - Despliegue de práctica DevOps</title>
</head>
<body>
  <h1>Industrial World</h1>
  <p>Esta es una salida de despliegue simulada para la práctica DevOps del proyecto en Godot.</p>
  <p>El objetivo es evidenciar la generación automatizada de archivos de salida dentro del repositorio.</p>
</body>
</html>
EOF

echo "[OK] Archivo de despliegue generado en $OUTPUT_DIR/index.html" | tee -a "$LOG_FILE"