vboxmanage () { VBoxManage.exe "$@"; }

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

#--------------acit4640 creation---------------

vboxmanage createvm --name ${vm_name} --register

vboxmanage createhd --filename ${vm_folder}\\${vm_name}.vdi --size ${size_in_mb} -variant Standard

vboxmanage storagectl ${vm_name} --name "idecontroller" --add ${ctrl_type_1} --bootable on #ide
vboxmanage storagectl ${vm_name} --name "satacontroller" --add ${ctrl_type_2} --bootable on #sata

vboxmanage storageattach ${vm_name} \
            --storagectl "idecontroller" \
            --port ${port_num} \
            --device ${device_num} \
            --type dvddrive \
            --medium ${vm_folder}\\${vm_name}.vdi

vboxmanage storageattach ${vm_name} \
            --storagectl "idecontroller" \
            --port ${port_num} \
            --device ${device_num} \
            --type dvddrive \
            --medium ${iso_file_path}

#-------ssd--------
vboxmanage storageattach ${vm_name} \
            --storagectl "satacontroller" \
            --port $port_num \
            --device $device_num \
            --type hdd \
            --medium ${vm_folder}/${vm_name}.vdi \
            --nonrotational on

vboxmanage modifyvm ${vm_name}\
            --ostype "RedHat_64"\
            --cpus 1\
            --hwvirtex on\
            --nestedpaging on\
            --largepages on\
            --firmware bios\
            --nic1 natnetwork\
            --nat-network1 "${network_name}"\
            --cableconnected1 on\
            --audio none\
            --boot1 disk\
            --boot2 dvd\
            --boot3 none\
            --boot4 none\
            --memory "${memory_mb}"

vboxmanage startvm ${vm_name} --type gui