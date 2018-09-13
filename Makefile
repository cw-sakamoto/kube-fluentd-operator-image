IMAGE ?= cwsakamoto/kube-fluentd-operator
FLUENT_VERSION ?= v1.2.5
OP_VERSION ?= master
TAG ?= $(FLUENT_VERSION)-$(OP_VERSION)

.PHONY: build-image
build-image: clone
	docker build -t $(IMAGE):$(TAG)\
		--build-arg FLUENT_VERSION=$(FLUENT_VERSION) .

.PHONY: push-image
push-image: build-image
	docker push $(IMAGE):$(TAG)

.PHONY: clone
clone: clean
	git clone --depth=1 -b $(OP_VERSION) https://github.com/vmware/kube-fluentd-operator.git

.PHONY: clean
clean:
	/bin/rm -fr kube-fluentd-operator

.PHONY: shell
shell:
	docker run --entrypoint=/bin/bash \
	  -ti --rm -v `pwd`:/workspace --net=host \
	  $(IMAGE):$(TAG)

.PHONY: run-fluentd
run-fluentd:
	docker run --entrypoint=fluentd \
	  -ti --rm -v `pwd`:/workspace --net=host \
	  $(IMAGE):$(TAG) \
	  -p /fluentd/plugins -v -c /workspace/local-fluent.conf

.PHONY: validate-config
validate-config:
	docker run --entrypoint=fluentd \
	  -ti --rm -v `pwd`:/workspace --net=host \
	  $(IMAGE):$(TAG) \
	  --dry-run -p /fluentd/plugins -v -c /workspace/tmp/fluent.conf
