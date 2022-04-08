# local
run-local:
	node -r dotenv/config main.js dotenv_config_path=${CURDIR}/env/dev/.env

# docker
build-docker-local:
	docker build \
	-t syamsuldocker/messaging-websocket \
	-f ${CURDIR}/env/dev/Dockerfile \
	.

run-docker-local:
	make build-docker-local
	docker run \
	-itd \
	--rm \
	--name messaging-websocket \
	--network=host \
	syamsuldocker/messaging-websocket
	docker logs -f messaging-websocket

stop-docker-local:
	docker stop messaging-websocket

# ship production
ship-production:
	docker build \
	-t syamsuldocker/messaging-websocket \
	-f env/prod/Dockerfile \
	.
	docker push syamsuldocker/messaging-websocket
	scp -i ~/syamsul.pem makefile ubuntu@ec2-18-142-64-31.ap-southeast-1.compute.amazonaws.com:~
	scp -i ~/syamsul.pem env/prod/default.conf ubuntu@ec2-18-142-64-31.ap-southeast-1.compute.amazonaws.com:~/nginx

# production
run-production:
	docker pull syamsuldocker/messaging-websocket
	docker run \
	-itd \
	--name nginx \
	--network=host \
	-v ${CURDIR}/nginx/:/etc/nginx/conf.d/ \
	-v ${CURDIR}/certbot/www/:/var/www/certbot/ \
	-v ${CURDIR}/certbot/config:/etc/nginx/ssl \
	nginx
	docker run \
	-itd \
	--name messaging-websocket \
	--network=host \
	syamsuldocker/messaging-websocket

stop-production:
	docker stop nginx messaging-websocket
	docker rm nginx messaging-websocket

restart-production:
	make run-production
	make stop-production

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
