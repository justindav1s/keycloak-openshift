#!/usr/bin/env bash

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi


exec /ib/appl/keycloak/bin/standalone.sh $@
exit $?
