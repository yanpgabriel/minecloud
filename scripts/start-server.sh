#!/bin/bash
set -e

cd /minecraft

# shellcheck disable=SC1091
source variaveis.env

echo "eula=true" > eula.txt

PAPERMC_START_MEMORY=${PAPERMC_START_MEMORY:-1G}
PAPERMC_MAX_MEMORY=${PAPERMC_MAX_MEMORY:-2G}

echo "[INFO] Heap: -Xms${PAPERMC_START_MEMORY} -Xmx${PAPERMC_MAX_MEMORY}"

# exec substitui o processo do shell pelo java, para que ele vire PID 1
# e receba o SIGTERM do "docker stop" diretamente (permite salvar o mundo antes de encerrar)
# shellcheck disable=SC2086 # PAPERMC_JAVA_ARGS precisa ficar sem aspas pra fazer word-splitting de varias flags
exec java -Xms"${PAPERMC_START_MEMORY}" -Xmx"${PAPERMC_MAX_MEMORY}" ${PAPERMC_JAVA_ARGS} -jar "${PAPERMC_JAR_NAME}" --nogui