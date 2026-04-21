define env_vars
grep -hEo '^([A-Z\_]+)\s*(\?|!|::|:::)=' $(MAKEFILE_LIST) | sed 's/\s*[?!:]*=.*//g' | sort -d
endef

.env:
	for v in $(foreach v,$(shell $(env_vars)),$(v)="$($(v))"); do
		echo "$${v}" >> .env
	done

.DEFAULT: .env
	$(MAKE) $(.DEFAULT_GOAL)
