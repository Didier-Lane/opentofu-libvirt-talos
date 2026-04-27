.PHONY: check
check: jq jq/check yq/check talosctl/check # 🔄 Checks for newer versions of dependencies
