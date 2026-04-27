# https://factory.talos.dev/
# https://factory.talos.dev/?arch=amd64&bootloader=grub&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.12.5
TALOS_FACTORY_URL			:= https://factory.talos.dev/image
TALOS_FACTORY_ID			?= ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515
TALOS_PLATFORM				?= nocloud
TALOS_ISO_URL				:= $(TALOS_FACTORY_URL)/$(TALOS_FACTORY_ID)/$(TALOS_VERSION)/$(TALOS_PLATFORM)-$(ARCH).iso
TALOS_ISO_NAME				:= talos-$(TALOS_VERSION)-$(TALOS_PLATFORM)-$(ARCH).iso
TALOS_ISO					:= $(IMAGES_DIR)/$(TALOS_ISO_NAME)

$(TALOS_ISO): $(IMAGES_DIR)
	$(call message,📥,Downloading Talos Linux ISO version,$(TALOS_VERSION),to,$(TALOS_ISO))
	curl -fSLo "$(TALOS_ISO)" "$(TALOS_ISO_URL)"
