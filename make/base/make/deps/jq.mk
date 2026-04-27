JQ_REPOSITORY	:= jqlang/jq
JQ_VERSION		:= jq-1.8.1
JQ_DIGEST		:= sha256:020468de7539ce70ef1bceaf7cde2e8c4f2ca6c3afb84642aabc5c97d9fc2a0d
JQ_ASSET		:= jq-$(OS)-$(ARCH)
JQ_DOWNLOAD_URL	:= https://github.com/$(JQ_REPOSITORY)/releases/download/$(JQ_VERSION)/$(JQ_ASSET)
JQ_BIN			:= $(BIN_DIR)/jq

$(JQ_BIN): $(BIN_DIR)
	if [[ ! -f "$(JQ_BIN)" ]] || [[ "$$( jq --version )" != "$(JQ_VERSION)" ]]; then
		$(call release_install,JQ,$(JQ_VERSION),$(JQ_DOWNLOAD_URL),$(JQ_DIGEST),$(JQ_BIN))
	fi

.PHONY: jq
jq: $(JQ_BIN)

.PHONY: jq/check
jq/check: jq
	$(call github_check_release_version,$(JQ_REPOSITORY),$(JQ_VERSION),$(JQ_ASSET))
