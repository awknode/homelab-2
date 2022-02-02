## setup nextcloud

#### login 

- default username admin/changeme
- go to apps section add "LDAP user and group backend"
- click on profile top right -> settings -> Ldap/AD Integration


##### ldap/Ad integration app setup
tab server:
- server: openldap-openldap-stack-ha.openldap.svc.cluster.local
- port: 389
- user dn: cn=admin,dc=ldap,dc=example,dc=com
- click save credentials
- click detect base DN
- click test base DN
- password: adminPassword configured in openldap.yaml section inside mysecrets/*
- manually enter LDAP filters (recommended for large directories )

tab user:
- ldap query: (&(objectclass=inetOrgPerson))

tab login attributes: 
- ldap query: (&(objectclass=inetOrgPerson)(uid=%uid))
- enter username that exists in ldap and is in user group
- verify settings

tab groups
- ldap query: (&(objectClass=groupOfNames)(cn=user))