FROM fedora:latest as builder

WORKDIR /app

COPY . .

RUN dnf -y update && dnf -y install wget tar git

RUN git submodule update --init --recursive

RUN wget https://github.com/gohugoio/hugo/releases/download/v0.155.3/hugo_extended_0.155.3_linux-amd64.tar.gz

RUN tar -xzf hugo_extended_0.155.3_linux-amd64.tar.gz

RUN mv hugo /usr/local/bin/

RUN rm hugo_extended_0.155.3_linux-amd64.tar.gz

RUN hugo

FROM docker.io/nginx:alpine

WORKDIR /usr/share/nginx/html

COPY --from=builder /app/public .

EXPOSE 80/tcp
