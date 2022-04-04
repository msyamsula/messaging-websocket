make dev:
	node main.js

build:
	docker build -t syamsuldocker/messaging-websocket .

run:
	make build
	docker run -itd --name websocket --network=host syamsuldocker/messaging-websocket

ship:
	make build
	docker push syamsuldocker/messaging-websocket
	scp -i ~/syamsul.pem makefile ubuntu@ec2-18-142-64-31.ap-southeast-1.compute.amazonaws.com:~
	scp -i ~/syamsul.pem nginx/prod/nginx.conf ubuntu@ec2-18-142-64-31.ap-southeast-1.compute.amazonaws.com:~/prod

ssh:
	ssh -i ~/syamsul.pem ubuntu@ec2-18-142-64-31.ap-southeast-1.compute.amazonaws.com

stop:
	docker stop websocket
	docker rm websocket

nginx-start:
	docker run -itd --name nginx --network=host \
	-v ${CURDIR}/nginx/dev:/etc/nginx/conf.d \
	nginx

nginx-stop:
	docker stop nginx
	docker rm nginx

prod-run:
	docker pull syamsuldocker/messaging-websocket
	docker run -itd --name nginx --network=host \
	-v ${CURDIR}/prod:/etc/nginx/conf.d:ro \
	-v ${CURDIR}/certbot/www:/var/www/certbot/:ro \
	-v ${CURDIR}/certbot/conf:/etc/nginx/ssl/:ro \
	nginx
	docker run -itd --name websocket --network=host syamsuldocker/messaging-websocket

prod-stop:
	docker stop nginx websocket
	docker rm nginx websocket

prod-restart:
	make prod-stop
	make prod-run

# https tools
webserver-start:
	docker run -itd --name nginx --network=host \
	 -v ${CURDIR}/prod:/etc/nginx/conf.d/:ro \
	 -v ${CURDIR}/certbot/www:/var/www/certbot/:ro \
	 -v ${CURDIR}/certbot/conf:/etc/nginx/ssl/:ro \
	 nginx:latest
webserver-stop:
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
