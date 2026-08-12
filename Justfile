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
    docker build -t gitea.oyan.dev/yan/minecloud:{{ tag }} .
    docker push gitea.oyan.dev/yan/minecloud:{{ tag }}

staging-up:
    docker compose --profile staging up -d papermc-staging

staging-down:
    docker compose --profile staging down papermc-staging

staging-logs:
    docker compose logs -f papermc-staging

staging-shell:
    docker attach $(docker compose ps -q papermc-staging)
