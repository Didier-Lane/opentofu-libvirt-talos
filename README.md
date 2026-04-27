# OpenTofu Libvirt Talos

Provisioning a [Talos Linux] cluster in [Libvirt] [QEMU/KVM] virtual machines with [OpenTofu]

## Requirements

- [OpenTofu]
- [Libvirt]
- [QEMU/KVM]
- [GNU Make]
- An [AWS S3] compatible backend for storing the terraform state

## Usage

Operations are organized as make recipes, just run `make` to see the list of available targets.

```shell
$ make
Usage

# To run and execute a target
make <target>

Available Targets

tofu/%          🧈 Executes an OpenTofu command
tofu            🧈 Deploys infrastructure with OpenTofu
install         🚀 Deploys the Kubernetes cluster
uninstall       🗑️  Destroys the Kubernetes cluster
clean           ✨ Cleans the working copy
help            💡 Shows this help menu
check           🔄 Checks for newer versions of dependencies
```

[Talos Linux]: https://docs.siderolabs.com/talos/
[Libvirt]: https://libvirt.org/
[QEMU/KVM]: https://libvirt.org/drvqemu.html
[OpenTofu]: https://opentofu.org/
[GNU Make]: https://www.gnu.org/software/make/
[AWS S3]: https://aws.amazon.com/s3/
