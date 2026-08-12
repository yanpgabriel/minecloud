#!/bin/bash
set -e

if [ ! -w /minecraft ]; then
  echo "[ERRO] Sem permissão de escrita em /minecraft. Verifique se o dono do volume no host bate com o UID/GID do container (padrão 1000:1000)."
  exit 1
fi

echo "Versão selecionada ${VERSION}-${BUILD}"

# shellcheck disable=SC1091
source /scripts/download-server.sh

echo 'Iniciando...'

# shellcheck disable=SC1091
source /scripts/start-server.sh