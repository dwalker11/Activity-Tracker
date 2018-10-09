FROM node:carbon
ADD ./app /code
WORKDIR /code
RUN npm install
CMD ["npm", "start"]
