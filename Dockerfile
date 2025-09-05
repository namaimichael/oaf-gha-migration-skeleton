FROM node:18-alpine AS base
LABEL org.opencontainers.image.source=https://github.com/namaimichael/oaf-gha-migration-skeleton

WORKDIR /app

FROM base AS deps
COPY package*.json ./
RUN npm ci --omit=dev --frozen-lockfile && npm cache clean --force

FROM base AS runtime
COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./
COPY . .

EXPOSE 3000
USER node

CMD ["npm", "start"]
