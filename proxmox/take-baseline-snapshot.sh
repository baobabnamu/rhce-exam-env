# Proxmox Host의 root shell 에서 진행
# "시험 시작 직전" 상태(Controller 비어있음, Utility 구성 완료, Node 저장소 전환 완료)를
# 7대 전부 스냅샷으로 떠둔다. 이후 문제를 다 풀고 나면 이 스냅샷으로 되돌려서 재도전한다.
#
# Terraform destroy/apply로 다시 만드는 것보다 이 방식을 쓰는 이유:
# Utility의 BaseOS/AppStream 미러(수십 GB)는 VM을 새로 만들면 처음부터 다시 받아야 한다.
# 스냅샷 롤백은 디스크 상태만 되돌리므로 그 미러링을 다시 할 필요가 없다.

SNAP_NAME="clean-start"
VMIDS="9001 9002 9011 9012 9013 9014 9015"

for vmid in $VMIDS; do
  qm snapshot "$vmid" "$SNAP_NAME" \
    --description "시험 시작 전 상태: Controller에 ansible 없음, Utility DNS/NTP/repo 구성 완료, Node는 Utility 저장소만 봄"
done

# 확인
for vmid in $VMIDS; do
  echo "--- vmid $vmid ---"
  qm listsnapshot "$vmid"
done
