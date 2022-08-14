run:
	docker-compose up -d
build:
	docker build -t syamsuldocker/messaging-websocket .
	docker image prune -f
push:
	docker push syamsuldocker/messaging-websocket