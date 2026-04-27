terraform {
  # https://search.opentofu.org/provider/dmacvicar/libvirt/latest
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "this" {
  name = var.project_name
  domain = {
    name = var.network.domain
  }
  autostart = true
  forward = {
    mode = "nat"
  }
  ips = [{
    family  = "ipv4"
    prefix  = var.network.prefix
    address = var.network.gateway
  }]
}

resource "libvirt_pool" "storage" {
  name = var.project_name
  type = "dir"
  target = {
    path = var.images_storage_path
    permissions = {
      owner = var.images_owner
      group = var.images_group
      mode  = var.images_mode
    }
  }
}

resource "libvirt_volume" "talos_iso" {
  for_each = var.nodes

  name = "${var.project_name}.${each.key}.${var.talos_iso.name}"
  pool = libvirt_pool.storage.name
  target = {
    format = {
      type = "iso"
    }
    permissions = {
      owner = var.images_owner
      group = var.images_group
      mode  = var.images_mode
    }
  }
  create = {
    content = {
      url = var.talos_iso.url
    }
  }
}

resource "libvirt_volume" "main" {
  for_each = var.nodes

  name     = "${var.project_name}.${each.key}.main.qcow2"
  pool     = libvirt_pool.storage.name
  capacity = each.value.disk_gb * 1073741824 # Convert GB to bytes
  target = {
    format = {
      type = "qcow2"
    }
    permissions = {
      owner = var.images_owner
      group = var.images_group
      mode  = var.images_mode
    }
  }
}

resource "libvirt_cloudinit_disk" "cidata" {
  for_each = var.nodes

  name = "${var.project_name}.${each.key}.cidata"
  meta_data = yamlencode({
    instance-id    = each.key
    local-hostname = each.key
  })
  user_data = templatefile("${path.module}/cloud_init/cloud_init.cfg", {
    hostname = each.key
    domain   = var.network.domain
  })
  network_config = templatefile("${path.module}/cloud_init/network_config.cfg", {
    address     = cidrhost(var.network.cidr, replace(each.key, var.nodes_prefix, ""))
    prefix      = var.network.prefix
    gateway     = var.network.gateway
    nameservers = indent(8, yamlencode(var.network.nameservers))
  })
}

resource "libvirt_volume" "cloud_init" {
  for_each = var.nodes

  name = "${var.project_name}.${each.key}.cloud_init.iso"
  pool = libvirt_pool.storage.name
  target = {
    format = {
      type = "iso"
    }
    permissions = {
      owner = var.images_owner
      group = var.images_group
      mode  = var.images_mode
    }
  }
  create = {
    content = {
      url = libvirt_cloudinit_disk.cidata[each.key].path
    }
  }
}

resource "libvirt_domain" "node" {
  for_each = var.nodes

  type           = "kvm"
  name           = "${var.project_name}.${each.key}"
  memory         = each.value.memory
  memory_unit    = "MiB"
  vcpu           = each.value.vcpus
  vcpu_placement = "static"
  cpu = {
    mode = "host-passthrough"
  }
  autostart = false
  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc-i440fx-10.1"
    boot_menu = {
      enable  = "yes"
      timeout = "1"
    }
    boot_devices = [{
      dev = "hd"
      }, {
      dev = "cdrom"
    }]
  }
  features = {
    acpi = true
    vm_port = {
      state = "off"
    }
  }
  clock = {
    offset = "utc"
    timer = [{
      name       = "rtc"
      tickpolicy = "catchup"
      },
      {
        name       = "pit"
        tickpolicy = "delay"
      },
      {
        name    = "hpet"
        present = "no"
    }]
  }
  pm = {
    suspend_to_disk = {
      enabled = "no"
    }
    suspend_to_mem = {
      enabled = "no"
    }
  }
  devices = {
    disks = [{
      type   = "file"
      device = "cdrom"
      driver = {
        name = "qemu"
        type = "raw"
      }
      source = {
        file = {
          file = libvirt_volume.talos_iso[each.key].path
        }
      }
      target = {
        dev = "sda"
        bus = "sata"
      }
      },
      {
        type   = "file"
        device = "disk"
        driver = {
          name    = "qemu"
          type    = "qcow2"
          discard = "unmap"
        }
        source = {
          file = {
            file = libvirt_volume.main[each.key].path
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        type   = "file"
        device = "cdrom"
        driver = {
          name = "qemu"
          type = "raw"
        }
        source = {
          file = {
            file = libvirt_volume.cloud_init[each.key].path
          }
        }
        target = {
          dev = "sdc"
          bus = "sata"
        }
    }]
    interfaces = [{
      model = {
        type = "e1000"
      }
      source = {
        network = {
          network = libvirt_network.this.name
        }
      }
    }]
    consoles = [{
      type = "pty"
      target = {
        port = 0
        type = "virtio"
      }
    }]
    graphics = [{
      spice = {
        auto_port = true
        image = {
          compression = "off"
        }
      }
    }]
    videos = [{
      model = {
        type    = "virtio"
        heads   = "1"
        primary = "yes"
        acceleration = {
          accel3d = "no"
        }
      }
    }]
    rngs = [{
      model = "virtio"
      backend = {
        random = "/dev/urandom"
      }
    }]
  }
}
