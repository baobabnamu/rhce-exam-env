# bpg/proxmox 0.111.x 기준 스키마. 다른 버전을 쓰면
# registry.terraform.io/providers/bpg/proxmox/latest/docs 에서 속성명을 재확인할 것.

provider "proxmox" {
  endpoint  = var.pm_api_url
  api_token = var.pm_api_token
  insecure  = var.pm_tls_insecure

  ssh {
    agent    = true
    username = var.pm_ssh_username
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  for_each = var.vms

  name      = each.key
  node_name = var.target_node
  vm_id     = each.value.vm_id
  tags      = ["rhce-lab", each.value.role]

  clone {
    vm_id = var.template_vmid
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = true
    timeout = "2m"
  }

  disk {
    datastore_id = var.storage
    interface    = "scsi0"
    size         = each.value.disk_size
    file_format  = "raw"
  }

  dynamic "disk" {
    for_each = each.value.extra_disk_size != null ? [each.value.extra_disk_size] : []
    content {
      datastore_id = var.storage
      interface    = "scsi1"
      size         = disk.value
      file_format  = "raw"
    }
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    datastore_id = var.storage

    ip_config {
      ipv4 {
        address = "${var.ip_prefix_base}.${each.value.ip_octet}/${var.ip_cidr}"
        gateway = var.ip_gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = var.ci_user
      keys     = [var.ssh_public_key]
    }
  }

  lifecycle {
    ignore_changes = [
      clone,
    ]
  }
}
