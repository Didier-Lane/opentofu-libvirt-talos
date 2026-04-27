TALOS_VERSION				?= v1.12.7
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
KUBERNETES_VERSION			?= 1.36.0
KUBECONFIG					?= $(TALOS_CONFIG_DIR)/kubeconfig
TLS_CA_CRT					?= ~/.ssl/DidierLane/CA.crt
PROXIED_REGISTRIES			?= docker.io gcr.io ghcr.io registry.k8s.io quay.io
REGISTRY_PROXY_URL			?= http://$(NETWORK_GATEWAY):3128/

.PHONY: talos/ready
talos/ready: talosctl
	for ip in $(NODES_IPS); do
		$(call message,🌐,Trying to reach node $(hl)$${ip}$(rs))
		n=1; delay=5; max_attempts=6
		while ! curl -sk "https://$${ip}:50000"; do
			if [ "$$n" -eq "$${max_attempts}" ]; then
				$(call message,⚠️ ,Max attempts reached)
				exit 1
			fi
			$(call message,⚠️ ,Attempt $(hl)$${n}/$${max_attempts}$(rs) failed retrying in $(hl)$${delay} seconds$(rs))
			n=$$(($${n}+1))
			sleep $${delay}
		done
		$(call message,✅,Node $(hl)$${ip}$(rs) ready)
	done

$(TALOS_CONFIG_DIR): talos/ready
	if [ ! -d "$(TALOS_CONFIG_DIR)" ]; then
		$(call message,📝,Generating Talos configuration $(hl)$(TALOS_CONFIG_DIR)$(rs))
		talosctl gen config "$(CLUSTER_NAME)" \
			"$(CONTROL_PLANE_URL)" \
			--talos-version "$(TALOS_VERSION)" \
			--kubernetes-version "$(KUBERNETES_VERSION)" \
			--with-docs=false \
			--with-examples=false \
			--install-disk /dev/vda \
			--output "$(TALOS_CONFIG_DIR)"
	fi

.PHONY: talos/config
talos/config: $(TALOS_CONFIG_DIR) yq
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
		$(call message,📝,Generating Talos configuration $(hl)$${config}$(rs))
		yq -P --indent=2 '.' < "$(TALOS_CONFIG_DIR)/$${template}" > "$${config}"
		yq -i \
			'select(di == 0).machine.kubelet.nodeIP.validSubnets = ["$(NETWORK_CIDR)"]' \
			"$${config}"
		hostnameConfigDI="$$( yq 'select(.kind == "HostnameConfig") | documentIndex' < "$${config}" )"
		yq -i \
			'select(di == '"$${hostnameConfigDI}"').hostname= "'"$${hostname}"'"
			| select(di == '"$${hostnameConfigDI}"').auto = "off"' \
			"$${config}"
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
	done

.PHONY: talos/apply
talos/apply: talos/config
	hostnames=($(NODES_HOSTNAMES)); ips=($(NODES_IPS))
	for i in {1..$${#hostnames[@]}}; do
		hostname="$${hostnames[$$i]}"; ip="$${ips[$$i]}"
		config="$(TALOS_CONFIG_DIR)/$${hostname}.yaml"
		$(call message,⚙️ ,Applying configuration $(hl)$${config}$(rs) to $(hl)$${hostname}$(rs))
		talosctl apply-config --insecure --nodes "$${ip}" --file "$${config}"
	done

.PHONY: talos/endpoints
talos/endpoints:
	talosctl config endpoints "$(CONTROL_PLANE_IP)"

.PHONY: talos/time
talos/time: talos/endpoints
	$(call message,🌐,Trying to reach nodes $(hl)$(NODES_IPS)$(rs))
	n=1; delay=5; max_attempts=$$((10*$(NUM_NODES)))
	while ! talosctl time $(foreach n,$(NODES_IPS),--nodes $(n)) &> /dev/null; do
		if [ "$$n" -eq "$${max_attempts}" ]; then
			$(call message,⚠️ ,Max attempts reached)
			exit 1
		fi
		$(call message,⚠️ ,Attempt $(hl)$${n}/$${max_attempts}$(rs) failed retrying in $(hl)$${delay} seconds$(rs))
		n=$$(($${n}+1))
		sleep $${delay}
	done
	$(call message,✅,Nodes are ready)

.PHONY: talos/bootstrap
talos/bootstrap: talos/time
	talosctl bootstrap --nodes "$(CONTROL_PLANE_IP)"

$(KUBECONFIG):
	talosctl kubeconfig "$(KUBECONFIG)" --nodes "$(CONTROL_PLANE_IP)"
	$(call message,☸️ ,Run the following command to use kubectl $(hl)export KUBECONFIG=$(KUBECONFIG)$(rs))

.PHONY: talos
talos: talos/apply talos/bootstrap $(KUBECONFIG)
