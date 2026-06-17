# syntax=docker/dockerfile:1

# ---- Builder ----
# Builds the SvelteKit app with adapter-node. This stage pulls in the full
# dependency tree (incl. the ~1.8GB `pokemon-sprites` GitHub dep, which the
# build inlines into `build/` as base64), so it never ships in the final image.
FROM node:20-alpine AS builder
WORKDIR /app

# `pokemon-sprites` is a GitHub dependency, so git is required to install it.
RUN apk add --no-cache git

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Sprite base64 inlining is memory-hungry; give Node some headroom.
ENV NODE_OPTIONS=--max-old-space-size=4096
RUN npm run build

# Drop dev dependencies (incl. the build-only pokemon-sprites) so only the
# production deps the server bundle imports at runtime remain.
RUN npm prune --omit=dev

# ---- Runner ----
# adapter-node externalizes node_modules deps, so the runtime image needs the
# build output plus the pruned production dependencies.
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["node", "build"]
