KSA_NAME=console
kubectl create serviceaccount ${KSA_NAME}
kubectl create clusterrolebinding console-view-binding \
  --clusterrole view --serviceaccount default:${KSA_NAME}
kubectl create clusterrolebinding console-reader-binding \
  --clusterrole cloud-console-reader --serviceaccount default:${KSA_NAME}

SECRET_NAME=$(kubectl get serviceaccount console -o jsonpath='{$.secrets[0].name}')
kubectl get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' | base64 --decode
