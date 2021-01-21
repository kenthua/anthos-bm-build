```
curl -OL https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip
unzip terraform_0.14.5_linux_amd64.zip
chmod 755 terraform
```

```
grep -rl "PROJECT_ID" . | xargs sed -i "s/PROJECT_ID/${PROJECT_ID}/"
```

```
PROJECT_ID=kenthua-dev

gcloud init
gcloud auth applcation-default login

gsutil mb gs://${PROJECT_ID}
```