#cluster
stop:
	docker-compose -f env/dev/docker-compose.yaml down

ps:
	docker-compose -f env/dev/docker-compose.yaml ps

build:
	docker build \
	-t syamsuldocker/messaging-websocket \
	-f ${CURDIR}/env/dev/Dockerfile \
	.
	docker build \
	-t syamsuldocker/nginx-websocket \
	-f ${CURDIR}/env/dev/Dockerfile.nginx \
	.

run:
	make build
	docker-compose -f env/dev/docker-compose.yaml up --scale websocket=${scale} -d

# local
run-local:
	node -r dotenv/config main.js dotenv_config_path=${CURDIR}/env/dev/.env


# ship production
ship-production:
	docker build \
	-t syamsuldocker/messaging-websocket \
	-f env/prod/Dockerfile \
	.
	docker build \
	-t syamsuldocker/nginx-websocket \
	-f env/prod/Dockerfile.nginx \
	.
	docker push syamsuldocker/messaging-websocket
	docker push syamsuldocker/nginx-websocket
	scp -i ~/syamsul.pem makefile ubuntu@ec2-18-142-64-31.ap-southeast-1.compute.amazonaws.com:~
	scp -i ~/syamsul.pem env/prod/docker-compose.yaml ubuntu@ec2-18-142-64-31.ap-southeast-1.compute.amazonaws.com:~/

# production
run-production:
	docker pull syamsuldocker/messaging-websocket 
	docker pull syamsuldocker/nginx-websocket 
	docker pull redis
	docker-compose up -d --scale websocket=${scale}

stop-production:
	docker-compose down

# ssh
ssh:
	ssh -i ~/syamsul.pem ubuntu@ec2-18-142-64-31.ap-southeast-1.compute.amazonaws.com

# https tools
start-webserver:
	docker run -itd --name nginx --network=host \
	 -v ${CURDIR}/prod:/etc/nginx/conf.d/:ro \
	 -v ${CURDIR}/certbot/www:/var/www/certbot/:ro \
	 -v ${CURDIR}/certbot/conf:/etc/nginx/ssl/:ro \
	 nginx:latest
stop-webserver:
	docker stop nginx
	docker rm nginx
certbot-dry-run:
	docker run -it --name certbot --network=host \
	-v ${CURDIR}/certbot/www:/var/www/certbot/:rw \
	-v ${CURDIR}/certbot/conf:/etc/letsencrypt/:rw \
	certbot/certbot:latest certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d syamsulwebsocket.xyz
certbot-create:
	docker run -it --name certbot --network=host \
	-v ${CURDIR}/certbot/www:/var/www/certbot/:rw \
	-v ${CURDIR}/certbot/conf:/etc/letsencrypt/:rw \
	certbot/certbot:latest certonly --webroot --webroot-path /var/www/certbot/ -d syamsulwebsocket.xyz
certbot-stop:
	docker stop certbot
	docker rm certbot
certbot-renew:
	docker run -it --name certbot --network=host \
	-v ${CURDIR}/certbot/www:/var/www/certbot/:rw \
	-v ${CURDIR}/certbot/conf:/etc/letsencrypt/:rw \
	certbot/certbot:latest renew
