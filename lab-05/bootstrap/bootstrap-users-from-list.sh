#!/bin/bash

MESH_NS=$1
USERS_LIST=$2

ADMIN_USER=$3
OCP_API=$4

TMP_FILE=additional-ingress-tmp

oc login -u $ADMIN_USER $OCP_API

oc apply -f ./ocp/roles/labs-istio.yaml

for line in `cat $USERS_LIST`
do
  IFS='#' read -r -a array <<< "$line"
  echo "Bootstraping user => ${array[0]}  ${array[1]}"
  ./bootstrap-user.sh $MESH_NS ${array[0]}  ${array[1]} 
  echo "-------------------------------"
  cat smcp/additional-ingress.yaml | USER_NS=${array[1]} envsubst >> $TMP_FILE
  echo -e "\r" >> $TMP_FILE
done 

cat smcp/basic.yaml | ADDITIONAL_INGRESS=`cat $TMP_FILE` envsubst | oc apply -f - -n $MESH_NS

rm -rf $TMP_FILE