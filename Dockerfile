ARG REPO=887308979175.dkr.ecr.us-east-1.amazonaws.com
FROM ${REPO}/node:12.0.0-alpine

WORKDIR /usr/src/app

COPY package*.json ./
ENV NODE_ENV=production
RUN npm install
COPY . .

EXPOSE 8080
CMD ["node", "app.js"]
