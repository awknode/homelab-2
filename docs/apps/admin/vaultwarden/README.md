## setup vaultwarden

#### rollout default application

by default i turn on the ADMIN_TOKEN, so we can do the inital config of the .env vars via a nice webui.

#### create secrets
```
kubectl create namespace vaultwarden
cd deploy/mysecrets
cp argocd-vaultwarden.yaml.example argocd-vaultwarden.yaml
nano argocd-vaultwarden.yaml

cat argocd-vaultwarden.yaml | kubeseal | kubectl apply -f -
```

now rollout the argocd application


### access admin webui on vaultwarden.example.com/admin enter the ADMIN_TOKEN value ( homelab )
now in webui set
- DOMAIN URL

depends on your email but this might be a startiung point:
- SMTP_HOST: mail.example.com
- SMTP_FROM: vaultwarden@example.com
- SMTP_FROM_NAME: vaultwarden
- SMTP_PORT: 587          # Ports 587 (submission) and 25 (smtp) are standard without encryption and with encryption via STARTTLS (Explicit TLS). Port 465 is outdated and used with Implicit TLS.
- SMTP_SSL: true          # (Explicit) - This variable by default configures Explicit STARTTLS, it will upgrade an insecure connection to a secure one. Unless SMTP_EXPLICIT_TLS is set to true. Either port 587 or 25 are default.
- SMTP_EXPLICIT_TLS: true # (Implicit) - N.B. This variable configures Implicit TLS. It's currently mislabelled (see bug #851) - SMTP_SSL Needs to be set to true for this option to work. Usually port 465 is used here.
- SMTP_USERNAME: vaultwarden@example.com
- SMTP_PASSWORD: homelab
- SMTP_TIMEOUT: 15
- SMTP_AUTH_MECHANISM: "STARTTLS"
- HELO_NAME: mail.example.com

- DATABASE_URL

here we're changing the DB_URL to use postgresql