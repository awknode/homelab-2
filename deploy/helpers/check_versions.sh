#!/bin/bash

function lastversion() {
    version=$(curl -s https://artifacthub.io/api/v1/packages/helm/$1/$2/feed/rss | xmlstarlet sel -t -m "/rss/channel/item[1]" -v "title")
    echo "$version"
    mkdir -p versions/$1
    currentVersion=`cat versions/$1/$2`
    if [ "$currentVersion" == "" ]; then
        echo $version > versions/$1/$2
    fi
}

# plexversion=`lastversion k8s-at-home plex`
# plexCurrentVersion=`cat versions/k8s-at-home/plex`
# echo plex current: $plexCurrentVersion remote: $plexversion

# argocd
argocdVersion=`lastversion argo argo-cd`
argocdVersionCurrent=`cat versions/argo/argo-cd`
echo argo-cd current: $argocdVersionCurrent remote: $argocdVersion

# certManager
certManagerVersion=`lastversion cert-manager cert-manager`
certManagerVersionCurrent=`cat versions/cert-manager/cert-manager`
echo cert-manager current: $certManagerVersionCurrent remote: $certManagerVersion