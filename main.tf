terraform {
  required_providers {
    arvan = {
      source = "terraform.arvancloud.ir/arvancloud/iaas"
    }
  }
}

provider "arvan" {
  api_key = "apikey df486d58-0cd8-572a-9d01-ab1d4f9a5655"
}

variable "region" {
  type        = string
  description = "The chosen region for resources"
  default     = "ir-thr-fr1"
}

variable "chosen_distro_name" {
  type        = string
  description = " The chosen distro name for image"
  default     = "ubuntu"
}

variable "chosen_name" {
  type        = string
  description = "The chosen release for image"
  default     = "22.04"
}

variable "chosen_network_name" {
  type        = string
  description = "The chosen name of network"
  default     = "public201" //public202
}

variable "chosen_plan_id" {
  type        = string
  description = "The chosen ID of plan"
  default     = "g1-2-2-0"
}

# variable "chosen_server_group_id" {
#   type        = string
#   description = "The chosen ID of Server Group"
#   default     = "Staging"
# }

data "arvan_images" "terraform_image" {
  region     = var.region
  image_type = "distributions" // or one of: arvan, private
}

data "arvan_plans" "plan_list" {
  region = var.region
}

# data "arvan_server_groups" "server_group_list" {
#   region = var.region
# }

locals {
  chosen_image = try(
    [for image in data.arvan_images.terraform_image.distributions : image
    if image.distro_name == var.chosen_distro_name && image.name == var.chosen_name],
    []
  )

  selected_plan = [for plan in data.arvan_plans.plan_list.plans : plan if plan.id == var.chosen_plan_id][0]

  # chosen_server_group = [for server_group in data.arvan_server_groups.server_group_list.server_groups : server_group if server_group.id == var.chosen_server_group_id][0]
}

resource "arvan_security_group" "terraform_security_group" {
  region      = var.region
  description = "Terraform-created security group"
  name        = "stage_security_group"
  rules = [
    {
      direction = "ingress"
      protocol  = "icmp"
    },
    {
      direction = "ingress"
      protocol  = "udp"
    },
    {
      direction = "ingress"
      protocol  = "tcp"
    },
    {
      direction = "egress"
      protocol  = ""
    }
  ]
}

data "arvan_networks" "staging_network" {
  region = var.region
}

locals {
  network_list = tolist(data.arvan_networks.staging_network.networks)
  chosen_network = try(
    [for network in local.network_list : network
    if network.name == var.chosen_network_name],
    []
  )
}

output "chosen_network" {
  value = local.chosen_network
}

resource "arvan_network" "staging_private_network" {
  region      = var.region
  description = "Staging private network"
  name        = "staging_Private_Net"
  # dhcp_range = {
  #   start = "10.0.0.101"
  #   end   = "10.0.0.200"
  # }
  # dns_servers    = ["9.9.9.9", "1.1.1.1"]
  enable_dhcp    = false
  enable_gateway = false
  cidr           = "10.0.0.0/24"
  gateway_ip     = "10.0.0.1"
}

resource "arvan_abrak" "Controller-Node" {
  depends_on = [arvan_network.staging_private_network, arvan_security_group.terraform_security_group]
  timeouts {
    create = "1h30m"
    update = "2h"
    delete = "20m"
    read   = "10m"
  }
  region    = var.region
  name      = "Controller-Node"
  count     = 1
  image_id  = local.chosen_image[0].id
  flavor_id = local.selected_plan.id
  disk_size = 30
  # server_group_id = local.chosen_server_group.id //optional
  networks = [
    {
      network_id = local.chosen_network[0].network_id
    },
    {
      network_id = arvan_network.staging_private_network.network_id
    }
  ]
  security_groups = [arvan_security_group.terraform_security_group.id]
}

resource "arvan_abrak" "Compute-Node" {
  depends_on = [arvan_network.staging_private_network, arvan_security_group.terraform_security_group]
  timeouts {
    create = "1h30m"
    update = "2h"
    delete = "20m"
    read   = "10m"
  }
  region    = var.region
  name      = "Compute-Node-${count.index}"
  count     = 2
  image_id  = local.chosen_image[0].id
  flavor_id = local.selected_plan.id
  disk_size = 30
  # server_group_id = local.chosen_server_group.id //optional
  networks = [
    # {
    #   network_id = local.chosen_network[0].network_id
    # },
    {
      network_id = arvan_network.staging_private_network.network_id
    }
  ]
  security_groups = [arvan_security_group.terraform_security_group.id]
}

resource "arvan_abrak" "Network-Node" {
  depends_on = [arvan_network.staging_private_network, arvan_security_group.terraform_security_group]
  timeouts {
    create = "1h30m"
    update = "2h"
    delete = "20m"
    read   = "10m"
  }
  region    = var.region
  name      = "Network-Node"
  count     = 1
  image_id  = local.chosen_image[0].id
  flavor_id = local.selected_plan.id
  disk_size = 30
  # server_group_id = local.chosen_server_group.id //optional
  networks = [
    {
      network_id = local.chosen_network[0].network_id
    },
    {
      network_id = arvan_network.staging_private_network.network_id
    }
  ]
  security_groups = [arvan_security_group.terraform_security_group.id]
}

resource "arvan_abrak" "Monitoring-Node" {
  depends_on = [arvan_network.staging_private_network, arvan_security_group.terraform_security_group]
  timeouts {
    create = "1h30m"
    update = "2h"
    delete = "20m"
    read   = "10m"
  }
  region    = var.region
  name      = "Network-Node"
  count     = 1
  image_id  = local.chosen_image[0].id
  flavor_id = local.selected_plan.id
  disk_size = 25
  # server_group_id = local.chosen_server_group.id //optional
  networks = [
    {
      network_id = local.chosen_network[0].network_id
    },
    {
      network_id = arvan_network.staging_private_network.network_id
    }
  ]
  security_groups = [arvan_security_group.terraform_security_group.id]
}

output "instances" {
  value = [
    arvan_abrak.Controller-Node,
    arvan_abrak.Compute-Node,
    arvan_abrak.Network-Node,
    arvan_abrak.Monitoring-Node
  ]
}
