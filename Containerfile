FROM fedora:latest as builder

WORKDIR /app

COPY . .

RUN dnf -y update && dnf -y install hugo

RUN hugo --gc --minify

FROM docker.io/nginx:alpine

WORKDIR /usr/share/nginx/html

COPY --from=builder /app/public .

EXPOSE 80/tcp
