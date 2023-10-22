#!/bin/sh

PAPERMC_VERSION=$1

if [[ $PAPERMC_VERSION == "latest" ]]; then
    echo "[INFO] Buscando ultima versão do papermc" 
    PAPERMC_VERSION=$(curl -s "https://papermc.io/api/v2/projects/paper" | jq '.versions[-1]' -r)
    echo "[OK] Versão do papermc mais atualizada: ${PAPERMC_VERSION}"
else
    echo "[WARN] Parece que uma versão especifica do papermc foi informada, tentando baixar a build mais recente dela..."
fi


echo "[INFO] Buscando ultima build para a versão: ${PAPERMC_VERSION}"
LATEST_BUILD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}" | jq '.builds[-1]')
echo "[OK] Última build encontrada: ${LATEST_BUILD}" 


echo "[INFO] Verificando se a versão ${PAPERMC_VERSION} ja esta em uso..."
LATEST_DOWNLOAD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${LATEST_BUILD}" | jq '.downloads.application.name' -r)


if [[ -f ./${LATEST_DOWNLOAD} ]]; then
    echo "[WARN] Versão já esta atualizada!"
else
    echo "[INFO] Baixando nova versão..."
    PAPERMC_DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${LATEST_BUILD}/downloads/${LATEST_DOWNLOAD}"
    curl -s -o ${LATEST_DOWNLOAD} ${PAPERMC_DOWNLOAD_URL}
    echo "[OK] Nova versão pronta para uso."
fi

echo -----------------
echo $PAPERMC_VERSION#$LATEST_BUILD
echo -----------------