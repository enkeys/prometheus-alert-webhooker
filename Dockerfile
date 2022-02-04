FROM golang:1.17.6-alpine3.15 as builder
RUN apk add --no-cache make tzdata curl gcc libc-dev
WORKDIR /app
COPY . .
RUN \
    go test ./... && \
    cd cmd/prometheus-alert-webhooker && \
    CGO_ENABLED=0 GOOS=linux go build -v -a -installsuffix cgo -o prometheus-alert-webhooker

FROM alpine:3.15.0
RUN apk add --no-cache ca-certificates tzdata curl
COPY --from=builder /app/cmd/prometheus-alert-webhooker/prometheus-alert-webhooker /usr/bin/
EXPOSE 8080
ENTRYPOINT ["/usr/bin/prometheus-alert-webhooker"]
