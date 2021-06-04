* Replace the PROJECT_ID where applicable
    ```
    export PROJECT_ID=THE_PROJECT_ID
    export CLUSTER_NAME=standalone-single

    sed "s/PROJECT_ID/${PROJECT_ID}/" \
        bmctl-workspace/${CLUSTER_NAME}/${CLUSTER_NAME}.yaml_tmpl \
        > bmctl-workspace/${CLUSTER_NAME}/${CLUSTER_NAME}.yaml
    ```

* Execute cluster creation (ignore errors, because gcloud is not initialized locally, bootstrap cidr because, if using kvm, the default `192.168.122.0/24` will cause errors)
    ```
    bmctl create cluster \
        -c ${CLUSTER_NAME} \
        --ignore-validation-errors \
        --bootstrap-cluster-pod-cidr 192.168.100.0/24
    ```

* User Clusters (if an admin cluster is deployed)

    ```
    export PROJECT_ID=THE_PROJECT_ID
    export CLUSTER_NAME=user1
    kubectl --kubeconfig bmctl-workspace/admin/admin-kubeconfig apply -f bmctl-workspace/${CLUSTER_NAME}/${CLUSTER_NAME}.yaml
    ```

    > NOTE: The commands below check if the user cluster has been successfully created and extracts the user cluster kubeconfig
    ```
    kubectl --kubeconfig bmctl-workspace/admin/admin-kubeconfig wait \
      cluster ${CLUSTER_NAME} -n cluster-${CLUSTER_NAME} \
      --for=condition=Reconciling=False --timeout=30m && \
      kubectl --kubeconfig bmctl-workspace/admin/admin-kubeconfig wait nodepool node-pool-1 \
      -n cluster-${CLUSTER_NAME} --for=condition=Reconciling=False --timeout=30m &&
      kubectl --kubeconfig bmctl-workspace/admin/admin-kubeconfig get secret ${CLUSTER_NAME}-kubeconfig -n cluster-${CLUSTER_NAME} \
      -o 'jsonpath={.data.value}' | base64 -d > ${CLUSTER_NAME}-kubeconfig
    ```
