# https://github.com/siderolabs/talos/releases/download/v1.12.5/talosctl-linux-amd64
TALOSCTL_REPOSITORY			:= siderolabs/talos
TALOSCTL_DIGEST				?= sha256:97d08e5584e56114659f131e95e227910d1f3b427d26360dca2af3ed821b71f8
TALOSCTL_ASSET				:= talosctl-$(OS)-$(ARCH)
TALOSCTL_DOWNLOAD_URL		:= https://github.com/$(TALOSCTL_REPOSITORY)/releases/download/$(TALOS_VERSION)/$(TALOSCTL_ASSET)
TALOSCTL_BIN				:= $(BIN_DIR)/talosctl

define get_talosctl_version
talosctl version --client --short | tail -n 1 | grep -Eo 'v[0-9.]+$$'
endef

$(TALOSCTL_BIN): $(BIN_DIR)
	if [[ ! -f "$(TALOSCTL_BIN)" ]] || [[ "$$( $(get_talosctl_version) )" != "$(TALOS_VERSION)" ]]; then
		$(call release_install,TalosCTL,$(TALOS_VERSION),$(TALOSCTL_DOWNLOAD_URL),$(TALOSCTL_DIGEST),$(TALOSCTL_BIN))
	fi

.PHONY: talosctl
talosctl: $(TALOSCTL_BIN)

.PHONY: talosctl/check
talosctl/check:
	$(call github_check_release_version,$(TALOSCTL_REPOSITORY),$(TALOS_VERSION),$(TALOSCTL_ASSET))
