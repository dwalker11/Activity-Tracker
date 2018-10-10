FROM node:carbon
ADD ./app /code
WORKDIR /code
RUN npm install
RUN npm run build
CMD ["npm", "start"]
