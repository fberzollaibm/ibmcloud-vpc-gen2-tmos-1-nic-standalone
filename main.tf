
locals {
  subnets = [
    for i, subnet in var.subnets : {
      idx                 = i
      subnet_id           = subnet.subnet_id
      nic_name            = subnet.nic_name
      security_group_name = subnet.security_group_name
      unique-security_group_name = "${subnet.security_group_name}-${i}}"
      unique-subnet_id    = "${subnet.subnet_id}-${i}}"
      vip_route           = subnet.vip_route
    }
  ]
}

data "ibm_is_vpc" "f5_vpc" {
  name = var.vpc_name
}

data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

data "ibm_is_ssh_key" "f5_ssh_pub_key" {
  name = var.ssh_key_name
}

data "ibm_is_instance_profile" "instance_profile" {
  name = var.instance_profile
}

data "ibm_is_image" "f5_custom_image" {
  name = var.vnf_vpc_image_name
}

data "ibm_is_security_group" "f5_tmm_sg" {
  for_each = {
    for i, subnet in local.subnets : subnet.unique-security_group_name => subnet
  }
  name     = each.value.security_group_name
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.yaml")
  vars = {
    tmos_admin_password  = var.tmos_admin_password
    tmos_license_basekey = var.tmos_license_basekey
    phone_home_url       = var.phone_home_url
  }
}

resource "ibm_is_instance" "f5_ve_instance" {
  name = var.instance_name

  # image   = data.ibm_is_image.tmos_image.id
  image          = data.ibm_is_image.f5_custom_image.id
  profile        = data.ibm_is_instance_profile.instance_profile.id
  resource_group = data.ibm_resource_group.rg.id

  primary_network_interface {
      name            = local.subnets[0].nic_name
      subnet          = local.subnets[0].subnet_id
      security_groups = [data.ibm_is_security_group.f5_tmm_sg[local.subnets[0].unique-security_group_name].id]
  }

  dynamic "network_interfaces" {
    for_each = {
      for i, subnet in local.subnets : subnet.unique-subnet_id => subnet if i>0
    }
    content {
      name            = network_interfaces.value.nic_name
      subnet          = network_interfaces.value.subnet_id
      security_groups = [data.ibm_is_security_group.f5_tmm_sg[network_interfaces.value.unique-security_group_name].id]
    }
  }

  vpc       = data.ibm_is_vpc.f5_vpc.id
  zone      = var.zone
  keys      = [data.ibm_is_ssh_key.f5_ssh_pub_key.id]
  user_data = data.template_file.user_data.rendered
}


resource "ibm_is_vpc_route" "vip_route" {
  depends_on = [ibm_is_instance.f5_ve_instance]
  for_each = {
    for i, subnet in local.subnets : "${subnet.unique-subnet_id}" => subnet
  }
  name        = "VIP Route - ${each.value.unique-subnet_id}"
  vpc         = data.ibm_is_vpc.f5_vpc.id
  zone        = var.zone
  destination = each.value.vip_route
  next_hop    = each.value.idx == 0 ? ibm_is_instance.f5_ve_instance.primary_network_interface[0].primary_ipv4_address : ibm_is_instance.f5_ve_instance.network_interfaces[each.value.unique-subnet_id].primary_ipv4_address
}

output "locals_sunets" {
  value = local.subnets
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

output "security_groups" {
  value = data.ibm_is_security_group.f5_tmm_sg[*]
}
