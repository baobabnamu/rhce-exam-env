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

variable "network_bridge" {
  description = "VM 네트워크에 연결할 브리지"
  type        = string
  default     = "vmbr0"
}

variable "ip_prefix_base" {
  description = "IP 앞 3개 옥텟, 예: 192.168.10 -> vms 맵의 ip_octet과 합쳐서 192.168.10.X 생성"
  type        = string
}

variable "ip_cidr" {
  description = "서브넷 프리픽스 길이"
  type        = number
  default     = 24
}

variable "ip_gateway" {
  description = "게이트웨이 IP"
  type        = string
}

variable "dns_servers" {
  description = "VM에 설정할 DNS 서버 목록"
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}

variable "ci_user" {
  description = "cloud-init으로 생성할 관리 계정 (ansible_user로 사용)"
  type        = string
  default     = "ansible"
}

variable "ssh_public_key" {
  description = "위 ci_user 계정에 등록할 공개키 내용 (예: file(\"~/.ssh/id_ed25519.pub\") 로 전달)"
  type        = string
}

variable "vms" {
  description = "생성할 VM 정의: controller 1대 + node 5대. RHCE 실습용 기본 스펙이 들어가 있음."
  type = map(object({
    vm_id           = number
    role            = string # "controller" | "node"
    cores           = number
    memory          = number # MiB
    disk_size       = number # GiB, OS 디스크
    extra_disk_size = optional(number) # GiB, LVM/스토리지 실습용 추가 디스크
    ip_octet        = number # ip_prefix_base 뒤에 붙는 마지막 옥텟
  }))

  default = {
    "rhce-controller" = {
      vm_id     = 9001
      role      = "controller"
      cores     = 2
      memory    = 2048
      disk_size = 20
      ip_octet  = 110
    }
    "rhce-node1" = {
      vm_id           = 9011
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      ip_octet        = 111
    }
    "rhce-node2" = {
      vm_id           = 9012
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      ip_octet        = 112
    }
    "rhce-node3" = {
      vm_id           = 9013
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      ip_octet        = 113
    }
    "rhce-node4" = {
      vm_id           = 9014
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      ip_octet        = 114
    }
    "rhce-node5" = {
      vm_id           = 9015
      role            = "node"
      cores           = 1
      memory          = 2048
      disk_size       = 15
      extra_disk_size = 10
      ip_octet        = 115
    }
  }
}
