PRIVATE_KEY_PATH=$1
kubectl create ns config-management-system && \
kubectl create secret generic git-creds \
  --namespace=config-management-system \
  --from-file=ssh="${PRIVATE_KEY_PATH}"
