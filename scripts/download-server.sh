#!/bin/bash
set -e

SEMPRE_BAIXAR=FALSE

PAPERMC_VERSION=${VERSION}
PAPERMC_BUILD=${BUILD}
USER_AGENT="minecloud/1.0.0 (oyan.dev)"

if [[ $PAPERMC_VERSION == "" || $PAPERMC_VERSION == "latest" ]]; then
  SEMPRE_BAIXAR=TRUE
  echo "[INFO] Buscando ultima versão do papermc"
  PAPERMC_VERSION=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper | jq -r '.versions | to_entries[0] | .value[0]') || true
  if [[ -z "$PAPERMC_VERSION" || "$PAPERMC_VERSION" == "null" ]]; then
    echo "[ERRO] Nao foi possivel obter a ultima versao do papermc (API fill.papermc.io fora do ar?)"
    exit 1
  fi
  echo "[OK] Versão do papermc mais atualizada: ${PAPERMC_VERSION}"
else
  echo "[WARN] Parece que uma versão especifica do papermc foi informada, tentando baixar a build mais recente dela..."
fi

if [[ $PAPERMC_BUILD == "" || $PAPERMC_BUILD == "latest" ]]; then
  SEMPRE_BAIXAR=TRUE
  echo "[INFO] Buscando ultima build para a versão: ${PAPERMC_VERSION}"
  PAPERMC_BUILD=$(curl -s -H "User-Agent: $USER_AGENT" "https://fill.papermc.io/v3/projects/paper/versions/${PAPERMC_VERSION}/builds" | jq -r 'map(select(.channel == "STABLE")) | .[0] | .id') || true
  if [[ -z "$PAPERMC_BUILD" || "$PAPERMC_BUILD" == "null" ]]; then
    echo "[ERRO] Nao foi possivel obter a ultima build estavel para a versao ${PAPERMC_VERSION}"
    exit 1
  fi
  echo "[OK] Última build encontrada: ${PAPERMC_BUILD}"
else
  echo "[WARN] Parece que uma versão especifica da build do papermc foi informada, tentando baixar..."
fi

PAPERMC_JAR_NAME=paper-${PAPERMC_VERSION}-${PAPERMC_BUILD}.jar

if [[ -f ~/${PAPERMC_JAR_NAME} && ${SEMPRE_BAIXAR} == FALSE ]]; then
  echo "[OK] Parece que o arquivo já foi baixado. Pulando download"
else
  echo "[INFO] Verificando se a versão ${PAPERMC_VERSION}-${PAPERMC_BUILD} ja esta em uso..."
  BUILD_JSON=$(curl -s -H "User-Agent: $USER_AGENT" "https://fill.papermc.io/v3/projects/paper/versions/${PAPERMC_VERSION}/builds") || true

  if [[ $PAPERMC_BUILD == "latest" ]]; then
    DOWNLOAD_INFO=$(echo "$BUILD_JSON" | jq -r 'first(.[] | select(.channel == "STABLE")) | .downloads."server:default" | [.url, .checksums.sha256] | @tsv') || true
  else
    DOWNLOAD_INFO=$(echo "$BUILD_JSON" | jq -r --argjson PAPERMC_BUILD "$PAPERMC_BUILD" 'first(.[] | select(.id == $PAPERMC_BUILD) | select(.channel == "STABLE")) | .downloads."server:default" | [.url, .checksums.sha256] | @tsv') || true
  fi

  LATEST_DOWNLOAD=$(echo "$DOWNLOAD_INFO" | cut -f1)
  LATEST_SHA256=$(echo "$DOWNLOAD_INFO" | cut -f2)

  if [[ -z "$LATEST_DOWNLOAD" || "$LATEST_DOWNLOAD" == "null" ]]; then
    echo "[ERRO] Nao foi possivel encontrar o link de download para ${PAPERMC_VERSION}-${PAPERMC_BUILD}"
    exit 1
  fi

  PAPERMC_JAR_NAME=$(basename "$LATEST_DOWNLOAD")

  if [[ -f ./${PAPERMC_JAR_NAME} ]]; then
      echo "[WARN] Versão já esta atualizada!"
  else
      echo "[INFO] Baixando nova versão..."
      if ! curl -s -o "${PAPERMC_JAR_NAME}" "${LATEST_DOWNLOAD}"; then
        echo "[ERRO] Falha ao baixar ${LATEST_DOWNLOAD}"
        exit 1
      fi

      if [[ -n "$LATEST_SHA256" && "$LATEST_SHA256" != "null" ]]; then
        ACTUAL_SHA256=$(sha256sum "${PAPERMC_JAR_NAME}" | cut -d' ' -f1)
        if [[ "$ACTUAL_SHA256" != "$LATEST_SHA256" ]]; then
          echo "[ERRO] Checksum sha256 nao confere para ${PAPERMC_JAR_NAME} (esperado ${LATEST_SHA256}, obtido ${ACTUAL_SHA256})"
          rm -f "${PAPERMC_JAR_NAME}"
          exit 1
        fi
        echo "[OK] Checksum sha256 conferido."
      fi

      echo "[OK] Nova versão pronta para uso."
  fi
fi

OLD_JARS=$(find . -maxdepth 1 -name 'paper-*.jar' ! -name "${PAPERMC_JAR_NAME}" -type f)
if [[ -n "$OLD_JARS" ]]; then
  echo "[INFO] Removendo jars antigos do papermc:"
  echo "$OLD_JARS"
  find . -maxdepth 1 -name 'paper-*.jar' ! -name "${PAPERMC_JAR_NAME}" -type f -delete
fi

ls -lagh

echo -------------------------
echo Request version "$VERSION" build "$BUILD"
echo Paper version "$PAPERMC_VERSION" build "$PAPERMC_BUILD"
echo -------------------------

echo "PAPERMC_JAR_NAME=${PAPERMC_JAR_NAME}" > /minecraft/variaveis.env
