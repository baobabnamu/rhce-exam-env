[controller]
${controller_name} ansible_host=${controller_ip}

[nodes]
%{ for name, ip in nodes ~}
${name} ansible_host=${ip}
%{ endfor ~}

[all:vars]
ansible_user=${ci_user}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
