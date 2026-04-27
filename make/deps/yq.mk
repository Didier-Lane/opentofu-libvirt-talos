YQ_REPOSITORY	:= mikefarah/yq
YQ_VERSION		:= v4.53.2
YQ_DIGEST		:= sha256:d56bf5c6819e8e696340c312bd70f849dc1678a7cda9c2ad63eebd906371d56b
YQ_ASSET		:= yq_$(OS)_$(ARCH)
YQ_DOWNLOAD_URL	:= https://github.com/$(YQ_REPOSITORY)/releases/download/$(YQ_VERSION)/$(YQ_ASSET)
YQ_BIN			:= $(BIN_DIR)/yq

$(YQ_BIN): $(BIN_DIR)
	if [[ ! -f "$(YQ_BIN)" ]] || [[ "$$( yq --version | grep -Eo 'v([0-9\.]+)$$' )" != "$(YQ_VERSION)" ]]; then
		$(call release_install,YQ,$(YQ_VERSION),$(YQ_DOWNLOAD_URL),$(YQ_DIGEST),$(YQ_BIN))
	fi

.PHONY: yq
yq: $(YQ_BIN)

.PHONY: yq/check
yq/check: jq
	$(call github_check_release_version,$(YQ_REPOSITORY),$(YQ_VERSION),$(YQ_ASSET))
