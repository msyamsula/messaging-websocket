FROM node

WORKDIR /app

COPY . .

CMD [ "node", "main.js" ]