.PHONY: check
check: jq jq/check yq/check talosctl/check # 🔄 Checks for newer versions of dependencies
	$(call github_check_release_version,kubernetes/kubernetes,v$(KUBERNETES_VERSION))
