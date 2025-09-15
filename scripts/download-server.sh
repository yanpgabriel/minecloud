#!/bin/sh

SEMPRE_BAIXAR=FALSE

PAPERMC_VERSION=${VERSION}
PAPERMC_BUILD=${BUILD}
USER_AGENT="minecloud/1.0.0 (oyan.dev)"

if [[ $PAPERMC_VERSION == "" || $PAPERMC_VERSION == "latest" ]]; then
  SEMPRE_BAIXAR=TRUE
  echo "[INFO] Buscando ultima versão do papermc"
  PAPERMC_VERSION=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper | jq -r '.versions | to_entries[0] | .value[0]')
  echo "[OK] Versão do papermc mais atualizada: ${PAPERMC_VERSION}"
else
  echo "[WARN] Parece que uma versão especifica do papermc foi informada, tentando baixar a build mais recente dela..."
fi

if [[ $PAPERMC_BUILD == "" || $PAPERMC_BUILD == "latest" ]]; then
  SEMPRE_BAIXAR=TRUE
  echo "[INFO] Buscando ultima build para a versão: ${PAPERMC_VERSION}"
  PAPERMC_BUILD=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/${PAPERMC_VERSION}/builds | jq -r 'map(select(.channel == "STABLE")) | .[0] | .id')
  echo "[OK] Última build encontrada: ${PAPERMC_BUILD}"
else
  echo "[WARN] Parece que uma versão especifica da build do papermc foi informada, tentando baixar..."
fi

PAPERMC_JAR_NAME=paper-${PAPERMC_VERSION}-${PAPERMC_BUILD}.jar

if [[ -f ~/${PAPERMC_JAR_NAME} && ${SEMPRE_BAIXAR} == FALSE ]]; then
  echo "[OK] Parece que o arquivo já foi baixado. Pulando download"
else
  echo "[INFO] Verificando se a versão ${PAPERMC_VERSION}-${PAPERMC_BUILD} ja esta em uso..."
  if [[ $PAPERMC_BUILD == "latest" ]]; then
    LATEST_DOWNLOAD=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/${PAPERMC_VERSION}/builds | jq -r 'first(.[] | select(.channel == "STABLE") | .downloads."server:default".url) // "null"')
  else
    LATEST_DOWNLOAD=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/${PAPERMC_VERSION}/builds | jq -r --argjson PAPERMC_BUILD "$PAPERMC_BUILD" 'first(.[] | select(.id == $PAPERMC_BUILD) | select(.channel == "STABLE") | .downloads."server:default".url) // "null"')
  fi

  PAPERMC_JAR_NAME=$LATEST_DOWNLOAD | jq -r  'split("/") | last'

  if [[ -f ./${PAPERMC_JAR_NAME} ]]; then
      echo "[WARN] Versão já esta atualizada!"
  else
      echo "[INFO] Baixando nova versão..."
      curl -s -o ${PAPERMC_JAR_NAME} ${LATEST_DOWNLOAD}
      echo "[OK] Nova versão pronta para uso."
  fi
fi

ls -lagh

echo -------------------------
echo Request version $VERSION build $BUILD
echo Paper version $PAPERMC_VERSION build $PAPERMC_BUILD
echo -------------------------

echo "PAPERMC_JAR_NAME=${PAPERMC_JAR_NAME}" >> /minecraft/variaveis.env
