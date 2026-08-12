-include .env
export

REGISTRY_IMAGE ?= gitea.oyan.dev/yan/minecloud
TAG ?= latest
PLATFORMS ?= linux/amd64,linux/arm64/v8

.PHONY: down up deploy logs shell restart publish staging-up staging-down staging-logs staging-shell

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
	docker attach $$(docker compose ps -q papermc)
restart:
	docker compose restart

publish:
	docker buildx build --platform $(PLATFORMS) -t $(REGISTRY_IMAGE):$(TAG) --push .

staging-up:
	docker compose --profile staging up -d papermc-staging
staging-down:
	docker compose --profile staging down papermc-staging
staging-logs:
	docker compose logs -f papermc-staging
staging-shell:
	docker attach $$(docker compose ps -q papermc-staging)
