FROM quay.io/projectquay/golang:1.22 AS builder

ARG VERSION
ARG TARGETOS
ARG TARGETARCH
ARG APP

WORKDIR /go/src/app
COPY . .
RUN yum install -y make
RUN go mod tidy && go mod download
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o ${APP} -ldflags "-X=github.com/xvktn/kbot/cmd.appVersion=${VERSION}"

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENTRYPOINT ["./kbot"]