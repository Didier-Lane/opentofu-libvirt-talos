PROJECT_NAME			?= opentofu-libvirt-talos
IMAGES_STORAGE_PATH		?= $(abspath $(CURDIR)/images)
NUM_NODES				?= 2
NODES_PREFIX			?= node-
NODES_VCPUS				?= 2
NODES_MEMORY			?= 4096
NODES_DISK_GB			?= 20
NETWORK_CIDR			?= 10.11.12.0/24
NETWORK_DOMAIN			?= public
NETWORK_IP				:= $(shell echo "$(NETWORK_CIDR)" | sed 's|\/.*||')
NETWORK_PREFIX			:= $(shell echo "$(NETWORK_CIDR)" | sed 's|.*\/||')
NETWORK_GATEWAY			:= $(shell echo "$(NETWORK_IP)" | sed 's|\.0$$|.254|')
NAMESERVERS				?= 1.1.1.1 1.0.0.1 8.8.8.8

terraform.tfvars:
	cat <<EOF > terraform.tfvars
	project_name = "$(PROJECT_NAME)"
	bucket_name = "$(AWS_BUCKET_NAME)"
	nodes_prefix = "$(NODES_PREFIX)"
	talos_iso = {
		name = "$(TALOS_ISO_NAME)"
		url = "file://$(TALOS_ISO)"
	}
	images_storage_path = "$(IMAGES_STORAGE_PATH)"
	network = {
		cidr = "$(NETWORK_CIDR)"
		domain = "$(NETWORK_DOMAIN)"
		ip = "$(NETWORK_IP)"
		prefix = "$(NETWORK_PREFIX)"
		gateway = "$(NETWORK_GATEWAY)"
		nameservers = [$(foreach ns,$(NAMESERVERS),"$(ns)",)]
	}
	nodes = {
		$$( for i in {1..$(NUM_NODES)}; do \
		cat <<EON
			"$(NODES_PREFIX)$${i}" = {
				memory  = $(NODES_MEMORY)
				vcpus   = $(NODES_VCPUS)
				disk_gb = $(NODES_DISK_GB)
			},
		EON
		done)
	}
	EOF
	tofu fmt -recursive 1> /dev/null

.PHONY: tofu/%
tofu/%:	talos/iso terraform.tfvars # 🧈 Executes an OpenTofu command
	args=($(subst tofu/,,$@) $(ARGS))
	[[ "$${args[1]}" =~ "apply|destroy" ]] && args+=("-auto-approve") || true
	tofu "$${args[@]}"

.PHONY: tofu
tofu: tofu/init tofu/apply # 🧈 Deploys infrastructure with OpenTofu
