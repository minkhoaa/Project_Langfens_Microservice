FROM node:24-bookworm-slim AS build
WORKDIR /app
COPY . .
RUN npm ci --ignore-scripts \
    && npm run build:offline \
    && npm run check \
    && npm prune --omit=dev --ignore-scripts

FROM node:24-bookworm-slim
ENV NODE_ENV=production \
    LANGFENS_HARNESS_RUNTIME_DIR=/var/lib/langfens-harness
WORKDIR /app
COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/packages ./packages
COPY --from=build /app/scripts ./scripts
RUN mkdir -p /var/lib/langfens-harness && chown node:node /var/lib/langfens-harness
USER node
ENTRYPOINT ["node", "/app/scripts/run.mjs"]
CMD ["--mode", "rpc", "--no-session"]
