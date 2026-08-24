# Proxmox Host의 root shell 에서 진행
# 1) GenericCloud 이미지 다운로드
cd /var/lib/vz/template/iso
wget https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2

# 2) VM 골격 생성 (디스크 없이 뼈대만)
qm create 9000 --name rocky9-cloudinit-template \
  --memory 2048 --cores 2 --cpu host \
  --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci

# 3) 다운받은 이미지를 storage로 임포트
qm importdisk 9000 Rocky-9-GenericCloud.latest.x86_64.qcow2 local-lvm

# 4) 임포트된 디스크를 scsi0로 연결
qm set 9000 --scsi0 local-lvm:vm-9000-disk-0

# 5) cloud-init 드라이브 추가
qm set 9000 --ide2 local-lvm:cloudinit

# 6) 부팅 순서 + 시리얼 콘솔
qm set 9000 --boot order=scsi0
qm set 9000 --serial0 socket --vga serial0

# 7) QEMU Guest Agent 활성화 (Terraform이 클론 VM의 실제 IP를 읽는 데 필요)
# GenericCloud 이미지는 qemu-guest-agent가 기본 포함돼 있지만, 한 번 부팅해 확인해 두면 나중에 "IP를 못 읽어온다"는 문제를 예방할 수 있다.
qm set 9000 --agent enabled=1

# 8) 임시 부팅 확인
# GenericCloud 이미지는 root가 잠겨 있고 기본 계정이 없어 cloud-init 값 없이는 로그인 자체가 불가능하다.
# 확인용으로만 쓸 임시 계정/비밀번호를 Proxmox 자체 cloud-init 파라미터로 주입한다.
qm set 9000 --ciuser rocky --cipassword 'TempPassw0rd!'
qm start 9000
# 콘솔에서 rocky / TempPassw0rd! 로 로그인 (또는 SSH 키로 접속) 후 qemu-guest-agent 확인
systemctl is-enabled qemu-guest-agent
# 비활성 상태면 qemu-guest-agent 설치 후 활성화
# dnf install -y qemu-guest-agent && systemctl enable --now qemu-guest-agent
# 확인 후 종료
qm shutdown 9000

# 확인용 임시 계정/비밀번호 제거
qm set 9000 --delete cipassword
qm set 9000 --delete ciuser

# 9) 템플릿 전환
qm template 9000