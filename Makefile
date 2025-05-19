APP = $(shell basename -s .git $(shell git remote get-url origin))
REGISTRY = ghcr.io/xvktn
VERSION = $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS ?= linux
TARGETARCH ?= arm64
IMAGETAG = ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

image:
	DOCKER_BUILDKIT=0 docker buildx build \
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
	$(MAKE) image TARGETOS=linux TARGETARCH=amd64

windows:
	$(MAKE) image TARGETOS=windows TARGETARCH=amd64

macos:
	$(MAKE) image TARGETOS=darwin TARGETARCH=amd64

arm:
	$(MAKE) image TARGETOS=linux TARGETARCH=arm64