JQ_REPOSITORY	:= jqlang/jq
JQ_VERSION		:= jq-1.8.2
JQ_DIGEST		:= sha256:b1c22172dd303f3be49e935aa56aa48a8b7a46e0bc838b4997d3bb451495870f
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
