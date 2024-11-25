#!/bin/sh

SEMPRE_BAIXAR=FALSE

PAPERMC_VERSION=${VERSION}
PAPERMC_BUILD=${BUILD}

if [[ $PAPERMC_VERSION == "" || $PAPERMC_VERSION == "latest" ]]; then
  SEMPRE_BAIXAR=TRUE
  echo "[INFO] Buscando ultima versão do papermc"
  PAPERMC_VERSION=$(curl -s "https://papermc.io/api/v2/projects/paper" | jq '.versions[-1]' -r)
  echo "[OK] Versão do papermc mais atualizada: ${PAPERMC_VERSION}"
else
  echo "[WARN] Parece que uma versão especifica do papermc foi informada, tentando baixar a build mais recente dela..."
fi

if [[ $PAPERMC_BUILD == "" || $PAPERMC_BUILD == "latest" ]]; then
  SEMPRE_BAIXAR=TRUE
  echo "[INFO] Buscando ultima build para a versão: ${PAPERMC_VERSION}"
  PAPERMC_BUILD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}" | jq '.builds[-1]')
  echo "[OK] Última build encontrada: ${PAPERMC_BUILD}"
else
  echo "[WARN] Parece que uma versão especifica da build do papermc foi informada, tentando baixar..."
fi

PAPERMC_JAR_NAME=paper-${PAPERMC_VERSION}-${PAPERMC_BUILD}.jar

if [[ -f ~/${PAPERMC_JAR_NAME} && ${SEMPRE_BAIXAR} == FALSE ]]; then
  echo "[OK] Parece que o arquivo já foi baixado. Pulando download"
else
  echo "[INFO] Verificando se a versão ${PAPERMC_VERSION}-${PAPERMC_BUILD} ja esta em uso..."
  LATEST_DOWNLOAD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${PAPERMC_BUILD}" | jq '.downloads.application.name' -r)
  PAPERMC_JAR_NAME=$LATEST_DOWNLOAD

  if [[ -f ./${LATEST_DOWNLOAD} ]]; then
      echo "[WARN] Versão já esta atualizada!"
  else
      echo "[INFO] Baixando nova versão..."
      PAPERMC_DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${PAPERMC_BUILD}/downloads/${LATEST_DOWNLOAD}"
      curl -s -o ${LATEST_DOWNLOAD} ${PAPERMC_DOWNLOAD_URL}
      echo "[OK] Nova versão pronta para uso."
  fi
fi

ls -lagh

echo -------------------------
echo Request version $VERSION build $BUILD
echo Paper version $PAPERMC_VERSION build $PAPERMC_BUILD
echo -------------------------

echo "PAPERMC_JAR_NAME=${PAPERMC_JAR_NAME}" >> /minecraft/variaveis.env
