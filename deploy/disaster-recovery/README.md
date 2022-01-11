# disaster recovery with k10


## 1. wait till argocd is up too not sync bootstrap-apps yet

## 2. create disaster recovery secret
kubectl create secret generic k10-dr-secret \
   --namespace kasten-io \
   --from-literal key=mI6pYG8mOAT49CHa8Plr


## 3. sync bootstrap-apps

## 4. create location ( home ) in k10
kubectl -n kasten-io port-forward svc/gateway 8080:8000
http://localhost:8080/k10/#/ create location 
- type aws


## 5. install k10-restore helm chart
helm install k10-restore kasten/k10restore --namespace=kasten-io \
    --set sourceClusterID=2121701b-824c-47d3-8d80-a640ad5e49eb \
    --set profile.name=home \
    --set services.securityContext.runAsUser=1000