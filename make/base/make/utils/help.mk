.DEFAULT_GOAL := help

ifndef HELP_HEADER
define HELP_HEADER :=
$(underline)Usage$(reset)

	# To run and execute a target
	$(bold)make $(cyan)<target>$(reset)
$(HELP_HEADER_EXTRAS)
$(underline)Available Targets$(reset)

endef
endif

ifndef HELP_LINE_PADDING
HELP_LINE_PADDING := 16
endif

define help_line :=
'{gsub(/^ /, "", $$3); printf "%-$(HELP_LINE_PADDING)s %s\n", $$1, $$3}'
endef

ifdef COLORS
define help_line :=
'{printf "$(hl)%-$(HELP_LINE_PADDING)s$(rs)%s %s\n", $$1, $$2, $$3}'
endef
endif

define get_help_targets :=
grep -hEo '(^[^\: ]+:.*?# .*$$)' $(INCLUDED_MAKEFILES)
endef

define get_help_lines :=
$(get_help_targets) | sed -e 's/:.*# /|/g' -e 's/ /|/1'
endef

define get_help_lines_vars :=
$(get_help_targets) \
	| { grep -Eo '\$$\([^\)]+\)' || true } \
	| sort -u | sed -e 's/[\$$()]*//g' \
	| tr '\n' ' ' | sed 's/ $$//'
endef

define substitue_help_lines_vars :=
$(foreach v,$(shell $(get_help_lines_vars)),| sed -e 's!\$$($(v))!$($(v))!g')
endef

define display_help_lines :=
$(get_help_lines) \
	$(substitue_help_lines_vars) \
	| awk -F'|' $(help_line)
endef

.PHONY: help
help: # 💡 Shows this help menu
	echo -e "$(HELP_HEADER)"
	$(display_help_lines)
