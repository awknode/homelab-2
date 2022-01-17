## setup plex

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

so now i've created 4 folders/categories i ll plan on holding my data in.

```
kubectl -n media port-forward svc/plex 32400:32400
```

now visit http://localhost:32400/web, "got it", close popup. Give the server a name and click next

now on the "add library" screen i ll add 2 libraries one for movies, one for tv, the paths are /media/movies & /media/tv