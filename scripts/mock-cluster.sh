#! /usr/bin/env sh
set -e

#install hashicorp
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault --set "server.dev.enabled=true"

#install external secret crd
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace

# wait for the external secret and vault
kubectl -n external-secrets rollout status deployment/external-secrets --timeout=2m
kubectl -n external-secrets rollout status deployment/external-secrets-cert-controller --timeout=2m
kubectl -n external-secrets rollout status deployment/external-secrets-webhook --timeout=2m
kubectl -n default rollout status deployment/vault-agent-injector --timeout=2m

#set secrets
kubectl exec -it vault-0 -- /bin/sh -c "vault kv put secret/dev/kind/authentication database.username=toto database.password=toto"

#create a ClusterSecretStore check https://external-secrets.io/v0.4.4/api-clustersecretstore/
cat << 'EOF' | kubectl apply -f -
apiVersion: v1
metadata:
  name: my-secret
  namespace: default
data:
  vault-token: cm9vdA==
kind: Secret
type: Opaque
EOF

cat << 'EOF' | kubectl apply -f -
apiVersion: external-secrets.io/v1alpha1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault.default.svc.cluster.local:8200" #vault host
      path: secret
      version: v2
      auth:
        tokenSecretRef:
          name: "my-secret"
          namespace: "default"
          key: "vault-token"
EOF

SERVICE_VERSION=$(git rev-parse HEAD)
# deploy hello-kind
helm upgrade -f ./charts/hello-kind/values-dev.yaml --install hello-kind ./charts/hello-kind \
    --set image.repository=hello-kind \
    --set image.tag=v$SERVICE_VERSION \
    --namespace=default