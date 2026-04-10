# Multi-stage build
FROM node:18-alpine AS builder

WORKDIR /app

# Cache bust: ensure package-lock.json is included
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# Production image
FROM node:18-alpine

WORKDIR /app

# Copy build artifacts
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Non-root user
USER node

EXPOSE 8080

CMD ["node", "dist/index.js"]
