#!/bin/bash
#
# ============================================================
# Red Hat Consulting EMEA, 2025
#
# Created-------:
# ============================================================
# Description--: Delete Projects
# ============================================================
#
# ============================================================
# Pre Steps---:
# chmod 774 *.sh
# ============================================================
#
#
#
# EOH

num_users=25

# New USERS array
USERS=()
NAMESPACES=("-sm")

# populating USERS array
for ((i=1; i<=num_users; i++)); do
  user_name=$(printf "user%02d" $i)
  USERS+=("$user_name")
  for ns in ${NAMESPACES[@]}
    do
        prj_name=${user_name}${ns}
        echo "Deleting project use: ${prj_name}"
        oc delete project ${prj_name} --wait=true
    done
done

# checking USERS array
# for i in ${USERS[@]}
# do
#     echo "The projects has been deleted: ${prj_name}"
# done

exit 0

#
# EOF