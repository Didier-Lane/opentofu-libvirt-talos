DOCKER_HUB_API_ENDPOINT	:= https://hub.docker.com/v2

define dockerhub_api_get_tags
curl -fsSL \
	"$(DOCKER_HUB_API_ENDPOINT)/namespaces/$(1)/repositories/$(2)/tags?page_size=100" \
	| jq -c '[.results[] | select(.images[].architecture == "$(ARCH)")]'
endef

define dockerhub_get_reference_tag_image_digest
jq -r '.[] | select(.name == "'"$(1)"'")
	| .images[] | select(.architecture == "$(ARCH)")' \
	< "$(2)" | jq -rs 'first | .digest'
endef

define dockerhub_get_tag_by_image_digest
tagFilters=""
for tag in $(2); do
	tagFilters+=' | select(.name | contains("'"$${tag}"'") | not)'
done
jq -r '.[] | select(.images[].digest == "'"$(1)"'")
	'"$${tagFilters}"'' \
	< "$(3)" | jq -rs 'first | .name'
endef

define dockerhub_check_version
repository="$(1)"
if [[ "$${repository}" =~ .*/.* ]]; then
	namespace="$${repository%/*}"
	repository="$${repository#*/}"
else
	namespace="library"
fi
currentTag="$(2)"
[ ! -z "$(3)" ] && referenceTag="$(3)" || referenceTag="latest"
excludedTags=("$${referenceTag}")
[ ! -z "$(4)" ] && excludedTags+=("$(4)")
cache="$$( mktemp )"
$(call dockerhub_api_get_tags,$${namespace},$${repository}) > "$${cache}"
referenceTagDigest="$$( $(call dockerhub_get_reference_tag_image_digest,$${referenceTag},$${cache}) )"
if [[ "$${referenceTagDigest}" == "null" ]]; then
	$(call message,⚠️ ,Failed to resolve $(hl)$(1)$(rs) reference tag $(hl)$${referenceTag}$(rs) image digest)
else
	latestTag="$$( $(call dockerhub_get_tag_by_image_digest,$${referenceTagDigest},$${excludedTags[@]},$${cache}) )"
	if [[ "$${latestTag}" == "null" ]]; then
		$(call message,⚠️ ,Failed to resolve $(hl)$(1)$(rs) latest tag)
	elif [[ "$${latestTag}" == "$${currentTag}" ]]; then
		$(call message,✅,Image $(hl)$(1)$(rs) is up to date with tag $(hl)$${currentTag}$(rs))
	else
		$(call message,💡,Image $(hl)$(1)$(rs) new tag is $(hl)$${latestTag}$(rs) with digest $(hl)$${referenceTagDigest}$(rs))
	fi
fi
rm "$${cache}"
endef
