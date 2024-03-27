# Vault Oracle

Using Vault's Database Secrets Engine, stand up Oracle under Docker & configure Vault to generate credentials dynamically or statically to illustrate how this can scale to many databases.

## Create Vault & MongoDB via Docker Compose

```bash

./run all

cat ./sensitive/vault.txt | grep '^Initial' | awk '{print $4}'

vault login

vault read ldap_bar/creds/dynamic-role

vault read ldap_foo/creds/dynamic-role

vault read ldap_qux/creds/dynamic-role

open http://localhost:8080
# CN=admin,DC=qux,DC=local
# admin is the password
# see users created

./run cleanup

```

# To verify your vault init container logs:

docker logs tools-vaultsetup-1

# To verify your vault service container logs:

docker logs tools-vault-1


```


