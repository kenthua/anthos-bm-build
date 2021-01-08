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
