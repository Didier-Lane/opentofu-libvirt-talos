# https://github.com/siderolabs/talos/releases/download/v1.12.5/talosctl-linux-amd64
TALOSCTL_REPOSITORY			:= siderolabs/talos
TALOSCTL_DIGEST				?= sha256:4c41a3b10b075292e64b182283d558e9d8e935f43239de1ed4e4b14359593efb
TALOSCTL_ASSET				:= talosctl-$(OS)-$(ARCH)
TALOSCTL_DOWNLOAD_URL		:= https://github.com/$(TALOSCTL_REPOSITORY)/releases/download/$(TALOS_VERSION)/$(TALOSCTL_ASSET)
TALOSCTL_BIN				:= $(BIN_DIR)/talosctl

$(TALOSCTL_BIN): $(BIN_DIR)
	if [[ ! -f "$(TALOSCTL_BIN)" ]] || [[ "$$( talosctl --version )" != "$(TALOSCTL_BIN)" ]]; then
		$(call release_install,TalosCTL,$(TALOS_VERSION),$(TALOSCTL_DOWNLOAD_URL),$(TALOSCTL_DIGEST),$(TALOSCTL_BIN))
	fi

.PHONY: talosctl
talosctl: $(TALOSCTL_BIN)
