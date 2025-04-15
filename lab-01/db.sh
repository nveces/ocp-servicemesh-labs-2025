#!/usr/bin/env bash

printf "\n\n######## Deploying PostgreSQL ########\n"

# kubectl apply -f src/main/kubernetes/pgsql.yml
oc apply -f pgsql.yml
# oc wait --for=condition=available --timeout=60s deployment/postgresql
oc wait --for=condition=available --timeout=60s deployment/petclinic-database

printf "\n\n######## Create Schema PostgreSQL ########\n"

# kubectl apply -f src/main/kubernetes/pgsql-db-creator.yml
oc apply -f pgsql-db-creator.yml
oc wait --for=condition=complete job/petclinic-schema