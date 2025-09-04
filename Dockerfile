FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev || true
CMD ["node","-e","console.log('hello from demo image')"]
