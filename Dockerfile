################################################################################
# Dockerfile used for building linux/alpine binary
# taken from https://github.com/anmonteiro/gh-feed-reader/blob/master/Dockerfile
################################################################################

# start from node image so we can install esy from npm
FROM node:12-alpine as build

ENV TERM=dumb LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

RUN mkdir /esy
WORKDIR /esy

ENV NPM_CONFIG_PREFIX=/esy
RUN npm install -g --unsafe-perm esy@latest

# now that we have esy installed we need a proper runtime

FROM alpine:3.8 as esy

ENV TERM=dumb LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

WORKDIR /

COPY --from=build /esy /esy

RUN apk add --no-cache ca-certificates wget bash curl perl-utils git patch \
  gcc g++ musl-dev make m4 linux-headers coreutils python

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk
RUN apk add --no-cache glibc-2.28-r0.apk

ENV PATH=/esy/bin:$PATH

ENTRYPOINT ["/bin/bash", "-c"]
