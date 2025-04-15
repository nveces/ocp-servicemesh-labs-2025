# Service Mesh: Envoy & Istio Control Plane Tutorial Resources

Service Mesh: Envoy & Istio Control Plane Tutorial Resources

## 01 - Setup

- Modified params.env with the parameters provided by the Instructor at the beginning of this tutorial

```$bash
vi params.env
USER_NAMESPACE="userXX_namespace"
OCP_APPS_DOMAIN="apps.labs.mydomain.com"
```

## 02 - Deploy _Jump App_ Microservices

- Deploy _Jump App_ using an Openshift Template 

```$bash
oc process -f 02-jump-app-deploy/jump-app-template.yml --param-file=params.env --ignore-unknown-parameters | oc create -f -
```

## 03 - Create _Jump App_ Istio Objects

- Deploy _Jump App_ Gateways using an Openshift Template 

```$bash
oc process -f 03-jump-app-flows/00-jump-app-gws.yaml --param-file=params.env --ignore-unknown-parameters | oc create -f -
```

- Deploy _Jump App_ Virtual Services using an Openshift Template 

```$bash
oc process -f 03-jump-app-flows/01-jump-app-vss.yaml --param-file=params.env --ignore-unknown-parameters | oc create -f -
```

- Deploy _Jump App_ Destination Rules using an Openshift Template 

```$bash
oc process -f 03-jump-app-flows/02-jump-app-drs.yaml --param-file=params.env --ignore-unknown-parameters | oc create -f -
```

- Deploy _Jump App_ K8s Services using an Openshift Template 

```$bash
oc process -f 03-jump-app-flows/03-jump-app-services.yaml --param-file=params.env --ignore-unknown-parameters | oc create -f -
```

- Deploy _Jump App_ Routes using an Openshift Template 

```$bash
oc process -f 03-jump-app-flows/04-jump-app-routes.yaml --param-file=params.env --ignore-unknown-parameters | oc create -f - -n istio-system
```

## 04 - Review Red Hat Service Mesh objects

- Modify _Jump App_ a specific Destination Rule using an Openshift Template 

```$bash
oc process -f 04-istio-envoy-relationship/00-istio-envoy-rel-drs.yaml --param-file=params.env --ignore-unknown-parameters | oc create -f -
```

- Modify _Jump App_ a specific Virtual Service using an Openshift Template 

```$bash
oc process -f 04-istio-envoy-relationship/01-istio-envoy-rel-vss.yaml --param-file=params.env --ignore-unknown-parameters | oc create -f -
```

- Modify _Jump App_ a specific Service Entry using an Openshift Template 

```$bash
oc process -f 04-istio-envoy-relationship/02-istio-envoy-rel-ses.yaml --param-file=params.env --ignore-unknown-parameters | oc create -f -
```

## 05 - Understand Envoy Proxy

- Deploy a _Jump App_ Envoy Filter using an Openshift Template 

```$bash
oc process -f 05-envoy-proxy/00-istio-envoy-rel-ef.yaml --param-file=params.env --ignore-unknown-parameters | oc apply -f -
```

## Istio Control Plane 

- Create _ServiceMeshMember_ Object 

```$bash
oc process -f 06-istio-ctrlplane/00-jump-app-ns-smr.yaml--param-file=params.env --ignore-unknown-parameters | oc create -f -
```

## 07 - Istio Global Services

- Modify existing gateway object

```$bash
oc process -f 07-istio-sds/00-jump-app-front-gw.yaml --param-file=params.env --ignore-unknown-parameters | oc apply -f -
```

- Modify existing route object

```$bash
oc process -f 07-istio-sds/01-jump-app-front-route.yaml --param-file=params.env --ignore-unknown-parameters | oc apply -f - -n istio-system
```


## Author Information

Asier Cidon @Red Hat

asier.cidon@gmail.com
