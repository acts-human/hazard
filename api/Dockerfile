FROM node:10.8.0-alpine

ADD . /usr/src/app
WORKDIR /usr/src/app
RUN npm install
EXPOSE 3000
CMD ["npm", "run", "start"]
