#!/bin/bash

#setup rpi

#setup /boot/ssh
#setup /boot/wpa_supplicant.conf

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

#https://askubuntu.com/questions/1235723/automated-20-04-server-installation-using-pxe-and-live-server-image

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

echo "#cloud-config
autoinstall:
  version: 1
  # use interactive-sections to avoid an automatic reboot
  #interactive-sections:
  #  - locale
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
  identity: {hostname: focal-autoinstall, password: HASHEDPASSWORD,
    username: ubuntu}
  keyboard: {layout: us, variant: ''}
  locale: en_US.UTF-8
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
        root:HASHEDPASSWORD
  ssh:
    allow-pw: true
    authorized-keys: []
    install-server: true
  # this creates an efi partition, /boot partition, and root(/) lvm volume
  storage:
    grub:
      reorder_uefi: False
    swap:
      size: 0
    config:
    - {ptable: gpt, path: /dev/sda, preserve: false, name: '', grub_device: false,
      type: disk, id: disk-sda}
    - {device: disk-sda, size: 536870912, wipe: superblock, flag: boot, number: 1,
      preserve: false, grub_device: true, type: partition, id: partition-sda1}
    - {fstype: fat32, volume: partition-sda1, preserve: false, type: format, id: format-2}
    - {device: disk-sda, size: 1073741824, wipe: superblock, flag: linux, number: 2,
      preserve: false, grub_device: false, type: partition, id: partition-sda2}
    - {fstype: ext4, volume: partition-sda2, preserve: false, type: format, id: format-0}
    - {device: disk-sda, size: -1, flag: linux, number: 3, preserve: false,
      grub_device: false, type: partition, id: partition-sda3}
    - name: vg-0
      devices: [partition-sda3]
      preserve: false
      type: lvm_volgroup
      id: lvm-volgroup-vg-0
    - {name: lv-root, volgroup: lvm-volgroup-vg-0, size: 100%, preserve: false,
      type: lvm_partition, id: lvm-partition-lv-root}
    - {fstype: ext4, volume: lvm-partition-lv-root, preserve: false, type: format,
      id: format-1}
    - {device: format-1, path: /, type: mount, id: mount-2}
    - {device: format-0, path: /boot, type: mount, id: mount-1}
    - {device: format-2, path: /boot/efi, type: mount, id: mount-3}
write_files:
  # override the kernel package
  - path: /run/kernel-meta-package
    content: |
      linux-virtual
    owner: root:root
    permissions: \"0644\"" | sudo tee ${TFTP_ROOT}/user-data









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