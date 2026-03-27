#!/usr/bin/env bash
set -euo pipefail

RELEASE_ROOT="${1:-release}"

echo "Creando entorno de liberación en: $RELEASE_ROOT"

mkdir -p "$RELEASE_ROOT"
mkdir -p "$RELEASE_ROOT/logs"
mkdir -p "$RELEASE_ROOT/build"
mkdir -p "$RELEASE_ROOT/build/web"
mkdir -p "$RELEASE_ROOT/build/temp"
mkdir -p "$RELEASE_ROOT/deploy"

echo "Entorno de liberación creado correctamente."