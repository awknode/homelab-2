## setup plex

```
kubectl -n media port-forward svc/plex 32400:32400
```

now visit http://localhost:32400/web, "got it", close popup. Give the server a name and click next

now on the "add library" screen i ll add 2 libraries one for movies, one for tv, the paths are /media/movies & /media/tv