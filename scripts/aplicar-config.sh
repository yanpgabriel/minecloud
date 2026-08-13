#!/bin/bash
set -e

CONFIG_DIR=/config
SERVER_PROPERTIES=/minecraft/server.properties

aplicar_overlay() {
  [ -d "$CONFIG_DIR" ] || return 0

  local total=0
  local origem relativo destino

  while IFS= read -r -d '' origem; do
    relativo="${origem#"$CONFIG_DIR"/}"
    destino="/minecraft/${relativo}"
    mkdir -p "$(dirname "$destino")"
    cp "$origem" "$destino"
    echo "[OK] ${relativo}"
    total=$((total + 1))
  done < <(find "$CONFIG_DIR" -type f ! -name '.gitkeep' -print0)

  if [ "$total" -eq 0 ]; then
    echo "[INFO] Nenhum arquivo de config pra aplicar"
  else
    echo "[INFO] ${total} arquivo(s) de config aplicado(s) sobre /minecraft"
  fi
}

definir_propriedade() {
  local chave="$1"
  local valor="$2"

  [ -n "$valor" ] || return 0

  if grep -q "^${chave}=" "$SERVER_PROPERTIES" 2>/dev/null; then
    sed -i "s|^${chave}=.*|${chave}=${valor}|" "$SERVER_PROPERTIES"
  else
    echo "${chave}=${valor}" >> "$SERVER_PROPERTIES"
  fi

  echo "[OK] server.properties ${chave}=${valor}"
}

aplicar_overlay
definir_propriedade online-mode "${ONLINE_MODE:-}"
