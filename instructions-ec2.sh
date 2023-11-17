# ======================================================================
sudo su - root
sudo yum update
sudo yum install docker -y
systemctl start docker

sudo yum install git -y
mkdir ~/dev && cd ~/dev
git clone https://github.com/seannguyn/go-demo.git

cd ~/dev/go-demo
docker build -t go-demo .
docker run -p 6062:8080 go-demo

############ VISIT WEB PAGE TO VERIFY: http://PUBLIC_IP:6062

cd ~/dev

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

############ For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

kind create cluster
kind get clusters
kubectl cluster-info --context kind-kind

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
nohup kubectl port-forward --address 0.0.0.0 service/kubernetes-dashboard -n kubernetes-dashboard 8081:443 > ~/dev/kube-dashboard.log 2>&1 &

kubectl apply -f ~/dev/go-demo/argocd/token.yml
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d

############ KUBE DASHBOARD TOKEN: .....
TOKEN=""

kubectl create ns argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

############ AROCD PASSWORD: <ARGOCD_PASSWORD>
ARGOCD_PASSWORD=""

nohup kubectl port-forward --address 0.0.0.0 service/argocd-server -n argocd 8080:443 > ~/dev/argocd-server.log 2>&1 &

cd ~/dev/go-demo
kubectl apply -f argocd/users.yml

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

argocd login 127.0.0.1:8080

argocd account update-password \
  --account alice \
  --current-password $ARGOCD_PASSWORD \
  --new-password $ARGOCD_PASSWORD

argocd account update-password \
  --account bob \
  --current-password $ARGOCD_PASSWORD \
  --new-password $ARGOCD_PASSWORD

argocd cluster add kind-kind --insecure --in-cluster -y --upsert

kind load docker-image go-demo:latest

kubectl apply -f argocd/approach-1-project.yml
kubectl apply -f argocd/approach-1-application_set.yml

kubectl delete -f argocd/approach-1-project.yml
kubectl delete -f argocd/approach-1-application_set.yml

kubectl apply -f argocd/approach-2-project.yml
kubectl apply -f argocd/approach-2-application_set.yml

