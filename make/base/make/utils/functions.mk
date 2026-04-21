define path
$(subst ~,$(HOME),$(1))
endef

define download
curl -fSLo "$(2)" "$(1)"
endef

define checksum
DIGEST="$(1)"
ALG="$${DIGEST%:*}"
HASH="$${DIGEST#*:}"
echo "$${HASH}" "$(2)" | "$${ALG}sum" --check -
endef

define executable
chmod +x "$(1)"
endef

define extract
case "$$( file --brief --mime-type "$(1)" )" in
	*/x-bzip2|*/gzip|*/x-xz) tar -C "$(dir $(1))" -xf "$(1)";;
	*/zip) unzip -d "$(dir $(1))" "$(1)";;
esac
endef

define release_install
$(call message,📥,Installing $(hl)$(1)$(rs) version $(hl)$(2)$(rs) to $(hl)$(5)$(rs))
$(call download,$(3),$(5))
$(call checksum,$(4),$(5))
$(call extract,$(5))
$(call executable,$(5))
endef

define random_hash
tr -dc 'a-zA-Z0-9\+\-\@\,\:\;\!\%\=' </dev/urandom | head -c 24
endef
