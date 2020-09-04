variable "zone" {
  default     = "eu-de-1"
  description = ""
}

variable "vpc_name" {
  default     = "vpc-frankfurt"
  description = ""
}

variable "instance_name" {
  default     = "f5-ve-01"
  description = ""
}

variable "resource_group_name" {
  default     = "rg-frankfurt"
  description = ""
}

variable "instance_profile" {
  default     = "cx2-2x4"
  description = "The profile of compute CPU and memory resources to be used when provisioning F5 BIG-IP instance. To list available profiles, run `ibmcloud is profiles`."
}

variable "ssh_key_name" {
  default     = ""
  description = "The name of the public SSH key (VPC Gen 2 SSH Key) to be used when provisioning the F5 BIG-IP instance.  To list available keys, run `ibmcloud is keys`."
}

variable "tmos_license_basekey" {
  default     = ""
  description = "Base registration key for the F5 BIG-IP instance."
}

variable "tmos_admin_password" {
  default     = ""
  description = "'admin' account password for the F5 BIG-IP instance."
}

variable "phone_home_url" {
  default = ""
}

variable "vnf_vpc_image_name" {
  default     = ""
  description = "The name of the F5-BIGIP custom image to be used for this instance in your IBM Cloud account."
}

variable "TF_VERSION" {
  default     = "0.12"
  description = "terraform engine version to be used in schematics"
}

variable "subnets" {
  type = list(object({
    subnet_id           = string
    nic_name            = string
    security_group_name = string
    vip_route           = string
  }))
  default = [
    {
      subnet_id           = ""
      nic_name            = ""
      security_group_name = ""
      vip_route           = ""
    }
  ]
  description = "VPC Gen2 subnet ID for the TMOS instance and the associated route to the VIP."
}

