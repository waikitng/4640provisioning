#--------------acit4640 creation---------------

vboxmanage createvm --name ${vm_name} --register

vboxmanage createhd --filename ${vm_folder}/${vm_name}.vdi --size ${size_in_mb} -variant Standard

vboxmanage storagectl ${vm_name} --name "idecontroller" --add ${ctrl_type_1} --bootable on #ide
vboxmanage storagectl ${vm_name} --name "satacontroller" --add ${ctrl_type_2} --bootable on #sata

vboxmanage storageattach ${vm_name} \
            --storagectl "idecontroller" \
            --port ${port_num} \
            --device ${device_num} \
            --type hdd \
            --medium ${vm_folder}/${vm_name}.vdi

vboxmanage storageattach ${vm_name} \
            --storagectl "idecontroller" \
            --port ${port_num} \
            --device ${device_num} \
            --type hdd \
            --medium ${iso_file_path}

vboxmanage storageattach ${vm_name} \
            --storagectl "satacontroller" \
            --port $port_num \
            --device $device_num \
            --type dvddrive \
            --medium ${vm_folder}/${vm_name}.vdi \
            --nonrotational on

vboxmanage modifyvm ${vm_name}\
            --groups "${group_name}"\
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