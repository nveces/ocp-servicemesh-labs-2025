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

V_ADMIN_DIR=$(dirname $0)

num_users=21

# New USERS array
#USERS=("user01" "user02" "user03" "user04" "user05" "user06" "user07" "user08" "user09" )
USERS=()


# populating USERS array
for ((i=1; i<=num_users; i++)); do
  user_name=$(printf "user%02d" $i)
  USERS+=("$user_name")
  prj_name=${user_name}-sm
  oc project  $prj_name
  #oc process -f ${V_ADMIN_DIR}/../lab-02/02-jump-app-deploy/jump-app-template.yml -p USER_NAMESPACE=${prj_name} -p OCP_APPS_DOMAIN=apps.ocp.sandbox2790.opentlc.com --ignore-unknown-parameters | oc apply -f -
  #oc process -f ${V_ADMIN_DIR}/../lab-02/02-jump-app-deploy/jump-app-template.yml -p USER_NAMESPACE=${prj_name} -p OCP_APPS_DOMAIN=apps.ocp.sandbox2790.opentlc.com --ignore-unknown-parameters | oc delete -f -
done

exit 0

# EOF