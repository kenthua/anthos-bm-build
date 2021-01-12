# Anthos Bare Metal Build Out

### Prereqs
* 5 Anthos Bare Metal nodes (intel nucs)
* 1 network services node (dnsmasq -- dhcp, dns, tftp)
* 1 workstation node (bmctl, gcloud)

### Getting started
* Intel NUCs boot via PXE (default) if the internal SSD is not bootable
* `scripts/ubuntu` - script (ansible playbook TODO) to setup network services node
* `ansible` playbooks 
  * initialize prereqs for Anthos Bare Metal for Ubuntu 
  * shutdown and wakeup (wol) playbook
  * wipe ssd and trigger a restart to pxe boot a new install
* `terraform` - to setup google api services and service accounts, remote state in gcp bucket
* `bm` - generated & tweaked Anthos Bare Metal standalone configuration

### Reset the environment / Starting over
* Wipe SSD on each nuc (ex: in `scripts` folder), forcing PXE on reboot
* Ubuntu headless autoinstall to load 20.04 onto each node.  
  * Setup `ubuntu` user, passwordless sudo and ssh public key.  
