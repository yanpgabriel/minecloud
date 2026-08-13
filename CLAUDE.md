# Contexto do projeto

Infra containerizada pro servidor PaperMC. Reimplementação enxuta do `itzg/docker-minecraft-server`.

## Como o container funciona

`/minecraft` é ao mesmo tempo `HOME`, `WORKDIR` e o volume montado (`./minecraft` no host, `./minecraft-staging` no perfil de staging). Tudo que o servidor escreve — mundo, `plugins/`, `server.properties`, `eula.txt`, o jar do Paper — mora ali e sobrevive a recriação do container.

A cadeia de start é `entrypoint.sh` → `download-server.sh` → `start-server.sh`:

- `download-server.sh` resolve versão e build pela API `fill.papermc.io`, valida sha256, apaga jars antigos e grava `PAPERMC_JAR_NAME` em `/minecraft/variaveis.env`.
- `start-server.sh` lê esse arquivo, escreve `eula.txt` e faz `exec java`, pra JVM virar PID 1 e receber o SIGTERM do `docker stop` direto — é isso que garante o save do mundo no shutdown.

`VERSION` está pinado em `26.2` no compose de propósito, pra não subir de versão do Minecraft sozinho. `BUILD: latest` continua pegando a última build estável dessa versão a cada start.

## O que os plugins esperam desta infra

Os plugins instalados vão pra `./minecraft/plugins/`, hoje enviados por scp. Trocar jar **exige restart** — não existe reload de plugin.

Dois comportamentos já verificados que dependem de como o container está montado:

- **O restore de backup conta com o restart automático.** O plugin grava um marcador, derruba a JVM de propósito, e a restauração roda no boot seguinte, antes de carregar mundo. Funciona porque o `x-papermc-base` tem `restart: unless-stopped`. **Remover isso quebra o restore silenciosamente** — o servidor só não volta.
- **Os backups caem em `/minecraft/backups`**, porque o plugin grava em caminho relativo ao working directory. Estão dentro do volume, mas **no mesmo disco do mundo** — não são cópia off-site.

## Buracos conhecidos

- **Sem RCON.** Rodar comando no servidor exige `make shell`, que é `docker attach`.
- **Deploy de plugin é manual** e não tem alvo de Makefile aqui.
- **Config de plugin e do servidor é editada à mão** dentro do volume. Não há overlay versionado, então `server.properties`, `paper-global.yml` e config de plugin de terceiro não têm histórico nem revert.

## Armadilhas

- **`make shell` é `docker attach`: Ctrl-C derruba o servidor.** O sinal vai direto pra JVM, que é PID 1. Pra sair sem matar, use **Ctrl-P Ctrl-Q**.
- **`COPY ../scripts/*.sh` no Dockerfile funciona por acidente feliz.** O Docker normaliza o `..` travando na raiz do contexto, então vira `scripts/*.sh`. Continua confuso e frágil — se for mexer, troque por `COPY scripts/*.sh`.
- `./minecraft` e `./minecraft-staging` estão no `.gitignore` e no `.dockerignore`. Qualquer arquivo de configuração que deva ser versionado precisa morar **fora** dessas pastas.
- O staging usa volume e imagem separados (`:staging`, porta 25566), mas a mesma versão de Paper. É o lugar certo pra validar jar novo antes da produção — hoje subutilizado.

## Como trabalhar aqui

- Português no código, na documentação e nas mensagens.
- **Sem comentários no código.** Se precisa explicar, o nome ou a estrutura resolvem.
- Apresente o plano e espere aprovação antes de implementar.
- Mudança de infra é testada no perfil de staging antes da produção.
