.PHONY: install
install: tofu start talos # 🚀 Deploys the Kubernetes cluster

.PHONY: uninstall
uninstall: virsh/destroy tofu/destroy clean # 🗑️  Destroys the Kubernetes cluster
