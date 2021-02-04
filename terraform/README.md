* Get a version of terraform 0.14+
    ```
    curl -OL https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip
    unzip terraform_0.14.5_linux_amd64.zip
    chmod 755 terraform
    ```

* Initialize gcloud and create the expected bucket for storing remote state
    ```
    PROJECT_ID=kenthua-dev

    gcloud init
    gcloud auth applcation-default login

    gsutil mb gs://${PROJECT_ID}
    ```

* Replace terraform variables for the bucket
    ```
    grep -rl "PROJECT_ID" . | xargs sed -i "s/PROJECT_ID/${PROJECT_ID}/"
    ```

* Execute terraform 
    ```
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```

* Once accounts are generated, if necessary easier way to copy keys.  Ensure keys are appropriately managed.
    ```
    FILENAME=replicate_sa.sh
    GCR=bm_gcr_svc_account_key.json
    CA=connect_agent_svc_account_key.json
    CR=connect_register_svc_account_key.json
    LM=logging_monitoring_svc_account_key.json
    echo "#!/bin/bash" > ${FILENAME}

    for I in ${GCR} ${CA} ${CR} ${LM}; do
        echo "cat <<EOF > ${I}" >> ${FILENAME}
        cat ${I} >> ${FILENAME}
        echo "EOF" >> ${FILENAME}
        echo "cat ${I} | jq '.private_key' -r | openssl rsa -check | grep \"key ok\"" >> ${FILENAME}
    done
    ```
