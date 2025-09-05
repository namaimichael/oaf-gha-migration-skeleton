FROM node:18-alpine
LABEL org.opencontainers.image.source=https://github.com/namaimichael/oaf-gha-migration-skeleton

WORKDIR /app
COPY package*.json ./
COPY . .

EXPOSE 3000
USER node

CMD ["npm", "start"]
