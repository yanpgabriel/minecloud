# Melhorias do minecloud

Checklist de ações levantadas na análise do projeto (2026-08-11). Conforme um item for feito (e validado), ele sai daqui — o histórico de por que/como fica no commit correspondente. Ordenado por prioridade dentro de cada bloco.

✅ Já resolvido (bloco 🔴 Crítico inteiro): Java rodando como PID 1 (`exec` em `start-server.sh`), `stop_grace_period: 60s`, heap da JVM configurado via env vars, e a imagem base trocada pra `amazoncorretto:25-alpine` (o `latest` do Paper exige Java 25+, o Java 21 antigo nem subia).

## 🔴 Produção (achados na avaliação de prontidão, 2026-08-11)

✅ Já resolvido: rotação de log configurada no `docker-compose.yml` (`logging.driver: json-file`, `max-size: 10m`, `max-file: 5` — ~50MB no total por container); `HEALTHCHECK` no `Dockerfile` (checa se a porta 25565 aceita conexão TCP, `start-period` de 120s pra dar tempo do boot); e limpeza automática de jars antigos do Paper em `download-server.sh` a cada boot (mantém só o jar em uso). Validado com build real: `docker inspect` mostra `LogConfig` correto e `Health.Status: healthy` após o boot; jar antigo de teste foi removido, só o atual ficou no volume.

- Backup do mundo/plugins: **não é responsabilidade do minecloud** — o próprio yCore já faz backup de mundos e plugins na camada de plugin.

## 🟠 Importante

✅ Já resolvido: bug de atribuição do `PAPERMC_JAR_NAME` em `download-server.sh` (trocado por `basename`), `set -e` + validação de `null`/vazio nas respostas de `curl`/`jq` (com mensagem clara e `exit 1` em vez de seguir com estado quebrado), checagem de permissão de escrita em `/minecraft` no `entrypoint.sh`, e versão do Paper pinada em `VERSION: "26.2"` (com `BUILD: latest`, que hoje resolve pra `112` — a build validada). Isso trava o servidor na versão de Minecraft estável em uso, mas ainda pega builds de correção novas automaticamente dentro do 26.2. Validado com build real em todos os casos.

## 🟡 Melhorias menores

✅ Já resolvido: `restart: unless-stopped`, removidos os bind mounts de `/etc/timezone`/`/etc/localtime` (só funcionavam em host Linux), `variaveis.env` agora é sobrescrito em vez de acumular linhas, scripts migrados pra `#!/bin/bash` (com `bash` instalado na imagem — sem mais depender do compat mode do BusyBox ash), permissão de `/scripts` reduzida pra `755`, `.idea/` no `.gitignore`, checksum sha256 do `.jar` validado contra a API do PaperMC antes de usar o arquivo, CI com `shellcheck` (`.github/workflows/shellcheck.yml`) — scripts já passam limpos —, e destino do `server_downloader` decidido (fica como ferramenta local/dev, documentado no README; não integrado ao Dockerfile). Tudo validado com build + boot real.

## Ideias de conveniência (opcional)

- [ ] Adicionar targets no `Makefile`: `logs`, `shell` (attach no console do server), `restart`.
- [ ] Configurar RCON (env vars + porta) pra administração remota sem precisar de `docker attach`.
