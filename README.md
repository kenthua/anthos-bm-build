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

![](https://mermaid.ink/svg/eyJjb2RlIjoiZ3JhcGggVERcblxuc3ViZ3JhcGggaW5mcmFcbiAgICB3b3Jrc3RhdGlvbltCTSBXb3Jrc3RhdGlvbl0gLS0tIHwxMC4xMC4wLjIwfCBBQlxuICAgIEFCPjEwLjEwLjAueF0gLS0tIEFBXG4gICAgQUFbREhDUC9ETlMvUm91dGVyXSAtLS0gfDE5Mi4xNjguODYueHwgQUNbV0lGSV1cbmVuZFxuXG5zdWJncmFwaCBBbnRob3MgQmFyZSBNZXRhbCAtIE5VQ1NcbiAgc3ViZ3JhcGggQ29udHJvbCBQbGFuZVxuICAgIEJBW25vZGUwMV0gLS0tIEFCXG4gICAgQkJbbm9kZTAyXSAtLS0gQUJcbiAgICBCQ1tub2RlMDNdIC0tLSBBQlxuICAgIHN1YmdyYXBoIENvbXBvbmVudHNcbiAgICAgIG1ldGFsbGJbbWV0YWxsYl0gLS0tICBsYi1wb29sMT4xMC4xMC4wLjIxMC4uMjMwXVxuICAgIGVuZFxuICBlbmRcbiAgc3ViZ3JhcGggTm9kZXNcbiAgICBCRFtub2RlMDRdIC0tLSBBQlxuICAgIEJFW25vZGUwNV0gLS0tIEFCXG4gIGVuZFxuZW5kXG5cbnN0eWxlIENvbXBvbmVudHMgc3Ryb2tlLWRhc2hhcnJheTogNVxuXG4iLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)

<!--
https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggVERcblxuc3ViZ3JhcGggaW5mcmFcbiAgICB3b3Jrc3RhdGlvbltCTSBXb3Jrc3RhdGlvbl0gLS0tIHwxMC4xMC4wLjIwfCBBQlxuICAgIEFCPjEwLjEwLjAueF0gLS0tIEFBXG4gICAgQUFbREhDUC9ETlMvUm91dGVyXSAtLS0gfDE5Mi4xNjguODYueHwgQUNbV0lGSV1cbmVuZFxuXG5zdWJncmFwaCBBbnRob3MgQmFyZSBNZXRhbCAtIE5VQ1NcbiAgc3ViZ3JhcGggQ29udHJvbCBQbGFuZVxuICAgIEJBW25vZGUwMV0gLS0tIEFCXG4gICAgQkJbbm9kZTAyXSAtLS0gQUJcbiAgICBCQ1tub2RlMDNdIC0tLSBBQlxuICAgIHN1YmdyYXBoIENvbXBvbmVudHNcbiAgICAgIG1ldGFsbGJbbWV0YWxsYl0gLS0tICBsYi1wb29sMT4xMC4xMC4wLjIxMC4uMjMwXVxuICAgIGVuZFxuICBlbmRcbiAgc3ViZ3JhcGggTm9kZXNcbiAgICBCRFtub2RlMDRdIC0tLSBBQlxuICAgIEJFW25vZGUwNV0gLS0tIEFCXG4gIGVuZFxuZW5kXG5cbnN0eWxlIENvbXBvbmVudHMgc3Ryb2tlLWRhc2hhcnJheTogNVxuXG4iLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ
-->

<!--
graph TD

subgraph infra
    workstation[BM Workstation] --- |10.10.0.20| AB
    AB>10.10.0.x] --- AA
    AA[DHCP/DNS/Router] --- |192.168.86.x| AC[WIFI]
end

subgraph Anthos Bare Metal - NUCS
  subgraph Control Plane
    BA[node01] --- AB
    BB[node02] --- AB
    BC[node03] --- AB
    subgraph Components
      metallb[metallb] ---  lb-pool1>10.10.0.210..230]
    end
  end
  subgraph Nodes
    BD[node04] --- AB
    BE[node05] --- AB
  end
end

style Components stroke-dasharray: 5
-->
