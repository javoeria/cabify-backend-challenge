FROM alpine:latest

# This Dockerfile is optimized for go binaries, change it as much as necessary
# for your language of choice.

RUN apk --no-cache add ca-certificates libc6-compat

EXPOSE 9091

COPY car-pooling-challenge /

ENTRYPOINT [ "/car-pooling-challenge" ]
