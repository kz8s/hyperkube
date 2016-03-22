REGISTRY?="kz8s"
VERSION?="v1.2.0"

build:
	docker build -t ${REGISTRY}/hyperkube:${VERSION} .

.PHONY: build
