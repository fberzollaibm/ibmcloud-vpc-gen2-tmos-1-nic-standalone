
data "ibm_is_subnet" "f5_subnet" {
  identifier = var.subnet_id
}

data "ibm_resource_group" "rg" {
  depends_on = [data.ibm_is_subnet.f5_subnet]
  name       = data.ibm_is_subnet.f5_subnet.resource_group_name
}

data "ibm_is_ssh_key" "f5_ssh_pub_key" {
  name = var.ssh_key_name
}

data "ibm_is_instance_profile" "instance_profile" {
  name = var.instance_profile
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.yaml")
  vars = {
    tmos_admin_password  = var.tmos_admin_password
    tmos_license_basekey = var.tmos_license_basekey
    phone_home_url       = var.phone_home_url
  }
}

data "ibm_is_image" "f5_custom_image" {
  name       = var.vnf_vpc_image_name
}

data "ibm_is_security_group" "f5_tmm_sg" {
  name           = var.f5-tmm-sg-name
}

resource "ibm_is_instance" "f5_ve_instance" {
  name = var.instance_name

  # image   = data.ibm_is_image.tmos_image.id
  image          = data.ibm_is_image.f5_custom_image.id
  profile        = data.ibm_is_instance_profile.instance_profile.id
  resource_group = data.ibm_resource_group.rg.id
  primary_network_interface {
    name            = "tmm-1nic"
    subnet          = data.ibm_is_subnet.f5_subnet.id
    security_groups = [data.ibm_is_security_group.f5_tmm_sg.id]
  }
  vpc       = data.ibm_is_subnet.f5_subnet.vpc
  zone      = data.ibm_is_subnet.f5_subnet.zone
  keys      = [data.ibm_is_ssh_key.f5_ssh_pub_key.id]
  user_data = data.template_file.user_data.rendered
}

output "resource_name" {
  value = ibm_is_instance.f5_ve_instance.name
}

output "resource_status" {
  value = ibm_is_instance.f5_ve_instance.status
}

output "VPC" {
  value = ibm_is_instance.f5_ve_instance.vpc
}

