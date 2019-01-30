declare vm_name='acit4640'
declare vm_folder='C:\Users\white\Documents\acit4640'
declare size_in_mb=12800
declare ctrlr_name='sorinaisamadgenius'
declare ctrl_type_1="ide"
declare ctrl_type_2="sata"
declare iso_file_path='C:\Users\white\Documents\acit4640\CentOS-7-x86_64-Minimal-1708.iso'
declare port_num=0
declare device_num=0
declare network_name="sys_net_prov"
declare memory_mb=1280


vboxmanage () { VBoxManage.exe "$@"; }

vboxmanage natnetwork add --netname "sys_net_prov" --network "192.168.254.0/24" --dhcp off

vboxmanage natnetwork modify --netname "sys_net_prov" --port-forward-4 "rule_1:tcp:[*]:50022:[192.168.254.10]:22"

vboxmanage natnetwork modify --netname "sys_net_prov" --port-forward-4 "rule_2:tcp:[*]:50080:[192.168.254.10]:80"

vboxmanage natnetwork modify --netname "sys_net_prov" --port-forward-4 "rule_3:tcp:[*]:50443:[192.168.254.10]:443"
