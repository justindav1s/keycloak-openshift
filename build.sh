#!/bin/bash

git pull origin master
docker build -t ib-keycloak .
docker tag ib-keycloak 172.30.88.121:5000/openshift/ib-keycloak
docker push 172.30.88.121:5000/openshift/ib-keycloak