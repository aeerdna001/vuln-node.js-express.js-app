# Use an Alpine image with Node.js
FROM node:18-alpine as builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    python3 \
    && ln -sf python3 /usr/bin/python \
    && npm install -g node-gyp

RUN mkdir -p /build

COPY ./package.json ./package-lock.json /build/
WORKDIR /build
RUN npm ci

COPY . /build

FROM node:18-alpine

RUN apk add --no-cache \
    libxml2-dev \
    build-base \
    python3

ENV user=node
USER $user

RUN mkdir -p /home/$user/src
WORKDIR /home/$user/src

COPY --from=builder /build ./

COPY ./db/db.sqlite /home/$user/src/db/db.sqlite
COPY ./.env /home/$user/src/.env

RUN chown -R $user:$user /home/$user/src

RUN npm rebuild

EXPOSE 8081

ENV NODE_ENV=development

CMD ["npm", "start"]
