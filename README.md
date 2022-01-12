# loeken's homelab
This repo contains my homelab setup. I run this on a single server, but this can also be spread across multiple servers for HA. This setup has been tested on debian 11 / proxmox pve 7. 
- 32 x Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz (2 Sockets )
- 96 GB RAM
- HBA with 4 * 4TB disks connected ( storage type "slow" )
- 1 SSD for OS, 1 SSD for fast blockstorage ( storage type "fast" )

## Requirements & Setup
Proxmox needs to be installed on destination server. Clone this repo to your laptop, your laptop needs to be able to ssh into the proxmox server ( as a user with sudo / NOPASSWD ) for building the proxmox template.

## What's inside?
Core:
- terraform code to bootstrap 3 debian k3s nodes inside proxmox

Charts:
| Chart Name       | Helm   | App      | Source           | Description                                     |
| ---------------- | ------ | -------- | ---------------- | ----------------------------------------------- |
| argocd           | 3.29.5 | 2.2.2    | argoproj         | watches git repo and applies updates            |
| cert-manager     | 1.6.1  | 1.6.1    | jetstack         | issues tls certificates - letsencrypt           | 
| external-dns     | 6.0.2  | 0.10.2   | bitnami          | updates ips of dns records cloudflare           |
| nginx-ingress    | 9.1.0  | 1.1.0    | bitnami          | nginx reverse proxy for ingress traffic         | 
| sealed secrets   | 1.16.1 | 0.17.1   | sealed-secrets   | encrypts secrets in cluster                     |
| volume snapshots | 0.0.1  | 0.0.1    | local helm chart | snapshots of volumes for backup                 |

Optional Charts:
| Chart Name       | Helm   | App      | Source           | Description                                     |
| ---------------- | ------ | -------- | ---------------- | ----------------------------------------------- | 
| authelia         | 0.7.7  | 4.33.1   | truecharts       | SSO/two factor auth service works with nginx    |
| vaultwarden      | 4.0.0  | 1.22.2   | k8s-at-home      | vaultwarden password manager                    |
| democratic csi   | 0.8.3  | 0.8.3    | democratic-csi   | csi with nfs/iscsi to consume external storage  |
| heimdall         | 8.1.0  | 2.2.2    | k8s-at-home      | a simple dashboard to link to other services    |
| kasten-k10       | 4.5.6  | 4.5.6    | kasten-k10       | backup/disaster recovery for volumesnapshots    |
| uptime kuma      | 0.1.6  | 1.8.0    | duyet            | very simple nodejs uptime/status page           |
| nextcloud        | 2.11.3 | 22.2.3   | nextcloud        | self hosted dropbox alternative                 |
| photoprism       | 6.2.0  | 20211018 | k8s-at-home      | self hosted icloud/google photos alternative    |
| plex             | 6.2.0  | 1.24.1   | k8s-at-home      | self hosted media transcoding/streaming service |

## How does it work?
### 1.) github.com account
Github is a code repository, you can sign up for free and use private repositories. if you havent got an account yet head over sign up and create an account

### 2.) fork this repo ( github.com/loeken/homelab )
if you are on https://github.com/loeken/homelab then you can press on the top right on the fork button. this will create a fork - a fork is simply put a copy of my repo, but you can still fetch changes that i add to my repo to yours ( fetch from upstream ).

### 3.) customizing the values to your liking ( terraform & argocd/helm )
#### 3.1.) Terraform
first head to the terraform folder and copy over the defaults variables, then edit the variables.tf you created. you can also edit the domain for the ingress inside the deploy/terraform/argocd-values.yaml ( dont have to push deploy/terraform/argocd-values.yaml to repo )
```
cd deploy/terraform

cp variables.tf.example variables.tf
nano variables.tf

cp argocd-values.yaml.example argocd-values.yaml
nano argocd-values.yaml
```

### 3.) Bootstrap with terraform

the next part will create a new proxmox template based on debian 11 with cloud-init/nfs/iscsi support, afterwards it will create 3 vms of this template and install k3s as a 3 node k3s master-cluster. once the cluster is up it will install a helm chart for cert-manager, argocd and deploy/helm/bootstrap-core-apps. argocd is installed by feeding the argocd: section from deploy/helm/bootstrap-core-apps/values.yaml. this means that this values.yaml will contain all the config specific to your setup

you also have to edit the argocd-values.yaml inside the terraform folder, those will define the ingress for argocd.
```
terraform init
terraform plan
terraform apply
```

### 4.) Argocd two App of Apps
<b>deploy/helm/bootstrap-core-apps</b> is a local helm chart that creates an argocd "app of apps" in simple word it points at the deploy/argocd-core folder which contains one local helm chart, with an argocd application for each app running in the cluster. this chart contains the base we need in order to install the other charts ( but you dont have to customize anything for these )

<b>deploy/helm/bootstrap-optional-apps</b> is another local helm chart setup in the same way as the bootstrap-core-apps is with one major difference, you will need to edit the values for this chart, before synching argocd


### 5.) syncing bootstrap-core-apps via argocd dashboard
in this step we are going to sync the first set of apps, which are organized in bootstrap-core-apps helm chart. at this stage argocd is not yet reachable through ingress as we are missing nginx ingress, cert-manager, kubeseal and external-dns for it's ingress to function. so let's create a port forward using kubectl to connect to the cluster. we export the KUBECONFIG= to point to the kubeconfig file which was created by terraform apply.
```
export KUBECONFIG=$PWD/kubeconfig
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

```
kubectl -n argocd port-forward svc/argocd-server 8081:443
```

then head to https://localhost:8081 login with the username admin and the password returned by the kubectl get secret command

### 6.) sync bootstrap-core-apps
![todo](/docs/img/sync-argocd-core.png)
press the sync button at the top and wait for argocd to have synced all apps untill you see it being stuck on external-dns


### 7.) configure external-dns
external-dns does need credentials in order to connect we ll use kubeseal to save these credentials encrypted.

you can create the credentials as instructed here: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/cloudflare.md
```
cd ../mysecrets

cp cloudflare-credentials-external-dns.yaml.example cloudflare-credentials-external-dns.yaml
nano cloudflare-credentials-external-dns.yaml

cat cloudflare-credentials-external-dns.yaml | kubeseal -o yaml | kubectl apply -f -
```
then all apps should sync up.
![done](/docs/img/sync-argocd-core-done.png)

### 8.) configure optional apps
```
cp argocd-optional.yaml.example argocd-optional.yaml
nano argocd-optional.yaml
```
since we installed the kubeseal controller via the argocd-core apps we can now apply these 2 secrets - but encrypt them first.
```
cat argocd-optional.yaml | kubeseal | kubectl apply -f -
```
### 8.) configure authelia
authelia is setup to currently use a simple yaml file, which it reads from a secret, we can use this little helepr script to generate a simple layout for our username/email/password and save it as a sealedSecret
```
cd deploy/mysecrets
./create_authelia_secret.sh loeken loeken@internetz.me topsecure
```

### 9.) save your secrets
in the above command we encrypted our secrets with kubeseal this works by the kubeseal controller running in the cluster, and encrypting it for us instead of then running the encrypted kubernetes code we can also decide to save it to a yaml file
```
cat argocd-optional.yaml | kubeseal -o yaml > argocd-optional-encrypted.yaml
cat cloudflare-credentials-external-dns.yaml | kubeseal -o yaml > cloudflare-credentials-external-dns-encrypted.yaml
```
as the name indicates these have been encrypted by the kubeseal controller

### 10.) sync bootstrap-optional-apps
you can now again head to the argocd dashboard, at this stage the ingress should be working too, then head to the bootstrap-optional-apps app and click on sync.