## setup shared-media persistent volume

first we ll need to manually create a persistent volume
```
cd deploy/mysecrets
kubectl apply -f media-persistent-volume-claim.yaml
persistentvolumeclaim/shared-media created
```

preparing the folder, this can be done from any pod that mounts the shared volume, i ll do it from the rtorrent pod.

```
❯ k exec -it -n media rtorrent-flood-84f6c7c6d4-mlhq2 ash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/ $ cd /downloads/
/downloads $ mkdir movies
/downloads $ mkdir tv
/downloads $ mkdir music
/downloads $ mkdir games
```