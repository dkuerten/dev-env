IMAGE := dkdev/dev-env
TAG   := $(shell date +%Y%m%d)

.PHONY: build pull push tag-latest

build:
	docker build -t $(IMAGE):latest -t $(IMAGE):$(TAG) .

pull:
	docker pull $(IMAGE):latest

push:
	docker push $(IMAGE):latest
	docker push $(IMAGE):$(TAG)

tag-latest:
	docker tag $(IMAGE):$(TAG) $(IMAGE):latest
