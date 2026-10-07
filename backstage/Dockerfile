FROM node:24.21.0-bookworm-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends python3 g++ make ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN corepack enable && yarn install --immutable
RUN yarn tsc && yarn build:backend
RUN mkdir -p /bundle && tar xzf packages/backend/dist/skeleton.tar.gz -C /bundle && tar xzf packages/backend/dist/bundle.tar.gz -C /bundle
FROM node:24.21.0-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends python3 g++ make ca-certificates && rm -rf /var/lib/apt/lists/* && corepack enable
WORKDIR /app
COPY --from=build --chown=node:node /bundle/ ./
COPY --from=build --chown=node:node /app/package.json /app/yarn.lock /app/.yarnrc.yml /app/backstage.json ./
COPY --from=build --chown=node:node /app/.yarn ./.yarn
RUN chown node:node /app
USER node
RUN yarn workspaces focus --all --production
COPY --chown=node:node app-config.yaml app-config.production.yaml ./
COPY --chown=node:node catalog ./catalog
COPY --chown=node:node templates ./templates
COPY --chown=node:node certs ./certs
ENV NODE_ENV=production
EXPOSE 7007
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
