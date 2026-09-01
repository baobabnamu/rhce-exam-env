variable "pm_api_url" {
  description = "Proxmox API endpoint, e.g. https://proxmox.example.com:8006/api2/json"
  type        = string
}

variable "pm_api_token" {
  description = "Proxmox API token, format: user@realm!tokenid=uuid"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "자체 서명 인증서를 쓰는 홈랩이면 true"
  type        = bool
  default     = true
}

variable "pm_ssh_username" {
  description = "bpg/proxmox provider가 노드에 SSH로 접속할 때 쓰는 계정 (파일 업로드 등 API로 안 되는 작업에 필요)"
  type        = string
  default     = "root"
}

variable "target_node" {
  description = "VM을 생성할 Proxmox 노드 이름 (pvesh get /nodes 로 확인)"
  type        = string
}

variable "template_vmid" {
  description = "클론할 RHEL/Rocky/AlmaLinux cloud-init 템플릿의 VMID"
  type        = number
}

variable "storage" {
  description = "디스크를 생성할 datastore 이름"
  type        = string
  default     = "local-lvm"
}

variable "isolated_bridge" {
  description = "Managed Node용 격리 네트워크 브릿지 (업링크 없는 순수 브릿지, proxmox/add-isolated-bridge.sh 로 생성)"
  type        = string
  default     = "vmbr1"
}

variable "ci_user" {
  description = "cloud-init으로 생성할 관리 계정 (ansible_user로 사용). 실제 RHCE 시험 계정명이 admin이라 기본값도 admin으로 맞춤"
  type        = string
  default     = "admin"
}

variable "ssh_public_key" {
  description = "위 ci_user 계정에 등록할 공개키 내용 (예: file(\"~/.ssh/id_rsa.pub\") 로 전달)"
  type        = string
}

variable "vms" {
  description = "생성할 VM 정의: controller 1대 + utility 1대 + node 5대. controller/utility는 홈랩(vmbr0)+격리망(vmbr1) 이중 NIC, node는 격리망(vmbr1) 단일 NIC."
  type = map(object({
    vm_id           = number
    role            = string # "controller" | "utility" | "node"
    cores           = number
    memory          = number # MiB
    disk_size       = number # GiB, OS 디스크
    extra_disk_size = optional(number) # GiB, LVM/스토리지 실습용 추가 디스크 (node 전용)
    dns_servers     = list(string)
    networks = list(object({
      bridge  = string
      address = string            # CIDR, 예: "192.168.0.110/24"
      gateway = optional(string)  # 격리망 NIC는 생략 = 게이트웨이 없음(진짜 오프라인)
    }))
  }))

  default = {
    "rhce-controller" = {
      vm_id       = 9001
      role        = "controller"
      cores       = 2
      memory      = 2048
      disk_size   = 20
      dns_servers = ["192.168.0.1"]
      networks = [
        { bridge = "vmbr0", address = "192.168.0.110/24", gateway = "192.168.0.1" },
        { bridge = "vmbr1", address = "172.16.0.10/24" },
      ]
    }
    "rhce-utility" = {
      vm_id       = 9002
      role        = "utility"
      cores       = 2
      memory      = 2048
      disk_size   = 60 # reposync로 받는 BaseOS+AppStream 저장소 용량 확보
      dns_servers = ["192.168.0.1"]
      networks = [
        { bridge = "vmbr0", address = "192.168.0.111/24", gateway = "192.168.0.1" },
        { bridge = "vmbr1", address = "172.16.0.1/24" },
      ]
    }
    "rhce-node1" = {
      vm_id           = 9011
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      dns_servers     = ["172.16.0.1"]
      networks        = [{ bridge = "vmbr1", address = "172.16.0.11/24" }]
    }
    "rhce-node2" = {
      vm_id           = 9012
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      dns_servers     = ["172.16.0.1"]
      networks        = [{ bridge = "vmbr1", address = "172.16.0.12/24" }]
    }
    "rhce-node3" = {
      vm_id           = 9013
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      dns_servers     = ["172.16.0.1"]
      networks        = [{ bridge = "vmbr1", address = "172.16.0.13/24" }]
    }
    "rhce-node4" = {
      vm_id           = 9014
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      dns_servers     = ["172.16.0.1"]
      networks        = [{ bridge = "vmbr1", address = "172.16.0.14/24" }]
    }
    "rhce-node5" = {
      vm_id           = 9015
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      dns_servers     = ["172.16.0.1"]
      networks        = [{ bridge = "vmbr1", address = "172.16.0.15/24" }]
    }
  }
}
