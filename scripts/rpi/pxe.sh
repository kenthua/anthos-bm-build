#!/bin/bash

#setup rpi

#setup /boot/ssh
#setup /boot/wpa_supplicant.conf

ssh-keygen -t rsa -b 4096 -C "user"

sudo raspi-config
#expand fs
#change hostname

# force eth0 to static
echo "interface eth0
static ip_address=10.10.0.1/24
static domain_name_servers=8.8.8.8" | sudo tee -a /etc/dhcpcd.conf

# enable port forwarding
sudo sysctl -w net.ipv4.ip_forward=1
# persistent
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# enable forwarding eth0 traffic through wlan0
# https://serverfault.com/questions/152363/bridging-wlan0-to-eth0
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

sudo apt-get install -y iptables-persistent

sudo apt-get -y install dnsmasq

TFTP_ROOT=/var/lib/tftpboot
UBUNTU_ISO=ubuntu-20.04.1-live-server-amd64.iso
TMP_PATH=/tmp/ubuntu

mkdir -p ${TFTP_ROOT}
echo "
# custom settings
interface=eth0
dhcp-range=10.10.0.10,10.10.0.200,12h
dhcp-option=6,10.10.0.1,8.8.8.8,192.168.1.1
dhcp-option=66,10.10.0.1
dhcp-option=67,pxelinux.0
log-queries
log-facility=/var/log/dnsmasq.log
expand-hosts
domain=anthos.cloud
local=/anthos.cloud/
#addn-hosts=/etc/dnsmasq_static_hosts.conf
dhcp-host=1c:69:7a:6f:b8:af,10.10.0.11,node01
dhcp-host=1c:69:7a:6f:9f:27,10.10.0.12,node02
dhcp-host=1c:69:7a:6f:ba:c1,10.10.0.13,node03
dhcp-host=1c:69:7a:6f:c0:a9,10.10.0.14,node04
dhcp-host=1c:69:7a:6f:ba:2c,10.10.0.15,node05
" | sudo tee -a /etc/dnsmasq.conf

#https://askubuntu.com/questions/1235723/automated-20-04-server-installation-using-pxe-and-live-server-image

sudo apt-get -y install tftpd-hpa apache2

echo "# /etc/default/tftpd-hpa
TFTP_USERNAME=\"tftp\"
TFTP_DIRECTORY=\"/var/lib/tftpboot\"
TFTP_ADDRESS=\"10.10.0.1:69\"
TFTP_OPTIONS=\"--secure\"" | sudo tee /etc/default/tftpd-hpa

echo "<Directory /var/lib/tftpboot>
        Options +FollowSymLinks +Indexes
        Require all granted
</Directory>
Alias /tftp /var/lib/tftpboot" | sudo tee /etc/apache2/conf-available/tftp.conf

sudo a2enconf tftp

sudo curl -L https://releases.ubuntu.com/20.04/${UBUNTU_ISO} -o ${TFTP_ROOT}/${UBUNTU_ISO}
sudo curl -L http://archive.ubuntu.com/ubuntu/dists/focal/main/uefi/grub2-amd64/current/grubnetx64.efi.signed -o ${TFTP_ROOT}/pxelinux.0

mkdir -p ${TMP_PATH}
sudo mount ${TFTP_ROOT}/${UBUNTU_ISO} ${TMP_PATH}
sudo cp ${TMP_PATH}/casper/vmlinuz ${TFTP_ROOT}
sudo cp ${TMP_PATH}/casper/initrd ${TFTP_ROOT}
sudo umount ${TMP_PATH}

sudo mkdir -p ${TFTP_ROOT}/grub
echo "default=autoinstall
timeout=5
timeout_style=menu
menuentry \"Focal Live Installer - automate\" --id=autoinstall {
    echo \"Loading Kernel...\"
    # make sure to escape the ';'
    linux /vmlinuz ip=dhcp url=http://\${pxe_default_server}/tftp/${UBUNTU_ISO} autoinstall ds=nocloud-net\;s=http://\${pxe_default_server}/tftp/
    echo \"Loading Ram Disk...\"
    initrd /initrd
}
menuentry \"Focal Live Installer\" --id=install {
    echo \"Loading Kernel...\"
    linux /vmlinuz ip=dhcp url=http://\${pxe_default_server}/tftp/${UBUNTU_ISO}
    echo \"Loading Ram Disk...\"
    initrd /initrd
}" | sudo tee ${TFTP_ROOT}/grub/grub.cfg

sudo touch ${TFTP_ROOT}/meta-data
#echo "instance-id: focal-autoinstall" | sudo tee ${TFTP_ROOT}/meta-data

# https://ubuntu.com/server/docs/install/autoinstall

echo "#cloud-config
autoinstall:
  # encrypted pw == passw0rd
  identity: {hostname: node, password: \$6\$VzsMBQNG.jLDEFAp\$IseeLgTaGWnZaktBfN0RvoG7GSf7ra3rEo4FO4nXq.h25GoxLLHWZjfv/e8MBbojAzcKaagy2qAcApVKoFh3F/,
    realname: ubuntu, username: ubuntu}
  keyboard: {layout: us, toggle: null, variant: ''}
  locale: en_US
  reporting:
    builtin:
      type: print
  # change to your pub key
  ssh: {allow-pw: true, authorized-keys: ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCquwVARyLFDuKZcuvpXZbJB/vlPz4yJpAjwsyltri40MoqAGwhSqz8kHycHBA7/wPDglIj6W6YGnvT3tXkyqhZD23zix6Q9RryCw3mVCjQzyMU0TbU3JkrJpgaekw+nmlRXY4DJ/4CdPnS3KdEvCYHEStFEaYutv0vNajqVNYlDFqo4/w60YRedd8eTf8AIbMurUcfgEmVk+lx0vVQhgMOzLHEUMhOeZEnPfheOX+/JGsuiAFiAwH6XVQuPmddNCjyxj7uC05SZQRt+KaeW6pVKjE2FAyNBpnVJpb1azWtPzs+BMLJbrctQd4NRkMCkPFDSW7O35nwDBsqgdt09XxM4kZlYCIUfZIf6Cm5Tyjrrv/ifgXnZikFIqieyFW34KaIvSmD9MGE4qhC1wR2sdTzaGYwrVy3UXc6u4ikrRj9TuZJWYHXJqw67EAgXw18YKszWRHEzlwALc32/jEplO0Ydfx+inauw8QNEXm+5Yce2nAGe93+Mbo6JWMZT4wviBR8LGlnhSLcUZIDRQo8oA+RVvZmvfn+XznITU6wA0armyswuWm1Vko5rkwISqIHQhLEkt6JCO8aX2YnsWlCb6bw+1E+OHH0rxhp2FIXeBk+12EfXNh7N/SYM5OVsyjvTbB/Otzl2qWFkL7ka15/ynXX75nlKnSIVrsiAjSAUy8GpQ== user'], install-server: true}
  late-commands:
  - echo \"ubuntu ALL=(ALL:ALL) NOPASSWD:ALL\" > /target/etc/sudoers.d/ubuntu 
  - chmod 440 /target/etc/sudoers.d/ubuntu 
  version: 1" | sudo tee ${TFTP_ROOT}/user-data

sudo systemctl enable tftpd-hpa
sudo systemctl start tftpd-hpa
sudo systemctl enable apache2
sudo systemctl start apache2


#####################
## isc-dhcp-server if not using dnsmasq
#####################
sudo apt-get update
sudo apt-get -y install isc-dhcp-server

echo "authoritative
subnet 10.10.0.0 netmask 255.255.255.0 {
  range 10.10.0.10 10.10.0.200;
  option routers 10.10.0.1;
  option domain-name \"bm\";
  option domain-name-servers 8.8.8.8, 192.168.86.1;
}
option tftp-server-name \"10.10.0.1\";
option bootfile-name \"pxelinux.0\";
" | sudo tee -a /etc/dhcp/dhcpd.conf

# only do dhcp for ipv4 on eth0, leaving wlan0 alone
sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/1 /etc/default/isc-dhcp-server

# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian
echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt update
sudo apt install ansible



# wipe disk fdisk - fast just wipe parition table
echo "d
3
d
2
d

w" | sudo fdisk /dev/nvme0n1

# wipe disk dd -- ctrl-c after a few sec
sudo dd if=/dev/zero of=/dev/nvme0n1 bs=1M
