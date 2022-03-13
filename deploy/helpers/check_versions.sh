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

# externalDns
externalDnsVersion=`lastversion bitnami external-dns`
externalDnsVersionCurrent=`cat versions/bitnami/external-dns`
echo external-dns current: $externalDnsVersionCurrent remote: $externalDnsVersion

# nginx-ingress
nginxIngresVersion=`lastversion bitnami nginx-ingress-controller`
nginxIngresVersionCurrent=`cat versions/bitnami/nginx-ingress-controller`
echo nginx-ingress-controller current: $nginxIngresVersionCurrent remote: $nginxIngresVersion

# sealed-secrets
sealedSecretsVersion=`lastversion bitnami-labs sealed-secrets`
sealedSecretsVersionCurrent=`cat versions/bitnami-labs/sealed-secrets`
echo sealed-secrets current: $sealedSecretsVersionCurrent remote: $sealedSecretsVersion