## setup openldap

#### Openldap

this is a larger thing to setup but it does come with all required tools to run/debug. lets first take a look at the argocd-optional.yaml values

    adminPassword: homelab
    configPassword: homelab

this ldap comes with a structure for ldap.example.com ( or in ldap lingo dc=ldap,dc=example,dc=com )

this adminPassword will be whats used to login to ldap-admin.example.com ( your ui to manage your ldap structure ) the username for this would be:
Login DN: cn=admin,dc=ldap,dc=example,dc=com
Password: homelab

once logged into ldap-admin click on import and post something along the lines of:

```
version: 1

# Entry 2: ou=Group,dc=ldap,dc=example,dc=com
dn: ou=Group,dc=ldap,dc=example,dc=com
objectclass: organizationalUnit
objectclass: top
ou: Group

# Entry 3: cn=admins,ou=Group,dc=ldap,dc=example,dc=com
dn: cn=admins,ou=Group,dc=ldap,dc=example,dc=com
cn: admins
member: uid=loeken,ou=User,dc=ldap,dc=example,dc=com
objectclass: groupOfNames
objectclass: top

# Entry 4: cn=users,ou=Group,dc=ldap,dc=example,dc=com
dn: cn=users,ou=Group,dc=ldap,dc=example,dc=com
cn: users
member: uid=loeken,ou=User,dc=ldap,dc=example,dc=com
objectclass: groupOfNames
objectclass: top

# Entry 5: ou=User,dc=ldap,dc=example,dc=com
dn: ou=User,dc=ldap,dc=example,dc=com
objectclass: organizationalUnit
objectclass: top
ou: User

# Entry 6: uid=loeken,ou=User,dc=ldap,dc=example,dc=com
dn: uid=loeken,ou=User,dc=ldap,dc=example,dc=com
cn: loeken
displayname: loeken
mail: loeken@example.me
objectclass: inetOrgPerson
objectclass: top
sn: Filewalker
uid: loeken
userpassword: {CRYPT}$5$WtLavDZC$ScD.IMUJdgRhMZMtAlyYtbqezxsQ2qfWTVbQOFo5tg4
```

the userpassword resolves to "homelab"

#### creating a new user

create a user in the Ou=User then head to the Ou=Group section to add the user to a group