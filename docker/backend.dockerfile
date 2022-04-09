###############################################################################################
FROM node:14-alpine as pnpm
###############################################################################################

RUN npm i -g pnpm@6.32.3

###############################################################################################
FROM pnpm as development-dependencies
###############################################################################################

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --unsafe-perm --frozen-lockfile

###############################################################################################
FROM pnpm as build
###############################################################################################

WORKDIR /app

COPY --from=development-dependencies /app /app

COPY ./apps ./apps
COPY ./libs ./libs
COPY nx.json tsconfig.base.json ./

RUN pnpm build api -- --configuration production

###############################################################################################
FROM pnpm as production-dependencies
###############################################################################################

WORKDIR /app

COPY --from=build /app/dist/apps/api/package.json ./

RUN pnpm install --production --unsafe-perm

###############################################################################################
FROM mhart/alpine-node:slim-14 as application
###############################################################################################

WORKDIR /app

RUN apk add --no-cache tini

RUN adduser -HD node

COPY --from=build --chown=node /app/dist/apps/api ./
COPY --from=production-dependencies --chown=node /app/node_modules ./node_modules

USER node

ENTRYPOINT ["tini", "--"]
CMD node --enable-source-maps main.js
