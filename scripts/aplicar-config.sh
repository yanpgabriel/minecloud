#!/bin/bash
set -e

CONFIG_DIR=/config

if [ ! -d "$CONFIG_DIR" ]; then
  exit 0
fi

TOTAL=0

while IFS= read -r -d '' origem; do
  relativo="${origem#"$CONFIG_DIR"/}"
  destino="/minecraft/${relativo}"
  mkdir -p "$(dirname "$destino")"
  cp "$origem" "$destino"
  echo "[OK] ${relativo}"
  TOTAL=$((TOTAL + 1))
done < <(find "$CONFIG_DIR" -type f ! -name '.gitkeep' -print0)

if [ "$TOTAL" -eq 0 ]; then
  echo "[INFO] Nenhum arquivo de config pra aplicar"
else
  echo "[INFO] ${TOTAL} arquivo(s) de config aplicado(s) sobre /minecraft"
fi
