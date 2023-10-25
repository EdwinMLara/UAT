FROM node:12

RUN mkdir -p /home/app

COPY . /home/app
WORKDIR /home/app
RUN npm install

EXPOSE 3000

CMD ["node", "/home/app/index.js"]