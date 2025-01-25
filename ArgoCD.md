# Instructions

## Installing ArgoCD on kind cluster

```bash
# Add the ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm

# Update your local Helm chart repository cache
helm repo update

# Install ArgoCD into the argocd namespace
helm install argocd argo/argo-cd --namespace argocd --create-namespace
```

## Accessing the server UI

In order to access the server UI you have the following options:

1. `kubectl port-forward service/argocd-server -n argocd 8080:443`

    and then open the browser on [http://localhost:8080](http://localhost:8080) and accept the certificate

2. enable ingress in the values file `server.ingress.enabled` and either
      - Add the annotation for ssl passthrough: [ssl passthrough](https://argo-cd.readthedocs.io/en/stable) operator-manual/ingress/#option-1-ssl-passthrough
      - Set the `configs.params."server.insecure"` in the values file and terminate SSL at your ingress: [docs](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-2-multiple-ingress-objects-and-hosts)

After reaching the UI the first time you can login with username: admin and the random password generated during the installation. You can find the password by running:

```bash

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

(You should delete the initial secret afterwards as suggested by the Getting Started Guide: [guide](https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)
