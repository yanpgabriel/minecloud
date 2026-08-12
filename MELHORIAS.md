# Melhorias do minecloud

Checklist de ações levantadas na análise do projeto (2026-08-11). Conforme um item for feito (e validado), ele sai daqui — o histórico de por que/como fica no commit correspondente. Ordenado por prioridade dentro de cada bloco.

✅ Já resolvido (bloco 🔴 Crítico inteiro): Java rodando como PID 1 (`exec` em `start-server.sh`), `stop_grace_period: 60s`, heap da JVM configurado via env vars, e a imagem base trocada pra `amazoncorretto:25-alpine` (o `latest` do Paper exige Java 25+, o Java 21 antigo nem subia).

## 🔴 Produção (achados na avaliação de prontidão, 2026-08-11)

✅ Já resolvido: rotação de log configurada no `docker-compose.yml` (`logging.driver: json-file`, `max-size: 10m`, `max-file: 5` — ~50MB no total por container), evitando que o disco do host encha silenciosamente com o tempo. Validado via `docker inspect` (`LogConfig` aplicado corretamente).

- Backup do mundo/plugins: **não é responsabilidade do minecloud** — o próprio yCore já faz backup de mundos e plugins na camada de plugin.
- [ ] **Healthcheck**: hoje o Docker só sabe se o container está rodando, não se o servidor travou. Um `HEALTHCHECK` (via RCON ping ou checagem de porta) daria visibilidade real de "travado" em vez de só "container up".
- [ ] **Jars antigos nunca são limpos**: cada troca de versão/build do Paper deixa o `.jar` anterior no volume `/minecraft`. Disco cresce aos poucos ao longo do tempo. Vale um cleanup no `download-server.sh` depois de confirmar que o novo jar baixou/rodou com sucesso.

## 🟠 Importante

✅ Já resolvido: bug de atribuição do `PAPERMC_JAR_NAME` em `download-server.sh` (trocado por `basename`), `set -e` + validação de `null`/vazio nas respostas de `curl`/`jq` (com mensagem clara e `exit 1` em vez de seguir com estado quebrado), e checagem de permissão de escrita em `/minecraft` no `entrypoint.sh`. Validado com build real: fluxo feliz (`latest`/`latest`, jar nomeado corretamente) e fluxo de erro (build inexistente aborta com mensagem clara, exit code 1).

- [ ] **Pinar versão do Paper depois de estabilizar com o yCore**
  `VERSION=latest`/`BUILD=latest` atualiza o Paper a cada boot, o que pode quebrar compatibilidade de plugin sem aviso. Deixar `latest` só pra ambiente de teste; em produção fixar `VERSION`/`BUILD` explícitos no `docker-compose.yml`. (Ainda pendente — só faz sentido depois que o yCore estiver rodando de forma estável nessa stack.)

## 🟡 Melhorias menores

✅ Já resolvido: `restart: unless-stopped`, removidos os bind mounts de `/etc/timezone`/`/etc/localtime` (só funcionavam em host Linux), `variaveis.env` agora é sobrescrito em vez de acumular linhas, scripts migrados pra `#!/bin/bash` (com `bash` instalado na imagem — sem mais depender do compat mode do BusyBox ash), permissão de `/scripts` reduzida pra `755`, `.idea/` no `.gitignore`, checksum sha256 do `.jar` validado contra a API do PaperMC antes de usar o arquivo, CI com `shellcheck` (`.github/workflows/shellcheck.yml`) — scripts já passam limpos —, e destino do `server_downloader` decidido (fica como ferramenta local/dev, documentado no README; não integrado ao Dockerfile). Tudo validado com build + boot real.

## Ideias de conveniência (opcional)

- [ ] Adicionar targets no `Makefile`: `logs`, `shell` (attach no console do server), `restart`.
- [ ] Configurar RCON (env vars + porta) pra administração remota sem precisar de `docker attach`.
