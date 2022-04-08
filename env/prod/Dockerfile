FROM node

WORKDIR /app

COPY . .

CMD [ "node", "-r", "dotenv/config", "main.js", "dotenv_config_path=env/prod/.env" ]