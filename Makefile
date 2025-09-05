SERVICE ?= demo-app
TAG ?= dev
REGISTRY ?= ghcr.io
OWNER ?= $(shell git config user.name | tr "[:upper:]" "[:lower:]" | tr " " "-")

.PHONY: build push test lint deploy-local clean

# Build container locally
build:
	docker build -t $(REGISTRY)/$(OWNER)/$(SERVICE):$(TAG) .

# Push to GHCR (requires: echo $$GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin)
push: build
	docker push $(REGISTRY)/$(OWNER)/$(SERVICE):$(TAG)

# Run tests
test:
	npm test

# Lint workflows
lint:
	yamllint .github/workflows/

# Deploy locally with Helm (dry-run)
deploy-local:
	helm upgrade --install $(SERVICE) deploy/chart \
	  --set image.repository=$(REGISTRY)/$(OWNER)/$(SERVICE) \
	  --set image.tag=$(TAG) \
	  --set env.name=local \
	  --dry-run --debug

# Clean up local images
clean:
	docker rmi $(REGISTRY)/$(OWNER)/$(SERVICE):$(TAG) || true

# Show current config
info:
	@echo "Service: $(SERVICE)"
	@echo "Tag: $(TAG)"
	@echo "Registry: $(REGISTRY)"
	@echo "Owner: $(OWNER)"
	@echo "Full image: $(REGISTRY)/$(OWNER)/$(SERVICE):$(TAG)"
