# https://www.gnu.org/software/make/manual/make.html

# Do not print directory changes when using recursive make commands with the variable MAKE
GNUMAKEFLAGS = --no-print-directory

# all lines of the recipe will be given to a single invocation of the shell
# rather than each line being invoked separately
.ONESHELL:

# setting ZSH or BASH as the make recipes shell
SHELL := $(firstword $(foreach s,zsh bash,$(shell command -v $(s))))

ifeq ($(SHELL),)
$(error ZSH or BASH is required, but none were found)
endif

# flags of invoked shell in make recipes
.SHELLFLAGS = -Eeu -o pipefail

# enables make recipes verbosity
ifdef VERBOSE
.SHELLFLAGS += -x
else
.SILENT:
endif

.SHELLFLAGS += -c

# includes working copy environment variables
-include .env

# shares all environment variables accross makefiles
.EXPORT_ALL_VARIABLES:

# includes makefiles filtered out with dependencies makefiles
INCLUDED_MAKEFILES		:= $(shell find ./make -type f -name '*.mk' -not -path '*/deps/*')

# list of dependencies required by the project
DEPENDENCIES			?= $(DEPS)

# implements dependencies
ifneq (,$(DEPENDENCIES))

# list of dependencies makefiles
DEPS_MAKEFILES 			:= $(shell find ./make -type f -name '*.mk' -path '*/deps/*')

# appends the host dependency to the list if not present
ifeq (,$(findstring host,$(DEPENDENCIES)))
override DEPENDENCIES 	+= host
endif

# appends the jq dependency to the list for github or dockerhub if not present
ifneq (,$(firstword $(filter dockerhub github,$(DEPENDENCIES))))
ifeq (,$(findstring jq,$(DEPENDENCIES)))
override DEPENDENCIES 	+= jq
endif
endif

# appends selected dependencies makefiles to the include list
INCLUDED_MAKEFILES		+= $(filter $(foreach dep,$(DEPENDENCIES),%/deps/$(dep).mk),$(DEPS_MAKEFILES))

endif

# includes sub makefiles from the "make" directory
-include $(INCLUDED_MAKEFILES)
