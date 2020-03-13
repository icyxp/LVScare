FROM golang:1.12-alpine3.10 as go_builder

RUN apk add --no-cache git

ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn

COPY . /usr/local/go/src/github/LVScare

RUN \
    cd /usr/local/go/src/github/LVScare && \
    go install -a -v -ldflags="-w -s" ./ 

# final image
FROM icyboy/centos:7-mini

COPY --from=go_builder /go/bin/LVScare /usr/local/bin/lvscare

CMD ["lvscare"]
