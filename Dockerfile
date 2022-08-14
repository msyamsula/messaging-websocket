FROM node

WORKDIR /app

RUN apt update

COPY main.js .
# COPY wait-for-it.sh .
# RUN chmod +x wait-for-it.sh
COPY package.json .

RUN npm install
RUN npm install -g npm@8.17.0

CMD ["node", "main.js"]