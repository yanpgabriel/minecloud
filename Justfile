set dotenv-load := true
set dotenv-filename := ".env"

registry_image := env_var_or_default("REGISTRY_IMAGE", "gitea.oyan.dev/yan/minecloud")
platforms := env_var_or_default("PLATFORMS", "linux/amd64,linux/arm64/v8")

default:
    @just --list

down:
    docker compose down

up:
    docker compose up -d

deploy:
    docker compose down
    docker compose up --build -d

logs:
    docker compose logs -f papermc

shell:
    docker attach $(docker compose ps -q papermc)

restart:
    docker compose restart

publish tag="latest":
    docker buildx build --platform {{ platforms }} -t {{ registry_image }}:{{ tag }} --push .

staging-up:
    docker compose --profile staging up -d papermc-staging

staging-down:
    docker compose --profile staging down papermc-staging

staging-logs:
    docker compose logs -f papermc-staging

staging-shell:
    docker attach $(docker compose ps -q papermc-staging)
