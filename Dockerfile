FROM golang:1.12.6 AS builder

RUN mkdir -p /workspace/github.com/uber/makisu
WORKDIR /workspace/github.com/uber/makisu

ADD Makefile .
ADD go.mod ./go.mod
ADD go.sum ./go.sum
RUN make vendor
ADD .git ./.git
ADD bin ./bin
ADD lib ./lib
RUN make lbins

FROM alpine:3.12.0
RUN apk add --no-cache libc6-compat curl iftop tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
    
COPY --from=builder /workspace/github.com/uber/makisu/bin/makisu/makisu.linux /makisu-internal/makisu
ADD ./assets/cacerts.pem /makisu-internal/certs/cacerts.pem

ENTRYPOINT ["/makisu-internal/makisu"]