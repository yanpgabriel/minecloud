down:
	docker compose down
up:
	docker compose up -d
deploy:
	docker compose down
	docker compose up --build -d
