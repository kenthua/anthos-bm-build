###
* prepare the nodes
    ```
    ansible-playbook -i hosts.yaml init.yaml
    ```

* testing just node01
    ```
    ansible-playbook -i hosts.yaml -l test init.yaml
    ```

* wakeup the nodes
    ```
    ansible-playbook -i hosts.yaml wakeup.yaml
    ```

* shutdown the nodes
    ```
    ansible-playbook -i hosts.yaml shutdown.yaml
    ```

* wipe the nodes (there will be a confirmation, true/false), true being execute.  wipe, reboot, clear the local known_hosts of applicable host entries, wait ~1100 seconds, yours may differ, check the nodes
    ```
    ansible-playbook -i hosts.yaml wipe.yaml
    ```

* check the nodes are ready to be initialized, in this case check the hostnames are just `node`.  This is also run in the wipe playbook
    ```
    ansible-playbook -i hosts.yaml check.yaml
    ```
