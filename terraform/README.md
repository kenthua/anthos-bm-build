PROJECT_ID=kenthua-dev

gcloud init
gcloud auth applcation-default login

gsutil mb gs://${PROJECT_ID}