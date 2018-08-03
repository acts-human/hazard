FROM node:10.8.0-alpine

ADD . /usr/src/app
WORKDIR /usr/src/app
RUN ls -a
RUN npm install
CMD ["npm", "run", "start"]
