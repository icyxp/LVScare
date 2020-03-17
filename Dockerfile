FROM golang:1.13.8-alpine3.10 as go_builder

RUN apk add --no-cache git

ENV CGO_ENABLED=0
ENV GOPROXY=https://goproxy.cn

COPY . /go/src/github/LVScare

RUN \
    cd /go/src/github/LVScare && \
    go install -a -v -ldflags="-w -s" ./ 

# final image
FROM icyboy/centos:7-mini

COPY --from=go_builder /go/bin/LVScare /usr/bin/lvscare

CMD ["lvscare"]
