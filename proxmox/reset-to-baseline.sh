# Proxmox Host의 root shell 에서 진행
# 덤프(문제 세트)를 한 번 다 풀고 나서, 7대 전부를 take-baseline-snapshot.sh로
# 떠둔 "clean-start" 스냅샷 상태로 되돌린다. Terraform state는 그대로 유효하다 —
# VMID/설정은 안 바뀌고 디스크 내용만 되돌아가기 때문에 terraform plan에는 영향이 없다.

SNAP_NAME="clean-start"
VMIDS="9001 9002 9011 9012 9013 9014 9015"

# 1) 롤백 전에 전부 종료 (실행 중이면 rollback이 실패하거나 강제 종료됨)
for vmid in $VMIDS; do
  qm stop "$vmid"
done

# 2) 완전히 꺼졌는지 확인 (status가 stopped로 나올 때까지)
for vmid in $VMIDS; do
  qm status "$vmid"
done

# 3) 스냅샷으로 롤백
for vmid in $VMIDS; do
  qm rollback "$vmid" "$SNAP_NAME"
done

# 4) 다시 시작
for vmid in $VMIDS; do
  qm start "$vmid"
done
