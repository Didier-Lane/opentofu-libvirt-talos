# local directory were binaries are stored
LOCAL_BIN_DIR				?= ~/.local/bin
LOCAL_BIN_PATH				:= $(subst ~,$(HOME),$(LOCAL_BIN_DIR))

# local directory were iso and qcow2 images are stored
LOCAL_IMAGES_DIR			?= ~/.local/share/libvirt/images
LOCAL_IMAGES_PATH			:= $(subst ~,$(HOME),$(LOCAL_IMAGES_DIR))

$(LOCAL_BIN_PATH):
	mkdir -p $(LOCAL_BIN_PATH)

$(LOCAL_IMAGES_PATH):
	mkdir -p $(LOCAL_IMAGES_PATH)
