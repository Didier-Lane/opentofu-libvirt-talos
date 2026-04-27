# local directory were iso and qcow2 images are stored
IMAGES_DIR					?= ~/.local/share/libvirt/images

ifneq (,$(findstring ~,$(IMAGES_DIR)))
override IMAGES_DIR			:= $(call path,$(IMAGES_DIR))
endif

$(IMAGES_DIR):
	mkdir -p "$(IMAGES_DIR)"
