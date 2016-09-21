#!/bin/bash

oc delete service keycloak
oc delete pod keycloak-1-build
oc delete build keycloak-1-build
oc delete buildconfig keycloak
oc delete deploymentconfig keycloak
oc delete imagestream keycloak
oc delete route keycloak
