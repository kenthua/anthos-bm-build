
# copy key
scp ubuntu@10.10.0.1:/home/ubuntu/.ssh/id_rsa ${HOME}/.ssh/id_rsa_build
scp ubuntu@10.10.0.1:/home/ubuntu/.ssh/id_rsa.pub ${HOME}/.ssh/id_rsa_build.pub
chmod 600 ${HOME}/.ssh/id_rsa_build
chmod 644 ${HOME}/.ssh/id_rsa_build-cert.pub

# setup gcloud
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk

## docker gcloud
docker pull gcr.io/google.com/cloudsdktool/cloud-sdk:alpine
alias gcloud="docker run gcr.io/google.com/cloudsdktool/cloud-sdk:alpine gcloud"

# get bmctl
gsutil cp gs://anthos-baremetal-release/bmctl/1.6.0/linux-amd64/bmctl .
chmod 755 bmctl 
sudo mv bmctl /usr/local/bin

# get keys
mkdir -p ${HOME}/bm
gsutil cp gs://kenthua-dev/sa/* . ${HOME}/bm

# install docker
sudo apt-get remove docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/debian \
	      $(lsb_release -cs) \
	         stable"
sudo apt-get update
apt-cache madison docker-ce
sudo apt-get -y install docker-ce=5:19.03.14~3-0~debian-buster docker-ce-cli=5:19.03.14~3-0~debian-buster containerd.io

# add group
sudo usermod -a -G docker kenthua

# install bm
bmctl create config -c standalone --project-id kenthua-dev
bmctl create cluster -c standalone
