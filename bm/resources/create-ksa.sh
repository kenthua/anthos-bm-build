# https://cloud.google.com/anthos/multicluster-management/console/logging-in
kubectl apply -f cloud-console-reader.yaml
KSA_NAME=cloud-console-user
kubectl create serviceaccount ${KSA_NAME}
kubectl create clusterrolebinding view \
  --clusterrole view --serviceaccount default:${KSA_NAME}
kubectl create clusterrolebinding cloud-console-reader \
  --clusterrole cloud-console-reader --serviceaccount default:${KSA_NAME}
SECRET_NAME=$(kubectl get serviceaccount ${KSA_NAME} -o jsonpath='{$.secrets[0].name}')
kubectl get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' | base64 --decode
