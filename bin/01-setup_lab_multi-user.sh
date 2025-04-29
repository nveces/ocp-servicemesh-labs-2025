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
done

##
# Creating a custom role to manage Istio Objects
##
cat <<EOF > admin-mesh-custom-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: admin-mesh
rules:
  - apiGroups:
    - ""
    resources:
    - secrets
    verbs:
    - create
    - get
    - list
    - watch
  - apiGroups:
    - ""
    - route.openshift.io
    resources:
    - routes
    verbs:
    - create
    - delete
    - deletecollection
    - get
    - list
    - patch
    - update
    - watch
  - apiGroups:
    - ""
    - route.openshift.io
    resources:
    - routes/custom-host
    verbs:
    - create
  - apiGroups:
    - ""
    - route.openshift.io
    resources:
    - routes/status
    verbs:
    - get
    - list
    - watch
  - apiGroups:
    - ""
    - route.openshift.io
    resources:
    - routes
    verbs:
    - get
    - list
    - watch
  - apiGroups:
    - maistra.io
    resources:
    - servicemeshmemberrolls
    verbs:
    - get
    - list
    - watch
  - apiGroups:
    - apps
    resources:
    - daemonsets
    - deployments
    - deployments/rollback
    - deployments/scale
    - replicasets
    - replicasets/scale
    - statefulsets
    - statefulsets/scale
    verbs:
    - patch
    - update
  - apiGroups:
    - networking.istio.io
    resources:
    - serviceentries
    - destinationrules
    verbs:
    - create
EOF

cat admin-mesh-custom-role.yaml | oc apply -f -

##
# Creating a custom role to connect to pods
##
cat <<EOF > connect-pods-custom-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: connect-pods
rules:
- apiGroups:
  - ""
  resources:
  - pods/attach
  - pods/exec
  - pods/portforward
  - pods/proxy
  - secrets
  - services/proxy
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - pods/attach
  - pods/exec
  - pods/portforward
  - pods/proxy
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
EOF

cat connect-pods-custom-role.yaml | oc apply -f -

cat <<EOF > template-custom-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dev-templates
rules:
  - verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    apiGroups:
      - template.openshift.io
    resources:
      - processedtemplates
EOF

cat template-custom-role.yaml | oc apply -f -


##
# Creating a custom role to create WASM extensions
##
cat <<EOF > wasm-mesh-custom-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: wasm-mesh
rules:
  - apiGroups:
    - extensions.istio.io
    resources:
    - wasmplugins
    verbs:
    - create
    - delete
    - deletecollection
    - get
    - list
    - patch
    - update
    - watch
EOF

cat wasm-mesh-custom-role.yaml | oc apply -f -

##
# Adding required roles to users
##
for i in ${USERS[@]}
do
  prj_name=$i-sm
  # Create Namespaces
  oc new-project ${prj_name}-mesh-external

  # Create and apply permission Nginx resources
  oc create sa nginx -n ${prj_name}-mesh-external
  oc adm policy add-scc-to-user anyuid -z nginx -n ${prj_name}-mesh-external

  # Apply permissions in openshift-ingress project
  oc adm policy add-role-to-user view         $i -n openshift-ingress
  oc adm policy add-role-to-user connect-pods $i -n openshift-ingress

  # Apply permissions in istio-system project
  oc adm policy add-role-to-user view           $i -n istio-system
  oc adm policy add-role-to-user connect-pods   $i -n istio-system
  oc adm policy add-role-to-user admin-mesh     $i -n istio-system
  oc adm policy add-role-to-user dev-templates  $i -n istio-system
  oc adm policy add-role-to-user mesh-user      $i -n istio-system --role-namespace istio-system

  # Apply permission in their namespaces
  oc adm policy add-role-to-user admin     $i -n ${prj_name}
  oc adm policy add-role-to-user wasm-mesh $i -n ${prj_name}
  oc adm policy add-role-to-user admin     $i -n ${prj_name}-mesh-external

done


# EOF