DEPENDENCIES = github yq talosctl

define CLEAN_COMMAND
rm -rf $(TALOS_CONFIG_DIR) terraform.tfvars .env
endef

include make/base/Makefile
