# syntax=docker/dockerfile:1

FROM alpine:3.22
RUN apk update
RUN apk add nginx
RUN addgroup -S appusers && adduser -S appuser1 -G appusers
USER appuser1
ENTRYPOINT ["nginx", "-g", "daemon off;"]
EXPOSE 8080