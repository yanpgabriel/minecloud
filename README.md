# minecloud

Infraestrutura em Docker pro meu servidor de Minecraft (PaperMC), preparada pra rodar o **yCore** e a família de plugins dele.

Baseado no [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server), mas reescrito do zero, simplificado pro meu uso.

## Requisitos

- Docker + Docker Compose
- Git com suporte a submódulos (o `server_downloader` é um submódulo)

## Como rodar

```sh
git clone --recurse-submodules <url-do-repo>
# se já clonou sem o --recurse-submodules:
git submodule update --init --recursive
```

Os atalhos existem em duas versões equivalentes — `Makefile` (`make ...`) e `Justfile` (`just ...`) — use o que preferir, o que tiver instalado na hora:

```sh
make up      # ou: just up       — sobe o servidor em background
make deploy  # ou: just deploy   — rebuild da imagem + sobe
make down    # ou: just down     — para o servidor
make logs    # ou: just logs     — acompanha o console em tempo real
make shell   # ou: just shell    — anexa no console interativo (stop, save-all, op, etc.)
make restart # ou: just restart  — reinicia sem rebuildar
```

### Ambiente de staging

Serviço separado (`papermc-staging`), atrás de um profile do compose — não sobe junto com `up`. Usa porta `25566`, volume próprio (`./minecraft-staging`) e memória menor, pra testar builds novas do yCore sem arriscar o mundo principal:

```sh
make staging-up      # ou: just staging-up      — sobe o staging (porta 25566)
make staging-logs    # ou: just staging-logs    — acompanha o console do staging
make staging-shell   # ou: just staging-shell   — anexa no console do staging
make staging-down    # ou: just staging-down    — para o staging
```

### Publicar a imagem no Gitea

```sh
docker login gitea.oyan.dev   # uma vez, antes do primeiro publish
make publish                  # ou: just publish            — builda e publica :latest
make publish TAG=v1.2.3       # ou: just publish v1.2.3     — com uma tag específica
```

## Variáveis de ambiente

Definidas em `docker-compose.yml`, no serviço `papermc`:

| Variável               | Padrão    | Descrição |
|------------------------|-----------|-----------|
| `EULA`                 | `TRUE`    | Aceite da EULA do Minecraft. Precisa ser `TRUE` pro servidor subir. |
| `VERSION`               | `latest`  | Versão do Minecraft/Paper (ex: `1.21.4`). `latest` busca a mais recente suportada. |
| `BUILD`                 | `latest`  | Build do Paper pra essa versão. `latest` busca a build estável mais recente. |
| `PAPERMC_START_MEMORY`  | `1G`      | Heap inicial da JVM (`-Xms`). |
| `PAPERMC_MAX_MEMORY`    | `4G`      | Heap máximo da JVM (`-Xmx`). Ajustar conforme a RAM disponível no host. |
| `PAPERMC_JAVA_ARGS`     | *(vazio)* | Argumentos extras pra JVM (ex: flags de GC), passados antes do `-jar`. |

> ⚠️ `VERSION`/`BUILD` como `latest` atualiza o Paper a cada boot. Isso é conveniente pra testar, mas arriscado em produção rodando plugins customizados (o yCore e companhia) — uma build nova pode quebrar compatibilidade sem aviso. Fixe uma versão/build específica assim que a stack estiver estável.

> ⚠️ Se você mudar `PAPERMC_MAX_MEMORY`, ajuste também o `mem_limit` do serviço no `docker-compose.yml` — ele precisa ficar um pouco acima do heap máximo (a JVM usa memória nativa fora do heap: metaspace, threads, buffers do Netty). O padrão (`mem_limit: 5g` pra um heap de `4G`) segue essa margem de ~1G.

## Volumes

- `./minecraft:/minecraft` — tudo que precisa persistir: mundo, `plugins/`, jar do servidor, `eula.txt`, `server.properties`, etc.

O container roda como usuário não-root `minecraft` (uid/gid `1000` por padrão, configurável via os build args `UID`/`GID` no `docker-compose.yml`). Se a pasta `./minecraft` no host pertencer a outro usuário/uid, o servidor pode não conseguir escrever nela — ajuste o dono da pasta ou os build args pra baterem.

## Portas

- `25565/tcp` — porta padrão do Minecraft.

## Estrutura do projeto

```
Dockerfile              # imagem baseada em amazoncorretto:25-alpine (Java 25, exigido pelo Paper atual)
docker-compose.yml       # orquestração local (produção + staging)
Makefile / Justfile      # atalhos equivalentes (make ... / just ...) — use o que tiver instalado
scripts/
  entrypoint.sh           # ponto de entrada do container
  download-server.sh      # resolve versão/build e baixa o jar do Paper (fill.papermc.io)
  start-server.sh          # sobe o servidor (java como PID 1, heap configurável)
server_downloader/       # submódulo em TypeScript/Bun — experimento/ferramenta de dev
```

> `server_downloader` é uma reescrita experimental do `download-server.sh` em TypeScript/Bun. Não está integrada ao Dockerfile/entrypoint e **não é usada em produção** — é só uma ferramenta local, rodada manualmente (`bun run dev`) se quiser testar.

### Paths dentro do container

- `/minecraft` — diretório raiz do servidor (mundo, plugins, jar, `eula.txt`, `variaveis.env`). É o volume persistido.
- `/scripts` — scripts de bootstrap (`entrypoint.sh`, `download-server.sh`, `start-server.sh`).

## Roadmap / melhorias conhecidas

Acompanhado em [`MELHORIAS.md`](./MELHORIAS.md).
