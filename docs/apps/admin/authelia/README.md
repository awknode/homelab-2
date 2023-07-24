### setup authelia

#### notifier
by default it uses notifier.filesystem, means that it will not send emails but echo them to  /config/notification.txt i suggest you setup email instead and enable = false the filesystem


#### create account
by default it uses the authentification backend file so it will read from the secret you generated with deploy/mysecrets/create_authelia_secret.sh if you have openldap running from the other chart you can also turn on ldap as a backend.
head over to https://auth.example.com
