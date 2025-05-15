APP = $(shell basename -s .git $(shell git remote get-url origin))
REGISTRY = ghcr.io/xvktn
VERSION = $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS ?= linux
TARGETARCH ?= arm64
IMAGETAG = ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

build:
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o ${APP} -ldflags "-X="github.com/xvktn/kbot/cmd.appVersion=${VERSION}

image:
	docker buildx build \
		--build-arg VERSION=$(VERSION) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg APP=$(APP) \
		-t $(IMAGETAG) \
		--load .

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