# Proxmox Host의 root shell 에서 진행
# Managed Node 전용 격리 네트워크(vmbr1)를 만든다.
# 업링크(bridge-ports)가 없는 순수 브릿지라 그 자체로 인터넷/홈랜과 완전히 분리된다.
# SDN이 아니라 일반 Linux 브릿지라 별도 권한(SDN.Use 등) 추가가 필요 없다.

# 1) vmbr1 이름이 이미 쓰이고 있지 않은지 확인
ip -br link show type bridge

# 2) /etc/network/interfaces 에 격리 브릿지 추가
cat >> /etc/network/interfaces <<'EOF'

auto vmbr1
iface vmbr1 inet manual
    bridge-ports none
    bridge-stp off
    bridge-fd 0
#Isolated network for RHCE lab managed nodes (no uplink)
EOF

# 3) 재부팅 없이 적용
ifreload -a

# 4) 확인
ip -br link show vmbr1
