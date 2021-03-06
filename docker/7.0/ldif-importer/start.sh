#!/usr/bin/env bash

# Checking idrepo store is up

wait_repo() {
    REPO="$1-0.$1"
    echo "Waiting for $REPO to be available. Trying /alive endpoint"
    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $REPO:8080/alive)" != "200" ]];
    do
            sleep 5;
    done
    echo "$REPO is responding"
}


wait_repo ds-idrepo
wait_repo ds-cts


# Set the DS passwords for each store
if [ -f "/opt/opendj/ds-passwords.sh" ]; then
    echo "Setting directory service account passwords"
    /opt/opendj/ds-passwords.sh
    if [ $? -ne 0 ]; then
        echo "ERROR: Pre install script failed"
        exit 1
    fi
fi

# Apply the new ldap config entries
# Remove this once the ds profile has been updated to include FBC
/opt/opendj/bin/ldapmodify -c \
    -D uid=admin \
    -j /var/run/secrets/opendj-passwords/dirmanager.pw \
    -h ds-idrepo-0.ds-idrepo \
    -p 1389 \
    /opt/opendj/external-am-datastore.ldif
