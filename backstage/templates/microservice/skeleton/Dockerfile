FROM node:24.21.0-bookworm-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --chown=node:node src ./src
COPY --chown=node:node certs ./certs
USER node
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "src/server.js"]
