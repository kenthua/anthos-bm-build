#!/bin/bash

# enable port forwarding and make it persistent
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# enable forwarding eth0 traffic through wlan0 and make it persistent
# https://serverfault.com/questions/152363/bridging-wlan0-to-eth0
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo apt-get install -y iptables-persistent

# setup dns / tftp
sudo apt-get -y install dnsmasq

TFTP_ROOT=/var/lib/tftpboot
UBUNTU_ISO=ubuntu-20.04.1-live-server-amd64.iso
TMP_PATH=/tmp/ubuntu

## modify resolv.conf accordingly
## /etc/resolv.conf
# nameserver 10.10.0.1
# options edns0
# search anthos.cloud

# disable ubuntu systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

sudo cp dnsmasq.conf /etc/dnsmasq.conf
sudo systemctl restart dnsmasq

# setup apache
sudo apt-get -y install apache2

# copy / enable tftp configuration
sudo cp tftp.conf /etc/apache2/conf-available/tftp.conf
sudo a2enconf tftp

# ensure apache is autostarted/config reloaded/restarted
sudo systemctl enable apache2
sudo systemctl reload apache2

# grab the ubuntu iso
sudo mkdir -p ${TFTP_ROOT}
sudo curl -L https://releases.ubuntu.com/20.04/${UBUNTU_ISO} -o ${TFTP_ROOT}/${UBUNTU_ISO}
sudo curl -L http://archive.ubuntu.com/ubuntu/dists/focal/main/uefi/grub2-amd64/current/grubnetx64.efi.signed -o ${TFTP_ROOT}/pxelinux.0

# extract the boot files
mkdir -p ${TMP_PATH}
sudo mount ${TFTP_ROOT}/${UBUNTU_ISO} ${TMP_PATH}
sudo cp ${TMP_PATH}/casper/vmlinuz ${TFTP_ROOT}
sudo cp ${TMP_PATH}/casper/initrd ${TFTP_ROOT}
sudo umount ${TMP_PATH}

# prepare grub
sudo mkdir -p ${TFTP_ROOT}/grub
cat grub.cfg | sed "s/UBUNTU_ISO/${UBUNTU_ISO}/" | sudo tee ${TFTP_ROOT}/grub/grub.cfg

# https://ubuntu.com/server/docs/install/autoinstall
# prepare ubuntu auto installer
sudo touch ${TFTP_ROOT}/meta-data
sudo cp user-data ${TFTP_ROOT}/user-data

# get ansible ready
sudo apt update
sudo apt install ansible

#####################
## cleaning the disk
#####################
# wipe disk fdisk - fast just wipe parition table
echo "d
3
d
2
d

w" | sudo fdisk /dev/nvme0n1

# wipe disk dd -- ctrl-c after a few sec
sudo dd if=/dev/zero of=/dev/nvme0n1 bs=1M


pi@rpi:~/anthos-bm-build/ansible $ cat wakeup.yaml
---
- hosts: all
  gather_facts: false
  tasks:
  - name: wakeup
    wakeonlan:
      mac: "{{ hostvars['all'].mac }}"
      broadcast: 10.10.0.255
    delegate_to: localhost
pi@rpi:~/anthos-bm-build/ansible $ cat hosts.yaml
controlplane:
  vars:
    ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
  hosts:
    node01:
      ansible_host: 10.10.0.11
      mac: 1c:69:7a:6f:b8:af
    node02:
      ansible_host: 10.10.0.12
      mac: 1c:69:7a:6f:9f:27
    node03:
      ansible_host: 10.10.0.13
      mac: 1c:69:7a:6f:ba:c1
nodes:
  vars:
    ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
  hosts:
    node04:
      ansible_host: 10.10.0.14
      mac: 1c:69:7a:6f:c0:a9
    node05:
      ansible_host: 10.10.0.15
      mac: 1c:69:7a:6f:ba:2c
test:
  vars:
    ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
  hosts:
    node01:
      ansible_host: 10.10.0.11
      mac: 1c:69:7a:6f:b8:af