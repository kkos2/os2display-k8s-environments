echo " * Configuring kubectl"
gcloud --project=os2display-kff container clusters get-credentials --region=europe-west1 os2kff-cluster-1
kubens os2display-prod

echo " * Configuring helm"
helm init --client-only
helm repo add reload-os2display https://reload.github.io/os2display-k8s
helm repo add jetstack https://charts.jetstack.io
helm repo update

