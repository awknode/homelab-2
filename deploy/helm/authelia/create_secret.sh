#!/bin/bash
mypasswd="ajsd9123ghsd"
hashed_pass=`docker run authelia/authelia:latest authelia hash-password $mypasswd | cut -d' ' -f 3`
echo $hashed_pass / "s/replacesecret/$hashed_pass/g"
sed "s/replacesecret/$hashed_pass/g" users.yaml > myusers.yaml
kubectl create secret generic -n authelia authelia-users --from-file=users_database.yml=myusers.yaml --dry-run=client -oyaml | kubeseal | kubectl apply -f -