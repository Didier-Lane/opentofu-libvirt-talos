.PHONY: virsh/list
virsh/list:
	virsh list --state-$(STATE) --name \
		| grep -Es '^$(PROJECT_NAME)' || true

.PHONY: virsh/start
virsh/start:
	for domain in $$( $(MAKE) virsh/list STATE=shutoff ); do
		virsh start "$$domain"
	done

.PHONY: virsh/stop
virsh/stop:
	for domain in $$( $(MAKE) virsh/list STATE=running ); do
		virsh shutdown "$$domain"
	done

.PHONY: virsh/destroy
virsh/destroy:
	for domain in $$( $(MAKE) virsh/list STATE=running ); do
		virsh destroy "$$domain"
	done

.PHONY: start
start: virsh/start

.PHONY: stop
stop: virsh/stop
