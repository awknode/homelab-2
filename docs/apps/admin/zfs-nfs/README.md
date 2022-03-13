## democratic csi iscsi

#### basic truenas setup
make sure you followed the zfs-iscsi setup instructions for truenas
[zfs-iscsi](../zfs-iscsi/README.md)


#### customize your settings

```
cd deploy/mysecrets/
cp argocd-democratic-csi-nfs.yaml.example argocd-democratic-csi-nfs.yaml
nano argocd-democratic-csi-nfs.yaml
```

now in here change the ip 172.16.137.13 with the ip of your truenas, update the root password for truenas and insert the id_rsa_truenas private key, after that is done we can send this to kubeseal and apply the encrypted version

```
cat argocd-democratic-csi-iscsi.yaml | kubeseal | kubectl apply -f -
```