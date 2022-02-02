#!/bin/bash
# $1=username $2=email $3=password 
mypasswd="$3"
hashed_pass=`docker run authelia/authelia:latest authelia hash-password $mypasswd | cut -d' ' -f 3`
echo $hashed_pass
echo 'users:
  loeken:
    displayname: "admin"
    password: "'$hashed_pass'"
    email: "'$2'"
    groups:
      - admins
      - users' > authelia_config.yaml
      
kubectl create secret generic -n authelia authelia-users --from-file=users_database.yml=authelia_config.yaml --dry-run=client -oyaml | kubeseal | kubectl apply -f -