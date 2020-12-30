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
#static routers=192.168.86.1
static domain_name_servers=8.8.8.8" | sudo tee -a /etc/dhcpcd.conf

# fix routing?
# https://serverfault.com/questions/123553/how-to-set-the-preferred-network-interface-in-linux

# https://linuxconfig.org/how-to-configure-a-raspberry-pi-as-a-pxe-boot-server
# minus dnsmasq - using isc-dhcp-server
sudo apt-get -y install dnsmasq pxelinux syslinux-efi

sudo mkdir -p /mnt/data/netboot/{boot,bios,efi64}

sudo cp \
  /usr/lib/syslinux/modules/bios/{ldlinux,vesamenu,libcom32,libutil}.c32 \
  /usr/lib/PXELINUX/pxelinux.0 \
  /mnt/data/netboot/bios

sudo cp \
  /usr/lib/syslinux/modules/efi64/ldlinux.e64 \
  /usr/lib/syslinux/modules/efi64/{vesamenu,libcom32,libutil}.c32 \
  /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi \
  /mnt/data/netboot/efi64

TFTP_ROOT=/mnt/data/netboot
echo "port=0
interface=eth0
dhcp-range=10.10.0.10,10.10.0.200,12h
enable-tftp
tftp-root=/mnt/data/netboot
pxe-service=x86PC,\"PXELINUX (BIOS)\",bios/pxelinux
pxe-service=x86-64_EFI,\"PXELINUX (EFI)\",efi64/syslinux.efi
log-queries
log-facility=/var/log/dnsmasq.log" | sudo tee -a /etc/dnsmasq.conf

#https://askubuntu.com/questions/1235723/automated-20-04-server-installation-using-pxe-and-live-server-image
curl -OL https://releases.ubuntu.com/20.04/ubuntu-20.04.1-live-server-amd64.iso
curl -OL http://archive.ubuntu.com/ubuntu/dists/focal/main/uefi/grub2-amd64/current/grubnetx64.efi.signed
sudo cp grubnetx64.efi.signed ${TFTP_ROOT}/pxelinux.0

TMP_PATH=/tmp/ubuntu
mkdir -p ${TMP_PATH}
sudo mount ubuntu-20.04.1-live-server-amd64.iso ${TMP_PATH}
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
    linux /vmlinuz ip=dhcp url=http://${pxe_default_server}/tftp/ubuntu-20.04-live-server-amd64.iso autoinstall ds=nocloud-net\;s=http://${pxe_default_server}/tftp/
    echo \"Loading Ram Disk...\"
    initrd /initrd
}
menuentry \"Focal Live Installer\" --id=install {
    echo \"Loading Kernel...\"
    linux /vmlinuz ip=dhcp url=http://${pxe_default_server}/tftp/ubuntu-20.04-live-server-amd64.iso
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
