#!/bin/sh

echo "Vesão selecionada ${VERSION}-${BUILD}"

source /scripts/download-server.sh

echo 'Iniciando...'

source /scripts/start-server.sh