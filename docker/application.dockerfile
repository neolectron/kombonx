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
ARG PROJECT
ARG PROJECT_PATH

COPY --from=development-dependencies /app /app

COPY ${PROJECT_PATH}${PROJECT} ${PROJECT_PATH}${PROJECT}
COPY ./libs ./libs
COPY nx.json tsconfig.base.json ./

RUN pnpm build ${PROJECT} -- --configuration production

###############################################################################################
FROM pnpm as production-dependencies
###############################################################################################

WORKDIR /app
ARG PROJECT
ARG PROJECT_PATH

COPY --from=build /app/dist/${PROJECT_PATH}${PROJECT}/package.json ./

RUN pnpm install --production --unsafe-perm

###############################################################################################
FROM mhart/alpine-node:slim-14 as application
###############################################################################################

WORKDIR /app
ARG PROJECT
ARG PROJECT_PATH

RUN apk add --no-cache tini

RUN adduser -HD node

COPY --from=build --chown=node /app/dist/${PROJECT_PATH}${PROJECT} ./
COPY --from=production-dependencies --chown=node /app/node_modules ./node_modules

USER node

ENTRYPOINT ["tini", "--"]
