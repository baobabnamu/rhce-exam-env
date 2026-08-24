#!/bin/bash

# Proxmox Host 환경에서 Terraform Provisioner 전용 사용자 및 권한 설정 스크립트

# 1) 최소 권한 role 생성
pveum role add TerraformProvisioner -privs "VM.Allocate,VM.Clone,VM.Config.CDROM,\
VM.Config.CPU,VM.Config.Cloudinit,VM.Config.Disk,VM.Config.Memory,\
VM.Config.Network,VM.Config.Options,VM.Audit,VM.PowerMgmt,\
Datastore.AllocateSpace,Datastore.AllocateTemplate,Datastore.Audit,\
Sys.Audit,Sys.Console,Sys.Modify,SDN.Use"

# 2) 전용 사용자 생성 + 권한 부여
pveum user add terraform@pve --comment "Terraform automation"
pveum aclmod / -user terraform@pve -role TerraformProvisioner

# 3) API 토큰 발급 (privsep 0 = 토큰이 사용자 권한을 그대로 상속)
pveum user token add terraform@pve provisioning --privsep 0