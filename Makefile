APP = $(shell basename $(shell git remote get-url origin))
REGISTRY = ghcr.io/xvktn
VERSION = $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS ?= linux
TARGETARCH ?= arm64
IMAGETAG = ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

deps:
	go mod tidy && go mod download

get:
	go get

build: format deps get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o ${APP} -ldflags "-X="github.com/xvktn/kbot/cmd.appVersion=${VERSION}

image: build
	docker buildx build -t ${IMAGETAG} --load .

push:
	docker push ${IMAGETAG}

clean:
	rm -rf ${APP}
	docker rmi ${IMAGETAG} || true

linux:
	$(MAKE) build TARGETOS=linux TARGETARCH=amd64

windows:
	$(MAKE) build TARGETOS=windows TARGETARCH=amd64

macos:
	$(MAKE) build TARGETOS=darwin TARGETARCH=amd64

arm:
	$(MAKE) build TARGETOS=linux TARGETARCH=arm64