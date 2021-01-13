# Anthos Bare Metal Build Out

### Prereqs
* 5 Anthos Bare Metal nodes (intel nucs)
* 1 network services node (dnsmasq -- dhcp, dns, tftp)
* 1 workstation node (bmctl, gcloud)

### Getting started
* Intel NUCs boot via PXE (default) if the internal SSD is not bootable
* `scripts/ubuntu` - script (ansible playbook TODO) to setup network services node
  * utilize as necessary depending on your current environment
* `ansible` playbooks
  * change the `hosts.yaml` to reflect your environment.  There is no difference between control plane and node.
  * initialize prereqs for Anthos Bare Metal for Ubuntu 
  * shutdown and wakeup (wol) playbook
  * wipe ssd and trigger a restart to pxe boot a new install
  * reset the environment (wipe / provision / setup )
* `terraform` - to setup google api services and service accounts, remote state in gcp bucket
* `bm` - generated & tweaked Anthos Bare Metal standalone configuration (ansible j2 template? TBD)
  * adjust the configuration as applicable to your environment

### Reset the environment / Starting over
* Wipe SSD on each nuc (ex: in `scripts` folder), forcing PXE on reboot
* Ubuntu headless autoinstall to load 20.04 onto each node.  
  * Setup `ubuntu` user, passwordless sudo and ssh public key.

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggVERcblxuc3ViZ3JhcGggaW5mcmFcbiAgICB3b3Jrc3RhdGlvbltCTSBXb3Jrc3RhdGlvbl0gLS0tIHwxMC4xMC4wLjIwfCBBQlxuICAgIEFCPjEwLjEwLjAueF0gLS0tIEFBXG4gICAgQUFbREhDUCBTZXJ2ZXJdIC0tLSB8MTkyLjE2OC44Ni54fCBBQ1tXSUZJXVxuZW5kXG5cbnN1YmdyYXBoIEFudGhvcyBCYXJlIE1ldGFsIC0gTlVDU1xuICBzdWJncmFwaCBDb250cm9sIFBsYW5lXG4gICAgQkFbbm9kZTAxXSAtLS0gQUJcbiAgICBCQltub2RlMDJdIC0tLSBBQlxuICAgIEJDW25vZGUwM10gLS0tIEFCXG4gICAgc3ViZ3JhcGggQ29tcG9uZW50c1xuICAgICAgbWV0YWxsYlttZXRhbGxiXSAtLS0gIGxiLXBvb2wxPjEwLjEwLjAuMjAwLi4yMTBdXG4gICAgZW5kXG4gIGVuZFxuICBzdWJncmFwaCBOb2Rlc1xuICAgIEJEW25vZGUwNF0gLS0tIEFCXG4gICAgQkVbbm9kZTA1XSAtLS0gQUJcbiAgZW5kXG5lbmRcblxuc3R5bGUgQ29tcG9uZW50cyBzdHJva2UtZGFzaGFycmF5OiA1XG5cbiIsIm1lcm1haWQiOnsidGhlbWUiOiJkZWZhdWx0In0sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggVERcblxuc3ViZ3JhcGggaW5mcmFcbiAgICB3b3Jrc3RhdGlvbltCTSBXb3Jrc3RhdGlvbl0gLS0tIHwxMC4xMC4wLjIwfCBBQlxuICAgIEFCPjEwLjEwLjAueF0gLS0tIEFBXG4gICAgQUFbREhDUCBTZXJ2ZXJdIC0tLSB8MTkyLjE2OC44Ni54fCBBQ1tXSUZJXVxuZW5kXG5cbnN1YmdyYXBoIEFudGhvcyBCYXJlIE1ldGFsIC0gTlVDU1xuICBzdWJncmFwaCBDb250cm9sIFBsYW5lXG4gICAgQkFbbm9kZTAxXSAtLS0gQUJcbiAgICBCQltub2RlMDJdIC0tLSBBQlxuICAgIEJDW25vZGUwM10gLS0tIEFCXG4gICAgc3ViZ3JhcGggQ29tcG9uZW50c1xuICAgICAgbWV0YWxsYlttZXRhbGxiXSAtLS0gIGxiLXBvb2wxPjEwLjEwLjAuMjAwLi4yMTBdXG4gICAgZW5kXG4gIGVuZFxuICBzdWJncmFwaCBOb2Rlc1xuICAgIEJEW25vZGUwNF0gLS0tIEFCXG4gICAgQkVbbm9kZTA1XSAtLS0gQUJcbiAgZW5kXG5lbmRcblxuc3R5bGUgQ29tcG9uZW50cyBzdHJva2UtZGFzaGFycmF5OiA1XG5cbiIsIm1lcm1haWQiOnsidGhlbWUiOiJkZWZhdWx0In0sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)
