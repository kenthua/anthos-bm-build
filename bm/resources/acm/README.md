* Create secret for ssh private key
    ```
    ./create-secret-ssh-key.sh ${KEY_FILE}
    ```    

* Enable the ACM Feature
    ```
    gcloud alpha container hub config-management enable
    ```

* Deploy Config Management configuration into GCP.  The configuration can be deployed manually into the cluster, however applying it through hub will ensure consistency of the configuration.
    ```
    export REPO_PATH="git@gitlab.com:..."
    export BRANCH="main"
    export TYPE="ssh"
    export POLICY_DIR="/"
    export CLUSTER_NAME=""
    export PROJECT_ID=""
    
    envsubst < configmanagement.yaml_tmpl > configmanagement.yaml

    gcloud alpha container hub config-management apply \
      --membership=${CLUSTER_NAME} \
      --config=configmanagement.yaml \
      --project=${PROJECT_ID}
    ```