ifndef OS
OS					!= uname -s | tr "[:upper:]" "[:lower:]"
endif

ifndef ARCH
ARCH				!= uname -m
endif

ifeq (x86_64,$(ARCH))
override	ARCH	= amd64
endif

BIN_DIR				?= ~/.local/bin

ifneq (,$(findstring ~,$(BIN_DIR)))
override BIN_DIR	:= $(call path,$(BIN_DIR))
endif

$(BIN_DIR):
	mkdir -p "$(BIN_DIR)"
