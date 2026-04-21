# https://factory.talos.dev/
# https://factory.talos.dev/?arch=amd64&bootloader=grub&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.12.5
TALOS_FACTORY_URL			:= https://factory.talos.dev/image
TALOS_FACTORY_ID			?= 3cbe47354d9e61120789577b809fd5738aa607b0afbab74abb10216a4da57903
TALOS_VERSION				?= v1.12.5
TALOS_PLATFORM				?= nocloud
TALOS_ISO_URL				:= $(TALOS_FACTORY_URL)/$(TALOS_FACTORY_ID)/$(TALOS_VERSION)/$(TALOS_PLATFORM)-$(ARCH).iso
TALOS_ISO_NAME				:= talos-$(TALOS_VERSION)-$(TALOS_PLATFORM)-$(ARCH).iso
TALOS_ISO					:= $(LOCAL_IMAGES_PATH)/$(TALOS_ISO_NAME)

# https://github.com/siderolabs/talos/releases/download/v1.12.5/talosctl-linux-amd64
TALOSCTL_RELEASES			:= https://github.com/siderolabs/talos/releases
TALOSCTL_URL				:= $(TALOSCTL_RELEASES)/download/$(TALOS_VERSION)/talosctl-linux-$(ARCH)
TALOSCTL					:= $(LOCAL_BIN_PATH)/talosctl
TALOS_CONFIG_DIR			?= .talos
TALOSCONFIG					:= $(TALOS_CONFIG_DIR)/talosconfig
NODES_HOSTNAMES				:= $(shell for i in {1..$(NUM_NODES)}; do echo "$(NODES_PREFIX)$${i}"; done)
CONTROL_PLANE_HOSTNAME		:= $(firstword $(NODES_HOSTNAMES))
WORKERS_HOSTNAMES			:= $(strip $(subst $(CONTROL_PLANE_HOSTNAME),,$(NODES_HOSTNAMES)))
NODES_IPS					:= $(shell for i in {1..$(NUM_NODES)}; do echo "$(NETWORK_CIDR)" | sed "s|\.0.*$$|.$${i}|"; done)
CONTROL_PLANE_IP			:= $(firstword $(NODES_IPS))
WORKERS_IPS					:= $(strip $(subst $(CONTROL_PLANE_IP),,$(NODES_IPS)))
NODES_CIDRS					:= $(shell for i in {1..$(NUM_NODES)}; do echo "$(NETWORK_CIDR)" | sed "s|\.0\/|.$${i}\/|"; done)
CONTROL_PLANE_CIDR			:= $(firstword $(NODES_CIDRS))
WORKERS_CIDRS				:= $(strip $(subst $(CONTROL_PLANE_CIDR),,$(NODES_CIDRS)))
CONTROL_PLANE_URL			:= https://$(CONTROL_PLANE_IP):6443
CLUSTER_NAME				?= sandbox
KUBECONFIG					?= $(TALOS_CONFIG_DIR)/kubeconfig
TLS_CA_CRT					?= ~/.ssl/local.io/CA.crt
PROXIED_REGISTRIES			?= docker.io gcr.io ghcr.io registry.k8s.io quay.io
REGISTRY_PROXY_URL			?= http://$(NETWORK_GATEWAY):3128/

$(TALOS_ISO): $(LOCAL_IMAGES_PATH)
	$(call message,📥,Downloading Talos Linux ISO version,$(TALOS_VERSION),to,$(TALOS_ISO))
	curl -fSLo $(TALOS_ISO) $(TALOS_ISO_URL)

$(TALOSCTL): $(LOCAL_BIN_PATH)
	$(call message,📥,Downloading TalosCTL version,$(TALOS_VERSION),to,$(TALOSCTL))
	curl -fSLo $(TALOSCTL) $(TALOSCTL_URL)
	chmod +x $(TALOSCTL)

.PHONY: talos/ready
talos/ready: $(TALOSCTL)
	for ip in $(NODES_IPS); do
		$(call message,🌐,Trying to reach node,$${ip})
		n=1; delay=5; max_attempts=6
		while ! curl -sk "https://$${ip}:50000"; do
			if [ "$$n" -eq "$${max_attempts}" ]; then
				$(call message,⚠️ ,Max attempts reached)
				exit 1
			fi
			$(call message,⚠️ ,Attempt,$${n}/$${max_attempts},failed retrying in,$${delay} seconds)
			n=$$(($${n}+1))
			sleep $${delay}
		done
		$(call message,✅,Node,$${ip},ready)
	done

$(TALOS_CONFIG_DIR): talos/ready
	if [ ! -d "$(TALOS_CONFIG_DIR)" ]; then
		$(call message,📝,Generating Talos configuration in,$(TALOS_CONFIG_DIR))
		talosctl gen config "$(CLUSTER_NAME)" \
			"$(CONTROL_PLANE_URL)" \
			--talos-version "$(TALOS_VERSION)" \
			--kubernetes-version "1.35.2" \
			--with-docs=false \
			--with-examples=false \
			--install-disk /dev/vda \
			--output "$(TALOS_CONFIG_DIR)"
	fi

.PHONY: talos/config
talos/config: $(TALOS_CONFIG_DIR) $(YQ_BIN)
	hostnames=($(NODES_HOSTNAMES))
	ips=($(NODES_IPS))
	cidrs=($(NODES_CIDRS))
	for i in {1..$${#hostnames[@]}}; do
		hostname="$${hostnames[$$i]}"
		ip="$${ips[$$i]}"
		cidr="$${cidrs[$$i]}"
		[[ "$${hostname}" == "$(CONTROL_PLANE_HOSTNAME)" ]] \
			&& template="controlplane.yaml" || template="worker.yaml"
		config="$(TALOS_CONFIG_DIR)/$${hostname}.yaml"
		head -n -4 "$(TALOS_CONFIG_DIR)/$${template}" > "$${config}"
		yq -P --indent=2 -i '.' "$${config}"
		yq -i \
			'select(di == 0).machine.kubelet.nodeIP.validSubnets = ["$(NETWORK_CIDR)"]' \
			"$${config}"
		echo "---" >> "$${config}"
		yq -n '.apiVersion = "v1alpha1"
			| .kind = "HostnameConfig"
			| .hostname = "'"$${hostname}"'"
			| .auto = "off"' \
			>> "$${config}"
		echo "---" >> "$${config}"
		yq -n '.apiVersion = "v1alpha1"
			| .kind = "LinkConfig"
			| .name = "enp0s3"
			| .addresses = [{"address": "'"$${cidr}"'"}]
			| .routes = [{"gateway": "$(NETWORK_GATEWAY)"}]' \
			>> "$${config}"
		echo "---" >> "$${config}"
		yq -n '.apiVersion = "v1alpha1"
			| .kind = "ResolverConfig"
			| .nameservers = []' \
			>> "$${config}"
		for ns in $(NAMESERVERS); do
			yq -i 'select(di == 3).nameservers += {"address": "'"$${ns}"'"}' \
				"$${config}"
		done
		echo "---" >> "$${config}"
		yq -n '.apiVersion = "v1alpha1"
			| .kind = "TrustedRootsConfig"
			| .name = "host-ca"' \
			>> "$${config}"
		echo 'certificates: |-' >> "$${config}"
		cat "$(subst ~,$(HOME),$(TLS_CA_CRT))" | sed 's/^/  /g' >> "$${config}"
		for registry in $(PROXIED_REGISTRIES); do
			echo "---" >> "$${config}"
			yq -n '.apiVersion = "v1alpha1"
				| .kind = "RegistryMirrorConfig"
				| .name = "'"$${registry}"'"
				|.endpoints = [{"url":"$(REGISTRY_PROXY_URL)"}]' \
				>> "$${config}"
		done
	done

.PHONY: talos/apply
talos/apply: talos/config
	hostnames=($(NODES_HOSTNAMES)); ips=($(NODES_IPS))
	for i in {1..$${#hostnames[@]}}; do
		hostname="$${hostnames[$$i]}"; ip="$${ips[$$i]}"
		config="$(TALOS_CONFIG_DIR)/$${hostname}.yaml"
		$(call message,⚙️ ,Applying configuration,$${config},to,$${hostname})
		talosctl apply-config --insecure --nodes "$${ip}" --file "$${config}"
	done

.PHONY: talos/endpoints
talos/endpoints:
	talosctl config endpoints "$(CONTROL_PLANE_IP)"

.PHONY: talos/time
talos/time: talos/endpoints
	$(call message,🌐,Trying to reach nodes,$(NODES_IPS))
	n=1; delay=5; max_attempts=$$((10*$(NUM_NODES)))
	while ! talosctl time $(foreach n,$(NODES_IPS),--nodes $(n)) &> /dev/null; do
		if [ "$$n" -eq "$${max_attempts}" ]; then
			$(call message,⚠️ ,Max attempts reached)
			exit 1
		fi
		$(call message,⚠️ ,Attempt,$${n}/$${max_attempts},failed retrying in,$${delay} seconds)
		n=$$(($${n}+1))
		sleep $${delay}
	done
	$(call message,✅,Nodes are ready)

.PHONY: talos/bootstrap
talos/bootstrap: talos/time
	talosctl bootstrap --nodes "$(CONTROL_PLANE_IP)"

$(KUBECONFIG):
	talosctl kubeconfig "$(KUBECONFIG)" --nodes "$(CONTROL_PLANE_IP)"
	$(call message,☸️ ,Run the following command to use kubectl,export KUBECONFIG=$(KUBECONFIG))

.PHONY: talos
talos: talos/apply talos/bootstrap $(KUBECONFIG)
