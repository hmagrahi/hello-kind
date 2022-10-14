#! /usr/bin/env sh
set -e

kind create cluster --name kind || true

kubectl cluster-info --context kind-kind
#install hashicorp
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault --set "server.dev.enabled=true"

#install external secret crd
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace

#create a ClusterSecretStore check https://external-secrets.io/v0.4.4/api-clustersecretstore/
cat << 'EOF' | kubectl apply -f -
apiVersion: v1
metadata:
  name: my-secret
  namespace: external-secrets
data:
  vault-token: cm9vdA==
kind: Secret
type: Opaque
---
apiVersion: external-secrets.io/v1alpha1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://10.244.0.16:8200" #vault host
      path: secret
      version: v2
      auth:
        tokenSecretRef:
          name: "my-secret"
          namespace: "default"
          key: "vault-token"
EOF
