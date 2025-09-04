SERVICE ?= app
TAG ?= dev

parity:
	@echo "== Comparing image digests (ACR vs GHCR) =="
	crane digest $${ACR_NAME}.azurecr.io/$(SERVICE):$(TAG) > .acr.digest
	crane digest ghcr.io/$${GITHUB_OWNER}/$(SERVICE):$(TAG) > .ghcr.digest
	diff .acr.digest .ghcr.digest && echo "Digests match" || (echo "Digest mismatch"; exit 1)

demo-parity:
	@echo "== DEMO parity (fake matching digests) =="
	echo sha256:deadbeef > .acr.digest
	echo sha256:deadbeef > .ghcr.digest
	diff .acr.digest .ghcr.digest && echo "Digests match (demo)" || (echo "Digest mismatch"; exit 1)