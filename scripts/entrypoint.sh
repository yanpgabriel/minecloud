#!/bin/bash
set -e

if [ ! -w /minecraft ]; then
  echo "[ERRO] Sem permissão de escrita em /minecraft. O processo está rodando como UID:GID $(id -u):$(id -g), mas o dono do volume no host é outro."
  echo "[ERRO] Ajuste o dono da pasta no host (chown) OU defina HOST_UID/HOST_GID no .env pra bater com o dono atual, sem precisar rebuildar a imagem."
  exit 1
fi

echo "Versão selecionada ${VERSION}-${BUILD}"

# shellcheck disable=SC1091
source /scripts/download-server.sh

echo 'Iniciando...'

# shellcheck disable=SC1091
source /scripts/start-server.sh