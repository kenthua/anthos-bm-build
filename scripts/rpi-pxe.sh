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
sysctl -w net.ipv4.ip_forward=1
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
echo "port=0
interface=eth0
dhcp-range=10.10.0.10,10.10.0.200,12h
dhcp-option=6,8.8.8.8,192.168.1.1
dhcp-option=66,10.10.0.1
dhcp-option=67,pxelinux.0
log-queries
log-facility=/var/log/dnsmasq.log" | sudo tee -a /etc/dnsmasq.conf

#https://askubuntu.com/questions/1235723/automated-20-04-server-installation-using-pxe-and-live-server-image`

apt-get -y install tftpd-hpa apache2

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



curl -OL https://releases.ubuntu.com/20.04/${UBUNTU_ISO}
curl -OL http://archive.ubuntu.com/ubuntu/dists/focal/main/uefi/grub2-amd64/current/grubnetx64.efi.signed
sudo cp grubnetx64.efi.signed ${TFTP_ROOT}/pxelinux.0

mkdir -p ${TMP_PATH}
sudo mount ${TFTP_ROOT}/${UBUNTU_ISO} ${TMP_PATH}
sudo cp ${TMP_PATH}/casper/vmlinuz ${TFTP_ROOT}
sudo cp ${TMP_PATH}/casper/initrd ${TFTP_ROOT}
sudo umount ${TMP_PATH}

sudo mkdir -p ${TFTP_ROOT}/grub
echo "default=autoinstall
timeout=30
timeout_style=menu
menuentry \"Focal Live Installer - automate\" --id=autoinstall {
    echo \"Loading Kernel...\"
    # make sure to escape the ';'
    linux /vmlinuz ip=dhcp url=http://\${pxe_default_server}/tftp/${UBUNTU_ISO} autoinstall ds=nocloud-net\;s=http://${pxe_default_server}/tftp/
    echo \"Loading Ram Disk...\"
    initrd /initrd
}
menuentry \"Focal Live Installer\" --id=install {
    echo \"Loading Kernel...\"
    linux /vmlinuz ip=dhcp url=http://\${pxe_default_server}/tftp/${UBUNTU_ISO}
    echo \"Loading Ram Disk...\"
    initrd /initrd
}" | sudo tee ${TFTP_ROOT}/grub/grub.cfg

echo "instance-id: focal-autoinstall" | sudo tee ${TFTP_ROOT}/meta-data

# https://ubuntu.com/server/docs/install/autoinstall

echo "#cloud-config
autoinstall:
  version: 1
  apt:
    # even set to no/false, geoip lookup still happens
    #geoip: no
    preserve_sources_list: false
    primary:
    - arches: [amd64, i386]
      uri: http://us.archive.ubuntu.com/ubuntu
    - arches: [default]
      uri: http://ports.ubuntu.com/ubuntu-ports
  # r00tme
  identity:
    hostname: node
    password: \"\$6\$ZoP3olp8Tg3ygmEm\$VFq3UDGbz6Sl.UCpEzZPicnYDaHn3lEqsjpwJwwKFNBlAcZpD5yns1uCI5fkfKjHDPkwGNEAEdbFjNoY2NjP/0\"
    username: ubuntu
  keyboard:
    layout: us
    variant: \"\"
  locale: en_US
  # interface name will probably be different
  network:
    network:
      version: 2
      ethernets:
        ens192:
          critical: true
          dhcp-identifier: mac
          dhcp4: true
  user-data:
    timezone: America/Los_Angeles
    disable_root: false
    chpasswd:
      list: |
        root:\"\$6\$ZoP3olp8Tg3ygmEm\$VFq3UDGbz6Sl.UCpEzZPicnYDaHn3lEqsjpwJwwKFNBlAcZpD5yns1uCI5fkfKjHDPkwGNEAEdbFjNoY2NjP/0\"
  ssh:
    allow-pw: true
    authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCquwVARyLFDuKZcuvpXZbJB/vlPz4yJpAjwsyltri40MoqAGwhSqz8kHycHBA7/wPDglIj6W6YGnvT3tXkyqhZD23zix6Q9RryCw3mVCjQzyMU0TbU3JkrJpgaekw+nmlRXY4DJ/4CdPnS3KdEvCYHEStFEaYutv0vNajqVNYlDFqo4/w60YRedd8eTf8AIbMurUcfgEmVk+lx0vVQhgMOzLHEUMhOeZEnPfheOX+/JGsuiAFiAwH6XVQuPmddNCjyxj7uC05SZQRt+KaeW6pVKjE2FAyNBpnVJpb1azWtPzs+BMLJbrctQd4NRkMCkPFDSW7O35nwDBsqgdt09XxM4kZlYCIUfZIf6Cm5Tyjrrv/ifgXnZikFIqieyFW34KaIvSmD9MGE4qhC1wR2sdTzaGYwrVy3UXc6u4ikrRj9TuZJWYHXJqw67EAgXw18YKszWRHEzlwALc32/jEplO0Ydfx+inauw8QNEXm+5Yce2nAGe93+Mbo6JWMZT4wviBR8LGlnhSLcUZIDRQo8oA+RVvZmvfn+XznITU6wA0armyswuWm1Vko5rkwISqIHQhLEkt6JCO8aX2YnsWlCb6bw+1E+OHH0rxhp2FIXeBk+12EfXNh7N/SYM5OVsyjvTbB/Otzl2qWFkL7ka15/ynXX75nlKnSIVrsiAjSAUy8GpQ== user
    install-server: true
  # this creates an efi partition, /boot partition, and root(/) lvm volume
  storage:
    grub:
      reorder_uefi: False
    swap:
      size: 0
    config:
    - {ptable: gpt,
      path: /dev/nvme0n1, wipe: superblock, preserve: false, name: '', grub_device: false,
      type: disk, id: disk-nvme0n1}
    - {device: disk-nvme0n1, size: 536870912, wipe: superblock, flag: boot, number: 1,
      preserve: false, grub_device: true, type: partition, id: partition-0}
    - {fstype: fat32, volume: partition-0, preserve: false, type: format, id: format-0}
    - {device: disk-nvme0n1, size: 1073741824, wipe: superblock, flag: '', number: 2,
      preserve: false, type: partition, id: partition-1}
    - {fstype: ext4, volume: partition-1, preserve: false, type: format, id: format-1}
    - {device: disk-nvme0n1, size: 248446451712, wipe: superblock, flag: '', number: 3,
      preserve: false, type: partition, id: partition-2}
    - name: ubuntu-vg
      devices: [partition-2]
      preserve: false
      type: lvm_volgroup
      id: lvm_volgroup-0
    - {name: ubuntu-lv, volgroup: lvm_volgroup-0, size: 124222701568B, preserve: false,
      type: lvm_partition, id: lvm_partition-0}
    - {fstype: ext4, volume: lvm_partition-0, preserve: false, type: format, id: format-2}
    - {device: format-2, path: /, type: mount, id: mount-2}
    - {device: format-1, path: /boot, type: mount, id: mount-1}
    - {device: format-0, path: /boot/efi, type: mount, id: mount-0}" | sudo tee ${TFTP_ROOT}/user-data









###
# isc-dhcp-server
###
sudo apt-get update
sudo apt-get -y install isc-dhcp-server

# make the rpi the authoritative dhcp server
sudo sed -i "/^#authoritative;/a\authoritative;" /etc/dhcp/dhcpd.conf

echo "subnet 10.10.0.0 netmask 255.255.255.0 {
  range 10.10.0.10 10.10.0.200;
  option routers 10.10.0.1;
  option domain-name "bm";
  option domain-name-servers 8.8.8.8, 8.8.4.4;
}" | sudo tee -a /etc/dhcp/dhcpd.conf

# only do dhcp for ipv4 on eth0, leaving wlan0 alone
sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/1 /etc/default/isc-dhcp-server
