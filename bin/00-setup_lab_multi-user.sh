#!/bin/bash
#
# ============================================================
# Red Hat Consulting EMEA, 2025
#
# ============================================================
# Description---:
# ============================================================
#
#
# chmod 774 *.sh
#
#
# EOH


##
# Script to prepare Openshift Laboratory
##

##
# Users
##

num_users=25

# New USERS array
#USERS=("user01" "user02" "user03" "user04" "user05" "user06" "user07" "user08" "user09" )
USERS=()

# populating USERS array
for ((i=1; i<=num_users; i++)); do
  user_name=$(printf "user%02d" $i)
  USERS+=("$user_name")
done

# # checking USERS array
# for i in ${USERS[@]}
# do
#   echo "We will use: htpasswd -b users.htpasswd $i $i"
# done



htpasswd -c -b users.htpasswd admin MzAwMjc5
htpasswd -b users.htpasswd redhat redhat01
htpasswd -b users.htpasswd user25 redhat01

for i in ${USERS[@]}
do
  htpasswd -b users.htpasswd $i $i
done

exit 0

GITOPS_NS="openshift-gitops"

##
# Adding user to htpasswd
##
# htpasswd -c -b users.htpasswd admin MzAwMjc5
# htpasswd -c -b users.htpasswd redhat redhat01
# htpasswd -c -b users.htpasswd user25 redhat01
# for i in ${USERS[@]}
# do
#   htpasswd -b users.htpasswd $i $i
# done
# htpasswd  -b users.htpasswd admin MzAwMjc5
# htpasswd  -b users.htpasswd redhat redhat01
# htpasswd  -b users.htpasswd user25 redhat01

#exit 1

##
# Creating htpasswd file in Openshift
##
oc delete secret lab-users -n openshift-config
oc create secret generic lab-users --from-file=htpasswd=users.htpasswd -n openshift-config

##
# Configuring OAuth to authenticate users via htpasswd
##
cat <<EOF > oauth.yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - htpasswd:
      fileData:
        name: lab-users
    mappingMethod: claim
    name: htpasswd_provider
    type: HTPasswd
EOF

cat oauth.yaml | oc apply -f -

##
# Disable self namespaces provisioner
##
oc patch clusterrolebinding.rbac self-provisioners -p '{"subjects": null}'

##
# Creating Role Binding for admin user
##
oc adm policy add-cluster-role-to-user admin admin

##
# Create Cluster Roles for Tekton (Manage triggers and get secret content in all namespaces)
##
#oc apply -f ./scripts/files/tekton_cluster_roles.yaml

##
# Install Pipelines Operator
##
#oc apply -f ./scripts/files/redhat_pipelines.yaml
#sleep 60

##
# Install GitOps Operator
##
#oc apply -f ./scripts/files/redhat_gitops.yaml
#sleep 60

exit 0
for i in ${USERS[@]}
do

  ##
  # Create required namespaces for each user
  ##
  oc new-project $i-sm
  #oc label namespace $i-sm argocd.argoproj.io/managed-by=$i-gitops-argocd --overwrite
  oc adm policy add-role-to-user admin $i -n $i-sm
  #oc adm policy add-role-to-user admin system:serviceaccount:$i-gitops-argocd:argocd-argocd-application-controller -n $i-jump-app-dev


  # oc new-project $i-jump-app-cicd
  # oc label namespace $i-jump-app-cicd argocd.argoproj.io/managed-by=$i-gitops-argocd --overwrite
  # oc adm policy add-role-to-user admin $i -n $i-jump-app-cicd
  # oc adm policy add-role-to-user admin system:serviceaccount:$i-gitops-argocd:argocd-argocd-application-controller -n $i-jump-app-cicd
  # oc adm policy add-cluster-role-to-user tekton-admin-view system:serviceaccount:$i-jump-app-cicd:tekton-deployments-admin
  # oc adm policy add-cluster-role-to-user secret-reader system:serviceaccount:$i-jump-app-cicd:tekton-deployments-admin
  # oc adm policy add-cluster-role-to-user secret-reader system:serviceaccount:$i-jump-app-cicd:pipeline

  # oc new-project $i-gitops-argocd
  # oc label namespace $i-gitops-argocd argocd.argoproj.io/managed-by=$i-gitops-argocd --overwrite
  # oc adm policy add-role-to-user admin $i -n $i-gitops-argocd
  # oc adm policy add-role-to-user admin system:serviceaccount:$i-gitops-argocd:argocd-argocd-application-controller -n $i-gitops-argocd

  ##
  # Create ArgoCD Roles and Rolebindings
  ##
  # oc process -f ./scripts/files/argocd_objs.yaml -p USERNAME=$i | oc apply -f -

  ##
  # Install ArgoCD Operator
  ##
  # oc process -f ./scripts/files/argocd_operator.yaml -p USERNAME=$i | oc apply -f -
  # sleep 30

  ##
  # Install ArgoCD
  ##
  #oc apply -f ./scripts/files/argocd.yaml -n $i-gitops-argocd

  ##
  # Install ArgoCD Project
  ##
  #oc process -f ./scripts/files/argocd_project.yaml -p USERNAME=$i | oc apply -f -

done

# for i in ${USERS[@]}
# do
#   GITOPS_NS="${GITOPS_NS},${i}-gitops-argocd"
# done

# oc patch subscription openshift-gitops-operator -n openshift-operators -p '{"spec":{"config":{"env":[{"name":"ARGOCD_CLUSTER_CONFIG_NAMESPACES","value":"'${GITOPS_NS}'"}]}}}' --type=merge

exit 0

# EOF