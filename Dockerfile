FROM node

WORKDIR /app

RUN apt update

COPY main.js .
COPY wait-for-it.sh .
RUN chmod +x wait-for-it.sh
COPY package.json .

RUN npm install

CMD ["node", "main.js"]