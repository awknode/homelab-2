## setup nextcloud

#### prepare 

first we ll need to manually create a persistent volume
```
kubectl create namespace media
cd /tmp
nano media-persistent-volume-claim.yaml
```
now we insert the following text into this file:
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nextcloud-nextcloud
  namespace: nextcloud
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: freenas-iscsi-csi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nextcloud-nextcloud-data
  namespace: nextcloud
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1000Gi
  storageClassName: freenas-iscsi-csi
```
adjust the size/storageClassName and make sure they match the values from the deploy/argocd/bootstrap-optional-apps/values.yaml
```
kubectl apply -f media-persistent-volume-claim.yaml
persistentvolumeclaim/shared-media created
```

#### login 

- default username/password specified in nextcloud.yaml in helm-values secret
- first exec into the nextcloud pod, cd into /var/www/html/config and run a touch CAN_INSTALL file
- head to the website of nextcloud and connect it to the postgresql credentials
- go to apps section add "LDAP user and group backend"
- click on profile top right -> settings -> Ldap/AD Integration


##### ldap/Ad integration app setup
tab server:
- server: openldap-openldap-stack-ha.openldap.svc.cluster.local
- port: 389
- user dn: cn=admin,dc=ldap,dc=example,dc=com
- admin password
- click save credentials
- click detect base DN
- click test base DN
- password: adminPassword configured in openldap.yaml section inside mysecrets/*
- manually enter LDAP filters (recommended for large directories )

tab user:
- edit ldap query: (&(objectclass=inetOrgPerson))

tab login attributes: 
- ldap query: (&(objectclass=inetOrgPerson)(uid=%uid))
- enter username that exists in ldap and is in user group
- verify settings

tab groups
- ldap query: (&(objectClass=groupOfNames)(cn=users))