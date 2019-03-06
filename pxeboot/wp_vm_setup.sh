vboxmanage () { VBoxManage.exe "$@"; }

declare vm_name='acit4640_test'
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
declare script_dir='C:\Users\white\Documents\acit4640\deliverables'

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

#-------------------ssd------------------------
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
            --boot2 net\
            --boot3 none\
            --boot4 none\
            --macaddress1 020000000001\
            --memory "${memory_mb}"

vboxmanage startvm ${vm_name} --type gui

scp ${script_dir}/pxeboot/wp_ks.cfg pxe:/usr/share/nginx/html/
scp -r ${script_dir}/setup pxe:/usr/share/nginx/html/
ssh pxe 'sudo chown nginx:wheel /usr/share/nginx/html/wp_ks.cfg'
ssh pxe 'chmod ugo+r /usr/share/nginx/html/wp_ks.cfg'
ssh pxe 'chmod ugo+rx /usr/share/nginx/html/setup'
ssh pxe 'chmod -R ugo+r /usr/share/nginx/html/setup/*'

until [[ $(ssh -q wp exit && echo "online") == "online" ]] ; do
  sleep 10s
  echo "waiting for wp vm to come online"
done
