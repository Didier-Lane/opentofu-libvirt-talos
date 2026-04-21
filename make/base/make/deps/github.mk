define github_check_release_version
cache="$$( mktemp )"
result="$$( curl -sSL https://api.github.com/repos/$(1)/releases/latest > "$${cache}" )"
latest="$$( jq -r '.tag_name' < "$${cache}" )"
if [[ "$${latest}" == "$(2)" ]]; then
	$(call message,✅,Repository $(hl)$(1)$(rs) is up to date with latest version $(hl)$${latest}$(rs))
else
	$(call message,💡,Repository $(hl)$(1)$(rs) new version is $(hl)$${latest}$(rs))
	if [ ! -z "$(3)" ]; then
		for asset in $(3); do
			digest="$$( jq -r '.assets[] | select(.name == "'"$${asset}"'") | .digest' < "$${cache}" )"
			$(call message,📦,Asset $(hl)$${asset}$(rs) digest is $(hl)$${digest}$(rs))
		done
	fi
fi
rm "$${cache}"
endef

ifdef GITHUB_TOKEN

define github_auth
--header "Authorization: Bearer $(GITHUB_TOKEN)"
endef

define github_check_package_version
cache="$$( mktemp )"
url="https://api.github.com/orgs/$(1)/packages/container/$(2)/versions"
result="$$( curl -sSL $(github_auth) "$$url" > "$${cache}" )"
tag="$$( jq -r '.[] | select(.metadata.container.tags[] | contains("latest")) | .metadata.container.tags[0]' < "$${cache}" )"
if [[ "$${tag}" == "$(3)" ]]; then
	$(call message,✅,Package $(hl)$(1)/$(2)$(rs) is up to date with latest tag $(hl)$${tag}$(rs))
else
	digest="$$( jq -r '.[] | select(.metadata.container.tags[] | contains("latest")) | .name' < "$${cache}" )"
	$(call message,💡,New tag is $(hl)$${tag}$(rs) with digest $(hl)$${digest}$(rs))
fi
rm "$${cache}"
endef

else

define github_check_package_version
$(call message,⚠️ ,Github check package version requires the environment variable $(hl)GITHUB_TOKEN$(rs) to be defined)
endef

endif
