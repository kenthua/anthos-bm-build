###
https://docs.ansible.com/ansible/latest/user_guide/connection_details.html#host-key-checking
```
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i hosts.yaml init.yaml
```

testing just node01
```
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i hosts.yaml -l test init.yaml
```
