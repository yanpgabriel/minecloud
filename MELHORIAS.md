# Melhorias do minecloud

Checklist de ações levantadas na análise do projeto (2026-08-11). Conforme um item for feito (e validado), ele sai daqui — o histórico de por que/como fica no commit correspondente. Ordenado por prioridade dentro de cada bloco.

✅ Já resolvido (bloco 🔴 Crítico inteiro): Java rodando como PID 1 (`exec` em `start-server.sh`), `stop_grace_period: 60s`, heap da JVM configurado via env vars, e a imagem base trocada pra `amazoncorretto:25-alpine` (o `latest` do Paper exige Java 25+, o Java 21 antigo nem subia).

## 🟠 Importante

- [ ] **Pinar versão do Paper depois de estabilizar com o yCore**
  `VERSION=latest`/`BUILD=latest` atualiza o Paper a cada boot, o que pode quebrar compatibilidade de plugin sem aviso. Deixar `latest` só pra ambiente de teste; em produção fixar `VERSION`/`BUILD` explícitos no `docker-compose.yml`.

- [ ] **Corrigir bug de atribuição em `download-server.sh` (linha ~39)**
  ```sh
  PAPERMC_JAR_NAME=$LATEST_DOWNLOAD | jq -r 'split("/") | last'
  ```
  Isso não atualiza a variável (roda em subshell do pipe, o valor antigo é mantido). Hoje é inofensivo por coincidência de nomenclatura da API do PaperMC, mas é código morto e frágil.
  - Trocar por algo como `PAPERMC_JAR_NAME=$(basename "$LATEST_DOWNLOAD")`.

- [ ] **Adicionar `set -e` e validação de erros nos scripts**
  Se `curl`/`jq` falharem (rede, API fora do ar), os scripts seguem com valores quebrados (`null`, vazio) sem abortar.
  - `set -e` no topo de `download-server.sh` (hoje só `start-server.sh` tem).
  - Checar se `PAPERMC_VERSION` / `PAPERMC_BUILD` / `LATEST_DOWNLOAD` não estão vazios ou `"null"` antes de seguir, com `exit 1` e mensagem clara se estiverem.

- [ ] **Documentar/checar permissão do volume `/minecraft`**
  A imagem cria `/minecraft` com dono `minecraft` (uid 1000), mas o bind mount `./minecraft:/minecraft` do host pode ter outro dono (ex: criado como root pelo Docker). Isso quebra escrita silenciosamente.
  - Documentar no README que o host precisa ter `./minecraft` com uid/gid 1000 (ou ajustar `UID`/`GID` do build pra bater com o host).
  - Opcional: o entrypoint checar `[ -w /minecraft ]` no boot e falhar com mensagem clara se não tiver permissão, em vez de erro genérico do Java depois.

## 🟡 Melhorias menores

- [ ] **`restart: no` → `restart: unless-stopped`** no `docker-compose.yml`, pra sobreviver a reboot do host/crash.
- [ ] **Remover bind mount de `/etc/timezone` e `/etc/localtime`**
  Só funciona em host Linux (quebra no Windows, onde você desenvolve). O Dockerfile já fixa `America/Sao_Paulo` na imagem — os volumes são redundantes.
- [ ] **Parar de acumular linhas em `variaveis.env`**
  Cada boot faz `>>` (append) de `PAPERMC_JAR_NAME=...`. Funciona (última linha vence), mas o arquivo cresce pra sempre. Sobrescrever em vez de anexar, ou limpar antes.
- [ ] **Corrigir typo** "Vesão" → "Versão" em `entrypoint.sh`.
- [ ] **Padronizar shell**: hoje mistura bash-isms (`[[ ]]`, `source`) com `#!/bin/sh`. Funciona por causa do compat mode do BusyBox ash do Alpine, mas é frágil. Trocar pra `#!/bin/bash` (instalar `bash` no Dockerfile) ou reescrever em POSIX puro (`[ ]`, `.`).
- [ ] **Reduzir permissão de `/scripts`**: `chmod 777 -R` → `755` já basta (não precisa ser world-writable).
- [ ] **Adicionar `.idea/` ao `.gitignore`** (hoje aparece como untracked no `git status`).
- [ ] **Decidir o destino do submódulo `server_downloader`**
  Parece ser a reescrita em TS/Bun do `download-server.sh`, mas não está integrada ao Dockerfile/entrypoint e por padrão assume `vanilla` em vez de `paper`.
  - Opção A: terminar a migração — compilar binário (`bun build --compile`), copiar pra imagem, chamar do entrypoint, aposentar o script shell.
  - Opção B: manter só como ferramenta local/dev e deixar claro no README que não é usado em produção ainda.
- [ ] **Checksum do `.jar` baixado**: validar contra o hash exposto pela API do PaperMC antes de usar o arquivo.
- [ ] **Adicionar `shellcheck` (CI ou pre-commit)**: teria pego o bug do item de `download-server.sh` na hora.

## Ideias de conveniência (opcional)

- [ ] Adicionar targets no `Makefile`: `logs`, `shell` (attach no console do server), `restart`.
- [ ] Configurar RCON (env vars + porta) pra administração remota sem precisar de `docker attach`.
