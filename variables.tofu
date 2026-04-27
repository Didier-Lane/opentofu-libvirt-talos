variable "project_name" {
  type    = string
  default = "opentofu-libvirt-talos"
}

variable "bucket_name" {
  type    = string
  default = "opentofu-libvirt-talos"
}

variable "nodes_prefix" {
  type    = string
  default = "node-"
}

variable "images_storage_path" {
  type = string
}

variable "talos_iso" {
  type = object({
    name = string
    url  = string
  })
}

variable "network" {
  type = object({
    cidr        = string
    domain      = string
    ip          = string
    prefix      = string
    gateway     = string
    nameservers = list(string)
  })
}

variable "nodes" {
  type = map(object({
    memory  = number # MB
    vcpus   = number
    disk_gb = number
  }))
}
