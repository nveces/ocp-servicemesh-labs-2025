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

num_users=25

# New USERS array
USERS=()

# populating USERS array
for ((i=1; i<=num_users; i++)); do
  user_name=$(printf "user%02d" $i)
  USERS+=("$user_name")

  prj_name=$user_name-sm
  # Configure Namespaces
  oc project ${prj_name}-mesh-external
  oc process -f ../lab-02/06-istio-ctrlplane/00-jump-app-ns-smr.yaml --ignore-unknown-parameters | oc apply -f -

done


exit 0


# EOF