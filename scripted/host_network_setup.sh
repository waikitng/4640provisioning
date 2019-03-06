vboxmanage () { VBoxManage.exe "$@"; }

vboxmanage natnetwork add --netname "sys_net_prov" --network "192.168.254.0/24" --dhcp off

vboxmanage natnetwork modify --netname "sys_net_prov" --port-forward-4 "rule_1:tcp:[]:50022:[192.168.254.10]:22"

vboxmanage natnetwork modify --netname "sys_net_prov" --port-forward-4 "rule_2:tcp:[]:50080:[192.168.254.10]:80"

vboxmanage natnetwork modify --netname "sys_net_prov" --port-forward-4 "rule_3:tcp:[]:50443:[192.168.254.10]:443"

vboxmanage natnetwork modify --netname "sys_net_prov" --port-forward-4 "rule_4:tcp:[]:50022:[192.168.254.5]:22"
