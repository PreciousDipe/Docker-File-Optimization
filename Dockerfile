# ===========================================================================
# Stage 1: build
# ===========================================================================
FROM node:24.0.0-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm ci --ignore-scripts

COPY src ./src

RUN npm run build --if-present \
 && npm prune --omit=dev \
 && npm cache clean --force

# ===========================================================================
# Stage 2: runtime
# ===========================================================================
FROM node:24.0.0-alpine AS runtime

LABEL org.opencontainers.image.title="platform-dockerfile-optimization" \
      org.opencontainers.image.description="A hardened, minimal Node.js web application image" \
      org.opencontainers.image.source="https://github.com/PreciousDipe/Docker-File-Optimization"

RUN apk upgrade --no-cache \
 && rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/lib/node_modules/corepack \
           /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack \
           /usr/local/bin/yarn /usr/local/bin/yarnpkg /opt/yarn-* \
           /root/.npm /tmp/*

WORKDIR /app

ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=192" \
    UV_THREADPOOL_SIZE=4 \
    PORT=3000


COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src

USER node:node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["node", "src/healthcheck.js"]

STOPSIGNAL SIGTERM

# Exec form: node runs as PID 1 and receives SIGTERM directly (no shell in between).
CMD ["node", "src/server.js"]
