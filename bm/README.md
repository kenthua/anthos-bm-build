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