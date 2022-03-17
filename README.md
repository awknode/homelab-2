# THIS IS BEING SCRAPPED AND RE-DONE, STAY TUNED
This repo contains my homelab setup. I run this on a single server ( in 3 kvms ), but this can also be spread across multiple servers for HA. This setup has been tested on debian 11 / proxmox pve 7. 

## how does this work?
This repo contains a terraform script inside deploy/terraform. this terraform requires a proxmox to be executed, but will then download a debian 11 image and turn it into a template ( with iscsi/nfs support and cloud-init ). this template is then being used to spin up 3 KVMs. Then terraform uses k3sup to install a 3 master k3s cluster. Last but not least it installs argocd via a helm chart. and sets up 2 argocd "apps of apps" inside argocd.

Next to the 3 kvms i run a 4th vm with truenas inside, to which i pass my HBA ( the controller that manages all disks in my server). truenas then is running a zfs pool ( or more if you want ) which provides nfs/iscsi/ssh  servers. this forms the "persistence" storage that is used across all charts

#### argocd-core
deploy/argocd-core contains a set of argocd apps to install cert-manager/external-dns/nginx-ingress/sealed secrets/volume snapshots. this is sort of the things that have to run for the rest to function.

#### argocd-optional
deploy/argocd-optional contains a set of argocd apps to install the rest of the included applications.

By default the main 2 charts are installed, but not all apps are installed automatically, this gives you the option to only install the parts that you need.

#### encryption / kubeseal
i did install proxmox using the debian 11 installer and installed it with full disk encryption. All configuration used by all helm charts ( an example can be found in deploy/ mysecrets/argocd-optional.yaml.example ) are stored in 1 big secret that contains a *.yaml file for each argocd app ( and thus for the helm chart specified in the argocd app ). you - the end user - create your own local copy ( cp argocd-optional.yaml.example argocd-optional.yaml ) and define your own passwords/names/domains etc. We then use kubeseal to encrypt this secret in the cluster. Kubeseal works by basically encrypting your secret inside the cluster, so kubeseal will have the keys to decrypt when needed. Kubeseal returns us the encrypted version, which we apply as a secret inside our cluster(encrypted). Now whenever we rollout something that needs to access the actual values, kubeseal will decrypt and provide it to the cluster. This way we can keep all "secrets" actually encrypted at rest without having to setup vault or similar.

Note: whenever you update your cluster and pull this repo, make sure to check that are no changes in the structure of the argocd-optional.yaml.example.

## Requirements & Setup
Proxmox needs to be installed on destination server. Clone this repo to your laptop, your laptop needs to be able to ssh into the proxmox server ( as a user with sudo / NOPASSWD ) for building the proxmox template.

## current requirements ( i run 3 containers with 10GB of ram each ) with the entire stack and no load you can expect:
```
❯ k top nodes
NAME          CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k3s-prod-01   221m         3%     5844Mi          60%       
k3s-prod-02   202m         3%     5261Mi          54%       
k3s-prod-03   344m         5%     5829Mi          59%  
```

## What's inside?
Core:
- terraform code to bootstrap 3 debian k3s nodes inside proxmox

Charts:
| Chart Name       | Helm   | App        | Source           | Description                                     |
| ---------------- | ------ | ---------- | ---------------- | ----------------------------------------------- |
| argocd           | 3.33.2 | 2.2.3      | argoproj         | watches git repo and applies updates            |
| cert-manager     | 1.7.1  | 1.7.1      | jetstack         | issues tls certificates - letsencrypt           | 
| external-dns     | 6.1.3  | 0.10.2     | bitnami          | updates ips of dns records cloudflare           |
| nginx-ingress    | 9.1.5  | 1.1.1      | bitnami          | nginx reverse proxy for ingress traffic         | 
| sealed secrets   | 2.1.2  | 0.17.3     | sealed-secrets   | encrypts secrets in cluster                     |
| volume snapshots | 0.0.1  | 0.0.1      | local helm chart | snapshots of volumes for backup                 |

Optional Charts:
| Chart Name       | Helm   | App        | Source           | Description                                     |
| ---------------- | ------ | ---------- | ---------------- | ----------------------------------------------- | 
| authelia         | 0.8.1  | 4.33.1     | truecharts       | SSO/two factor auth service works with nginx    |
| democratic csi   | 0.9.0  | 0.9.0      | democratic-csi   | csi with nfs/iscsi to consume external storage  |
| harbor           | 11.2.2 | 2.4.1      | bitnami          | a self container registry                       |
| heimdall         | 8.2.0  | 2.2.2      | k8s-at-home      | a simple dashboard to link to other services    |
| home-assistant   | 12.0.1 | 2021.12.7  | k8s-at-home      | opensource home automation solution             |
| kasten-k10       | 4.5.8  | 4.5.8      | kasten-k10       | backup/disaster recovery for volumesnapshots    |
| lidarr           | 14.0.0 | v1.0.0.2255| k8s-at-home      | Lidarr is a music collection manager            |
| nextcloud        | 2.11.3 | 22.2.3     | nextcloud        | self hosted dropbox alternative                 |
| nzbget           | 12.2.0 | 21.1       | k8s-at-home      | newsbin client to download from usenet          |
| openldap         | 2.1.6  | 2.4.57     | jp-gouin         | openldap / ltb-passwd / phpldapadmin in a chart |
| overseerr        | 5.2.0  | 1.26.1     | k8s-at-home      | manages requests for sonarr, radarr, plex       |
| plex             | 6.2.0  | 1.24.1     | k8s-at-home      | self hosted media transcoding/streaming service |
| prowlar          | 4.2.0  | 0.1.0.421  | k8s-at-home      | self hosted media transcoding/streaming service |
| radarr           | 16.0.0 | 3.2.2.5080 | k8s-at-home      | a fork of sonarr to work with movies            |
| rtorrent-flood   | 9.2.0  | 4.7.0      | k8s-at-home      | nodejs frontend for rtorrent ( with rtorrent )  |
| sonarr           | 16.0.0 | 3.0.6.1342 | k8s-at-home      | sonarr is a pv for Usenet and BitTorrent users  |
| uptime kuma      | 0.1.7  | 1.11.3     | duyet            | very simple nodejs uptime/status page           |
| vaultwarden      | 4.0.0  | 1.22.2     | k8s-at-home      | vaultwarden password manager                    |
| whoami           | 0.3.2  | 1.4.0      | halkeye          | whoami - simple go server to print http headers |

## Ingress
Right now Nginx Ingress Controller runs as a daemonset ( on all 3 nodes ) and binds to port 80/443 It is configured to be used as NodePort as i run these behind a NAT.
```
❯ k get svc -n nginx-ingress nginx-ingress-nginx-ingress-controller
NAME                                     TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
nginx-ingress-nginx-ingress-controller   NodePort   10.43.233.64   <none>        80:30847/TCP,443:30371/TCP   4h25m
```

Note: Klipper is k3s's inbuild service load balancer, so when we query port 80/443 we'll get:
```
❯ curl -s https://172.16.137.101/ -H "Host: whoami.awknode.cloud" --insecure |grep Forwarded-For
X-Forwarded-For: 10.42.0.11
```

however when we query the node ports for example 30371 for https, we ll get the right x-forwarded headers
```
❯ curl -s https://172.16.137.101:30371/ -H "Host: whoami.awknode.cloud" --insecure |grep Forwarded-For
X-Forwarded-For: 172.16.137.1
```

this is partially due to the externalTrafficPolicy
```
      - name: service.externalTrafficPolicy
        value: Local
```
## external-ip
my home has an ipv4 that semi regularly changes. to avoid having to setup another load balancer in front, i am running k3s with a --node-external-ip to set my public ip on all 3 nodes to my isp's public ip. the services/ingress inherit this value, this allows me to simply updated the systemd startup file / change my ip whenever my home ip changes. external-dns uses this public ip to send to cloudflare

## 10 Steps to set it up

### 1.) customizing the values to your liking ( terraform & argocd/helm )
#### 1.1.) Terraform
first head to the terraform folder and copy over the defaults variables, then edit the variables.tf you created. 
```
cd deploy/terraform

cp variables.tf.example variables.tf
nano variables.tf
```

### 2.) Bootstrap with terraform

the next part will create a new proxmox template based on debian 11 with cloud-init/nfs/iscsi support, afterwards it will create 3 vms of this template and install k3s as a 3 node k3s master-cluster. once the cluster is up it will install a helm chart for cert-manager, argocd and deploy/helm/bootstrap-core-apps. argocd is installed by feeding the argocd: section from deploy/helm/bootstrap-core-apps/values.yaml. this means that this values.yaml will contain all the config specific to your setup

you also have to edit the argocd-values.yaml inside the terraform folder, those will define the ingress for argocd.
```
terraform init
terraform plan
terraform apply
```

### 3.) Argocd two App of Apps
<b>deploy/helm/bootstrap-core-apps</b> is a local helm chart that creates an argocd "app of apps" in simple word it points at the deploy/argocd-core folder which contains one local helm chart, with an argocd application for each app running in the cluster. this chart contains the base we need in order to install the other charts ( but you dont have to customize anything for these )

<b>deploy/helm/bootstrap-optional-apps</b> is another local helm chart setup in the same way as the bootstrap-core-apps is with one major difference, you will need to edit the values for this chart, before synching argocd


### 4.) syncing bootstrap-core-apps via argocd dashboard
in this step we are going to sync the first set of apps, which are organized in bootstrap-core-apps helm chart. at this stage argocd is not yet reachable through ingress as we are missing nginx ingress, cert-manager, kubeseal and external-dns for it's ingress to function. so let's create a port forward using kubectl to connect to the cluster. we export the KUBECONFIG= to point to the kubeconfig file which was created by terraform apply.
```
export KUBECONFIG=$PWD/kubeconfig
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

```
kubectl -n argocd port-forward svc/argocd-server 8081:443
```

then head to https://localhost:8081 login with the username admin and the password returned by the kubectl get secret command

### 5.) sync bootstrap-core-apps
![todo](/docs/img/sync-argocd-core.png)
press the sync button at the top and wait for argocd to have synced all apps untill you see it being stuck on external-dns


### 6.) configure external-dns
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

### 7.) configure optional apps
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
./create_authelia_secret.sh awknode root@awknode.com topsecure
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

[more details on the apps in the docs/apps section](/docs/apps/README.md)
