#!/bin/bash
set -e

CONFIG_DIR=/config
SERVER_PROPERTIES=/minecraft/server.properties

aplicar_overlay() {
  if [ ! -d "$CONFIG_DIR" ]; then
    echo "[INFO] Sem overlay de config em ${CONFIG_DIR}, usando o que já está no volume"
    return 0
  fi

  local total=0
  local sobrescritos=0
  local origem relativo destino

  while IFS= read -r -d '' origem; do
    relativo="${origem#"$CONFIG_DIR"/}"
    destino="/minecraft/${relativo}"

    if [ -f "$destino" ] && cmp -s "$origem" "$destino"; then
      echo "[OK] inalterado: ${relativo}"
      total=$((total + 1))
      continue
    fi

    if [ -f "$destino" ]; then
      echo "[AVISO] sobrescrito: ${relativo}"
      sobrescritos=$((sobrescritos + 1))
    else
      echo "[OK] criado: ${relativo}"
    fi

    mkdir -p "$(dirname "$destino")"
    cp "$origem" "$destino"
    total=$((total + 1))
  done < <(find "$CONFIG_DIR" -type f ! -name '.gitkeep' -print0)

  if [ "$total" -eq 0 ]; then
    echo "[INFO] Nenhum arquivo de config pra aplicar"
    return 0
  fi

  echo "[INFO] ${total} arquivo(s) de config aplicado(s) sobre /minecraft, ${sobrescritos} sobrescrito(s)"

  if [ "$sobrescritos" -gt 0 ]; then
    echo "[AVISO] Os arquivos marcados como sobrescritos tinham edição feita direto no volume e foram substituídos pela versão do overlay"
  fi
}

definir_propriedade() {
  local chave="$1"
  local valor="$2"
  local anterior

  [ -n "$valor" ] || return 0

  if grep -q "^${chave}=" "$SERVER_PROPERTIES" 2>/dev/null; then
    anterior="$(sed -n "s|^${chave}=||p" "$SERVER_PROPERTIES" | head -n 1)"

    if [ "$anterior" = "$valor" ]; then
      echo "[OK] server.properties ${chave}=${valor} (inalterado)"
      return 0
    fi

    sed -i "s|^${chave}=.*|${chave}=${valor}|" "$SERVER_PROPERTIES"
    echo "[AVISO] server.properties sobrescrito: ${chave} ${anterior} -> ${valor}"
    return 0
  fi

  echo "${chave}=${valor}" >> "$SERVER_PROPERTIES"
  echo "[OK] server.properties ${chave}=${valor}"
}

aplicar_overlay
definir_propriedade online-mode "${ONLINE_MODE:-}"
