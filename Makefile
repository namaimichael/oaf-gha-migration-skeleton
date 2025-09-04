SERVICE ?= app
TAG ?= dev
parity:
	crane digest $${ACR_NAME}.azurecr.io/$(SERVICE):$(TAG) > .acr.digest
	crane digest ghcr.io/$${GITHUB_OWNER}/$(SERVICE):$(TAG) > .ghcr.digest
	diff .acr.digest .ghcr.digest && echo "Digests match " || (echo "Digest mismatch "; exit 1)
