# Melhorias do minecloud

Checklist de ações levantadas na análise do projeto (2026-08-11). Conforme um item for feito (e validado), ele sai daqui — o histórico de por que/como fica no commit correspondente. Ordenado por prioridade dentro de cada bloco.

✅ Já resolvido (bloco 🔴 Crítico inteiro): Java rodando como PID 1 (`exec` em `start-server.sh`), `stop_grace_period: 60s`, heap da JVM configurado via env vars, e a imagem base trocada pra `amazoncorretto:25-alpine` (o `latest` do Paper exige Java 25+, o Java 21 antigo nem subia).

## 🟠 Importante

✅ Já resolvido: bug de atribuição do `PAPERMC_JAR_NAME` em `download-server.sh` (trocado por `basename`), `set -e` + validação de `null`/vazio nas respostas de `curl`/`jq` (com mensagem clara e `exit 1` em vez de seguir com estado quebrado), e checagem de permissão de escrita em `/minecraft` no `entrypoint.sh`. Validado com build real: fluxo feliz (`latest`/`latest`, jar nomeado corretamente) e fluxo de erro (build inexistente aborta com mensagem clara, exit code 1).

- [ ] **Pinar versão do Paper depois de estabilizar com o yCore**
  `VERSION=latest`/`BUILD=latest` atualiza o Paper a cada boot, o que pode quebrar compatibilidade de plugin sem aviso. Deixar `latest` só pra ambiente de teste; em produção fixar `VERSION`/`BUILD` explícitos no `docker-compose.yml`. (Ainda pendente — só faz sentido depois que o yCore estiver rodando de forma estável nessa stack.)

## 🟡 Melhorias menores

- [ ] **`restart: no` → `restart: unless-stopped`** no `docker-compose.yml`, pra sobreviver a reboot do host/crash.
- [ ] **Remover bind mount de `/etc/timezone` e `/etc/localtime`**
  Só funciona em host Linux (quebra no Windows, onde você desenvolve). O Dockerfile já fixa `America/Sao_Paulo` na imagem — os volumes são redundantes.
- [ ] **Parar de acumular linhas em `variaveis.env`**
  Cada boot faz `>>` (append) de `PAPERMC_JAR_NAME=...`. Funciona (última linha vence), mas o arquivo cresce pra sempre. Sobrescrever em vez de anexar, ou limpar antes.
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
