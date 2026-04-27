terraform {
  backend "s3" {
    bucket                      = var.bucket_name
    key                         = "terraform.tfstate"
    use_lockfile                = true
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

module "libvirt" {
  source = "./modules/libvirt"

  project_name        = var.project_name
  nodes_prefix        = var.nodes_prefix
  images_storage_path = var.images_storage_path
  talos_iso           = var.talos_iso
  network             = var.network
  nodes               = var.nodes
}
