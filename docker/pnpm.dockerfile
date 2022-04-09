FROM node:14-alpine

RUN apk add --no-cache git tini
RUN npm i -g pnpm@6.32.3

ENTRYPOINT ["/sbin/tini", "--"]
