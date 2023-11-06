#!/bin/sh
set -e

echo "> java -Xms${PAPERMC_START_MEMORY} \
            -Xmx${PAPERMC_MAX_MEMORY} ${PAPERMC_JAVA_ARGS}
            -Dcom.mojang.eula.agree=true
            -jar ${PAPERMC_JAR_NAME}
            -p ${PAPERMC_PORT}
            -h ${PAPERMC_HOST}
            -s ${PAPERMC_MAX_PLAYERS}
            -P ${PAPERMC_PLUGIN_DIR}
            -W ${PAPERMC_WORLD_DIR} ${PAPERMC_ARGS} ${PARAMS}"
java -Xms${PAPERMC_START_MEMORY} -Xmx${PAPERMC_MAX_MEMORY} ${PAPERMC_JAVA_ARGS} -Dcom.mojang.eula.agree=true -jar ${PAPERMC_JAR_NAME} -p ${PAPERMC_PORT} -h ${PAPERMC_HOST} -s ${PAPERMC_MAX_PLAYERS} -P ${PAPERMC_PLUGIN_DIR} -W ${PAPERMC_WORLD_DIR} ${PAPERMC_ARGS} ${PARAMS}
