# JWT TOKEN + Istio:
REFERENCIA: https://istio.io/latest/docs/tasks/security/authorization/authz-jwt/

## Description: JWT Token

This task shows you how to set up an Istio authorization policy to enforce access based on a JSON Web Token (JWT). 
An Istio authorization policy supports both string typed and list-of-string typed JWT claims.

**A. Before you begin this task, do the following:**
- Complete the Istio end user authentication task.
    https://istio.io/latest/docs/tasks/security/authentication/authn-policy/#end-user-authentication

- Read the Istio authorization concepts.
    https://istio.io/latest/docs/concepts/security/#authorization

- Install Istio using Istio installation guide.
    https://istio.io/latest/docs/setup/install/istioctl/

- Deploy two workloads: httpbin and curl. Deploy these in one namespace, for example foo. Both workloads run with an Envoy proxy in front of each. Deploy the example namespace and workloads using these commands:

### Create namespace with istio annotations:
```
$ oc new-project user01
```

### Add this project to S.Mesh as a member:
```
$ oc edit smmr -n istio-system
```

### Then verify the change:
```
$ oc get smmr -n istio-system -o wide
```
```
OUTPUT:
NAME      READY   STATUS       AGE   MEMBERS
default   2/2     Configured   20h   ["user01"]
```

### Create serviceaccount, deployment and service for 'httpbin'.
```
$ oc apply -f 00.deploy-httpbin.yaml
```
```
OUTPUT:
serviceaccount/httpbin created
service/httpbin created
deployment.apps/httpbin created
```

*IMPORTANT*: you should see 2 pods running related to httpin, that is due to the annotation **sidecar.istio.io/inject: "true"** in the Deployment. If not, please verify your configuration (Deployment and SMMR). 

```
$ oc get pods
NAME                       READY   STATUS    RESTARTS   AGE
httpbin-646ff6b857-v52rq   2/2     Running   0          2m1s
```

### Create serviceaccount, deployment and service for 'curl'.
```
$ oc apply -f 01.curl.yaml
```
```
OUTPUT:
serviceaccount/curl created
service/curl created
deployment.apps/curl created
```

### Verify that curl successfully communicates with httpbin using this command:

```
$ oc project $MY_PROJECT (user01)

$ oc exec "$(oc get pod -l app=curl -o jsonpath={.items..metadata.name})" -c curl -- curl http://httpbin:8000/ip -sS -o /dev/null -w "%{http_code}\n"
```
```
OUTPUT:
200   (indicate that httpbin response correctly)
```

IMPORTANT: If not working, you can try adding the namespace as follows:
```
$ oc exec "$(oc get pod -l app=curl -n user01 -o jsonpath={.items..metadata.name})" -c curl -n user01 -- curl http://httpbin.user01:8000/ip -sS -o /dev/null -w "%{http_code}\n"
```

**B. Allow requests with valid JWT and list-typed claims** 
(https://istio.io/latest/docs/tasks/security/authorization/authz-jwt/#allow-requests-with-valid-jwt-and-list-typed-claims)

1. The following command creates the **'jwt-example' request authentication** policy for the httpbin workload in the namespace. This policy for httpbin workload accepts a JWT issued by testing@secure.istio.io:

```
$ oc apply -f 02.request-authentication.yaml
```
```
OUTPUT:
requestauthentication.security.istio.io/jwt-example created
```

2. Verify that a request with an invalid JWT is denied:
```
$ oc exec "$(oc get pod -l app=curl -o jsonpath={.items..metadata.name})" -c curl  -- curl "http://httpbin:8000/headers" -sS -o /dev/null -H "Authorization: Bearer invalidToken" -w "%{http_code}\n"
```
```
OUTPUT:
401  (indicate that request with an invalid JWT is denied)
```

IMPORTANT: If not working as expected, you can try adding the namespace as follows:
```
$ oc exec "$(oc get pod -l app=curl -n foo -o jsonpath={.items..metadata.name})" -c curl -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -H "Authorization: Bearer invalidToken" -w "%{http_code}\n"
```

3. Verify that a request without a JWT is allowed because there is no authorization policy:
```
$ oc exec "$(oc get pod -l app=curl -o jsonpath={.items..metadata.name})" -c curl -- curl "http://httpbin:8000/headers" -sS -o /dev/null -w "%{http_code}\n"
```
```
OUTPUT:
200 (OK!)        
```

IMPORTANT: If not working as expected, you can try adding the namespace as follows:
```
$ oc exec "$(oc get pod -l app=curl -n user01 -o jsonpath={.items..metadata.name})" -c curl -n user01 -- curl "http://httpbin.user01:8000/headers" -sS -o /dev/null -w "%{http_code}\n"
```

4. The following command creates the **'require-jwt' authorization policy** for the httpbin workload in the namespace. The policy requires *all requests to the httpbin workload to have a valid JWT* with requestPrincipal set to testing@secure.istio.io/testing@secure.istio.io. Istio constructs the requestPrincipal by combining the iss and sub of the JWT token with a / separator as shown:    
```
$ oc apply -f 03.authorization-policy.yaml
```
```
OUTPUT:
authorizationpolicy.security.istio.io/require-jwt created
```

Then run again the step 3:
```
oc exec "$(oc get pod -l app=curl -o jsonpath={.items..metadata.name})" -c curl -- curl "http://httpbin:8000/headers" -sS -o /dev/null -w "%{http_code}\n"
```
```
OUTPUT: 403 (indicates the auth.policy blocked a request without token)
```

5. Get the JWT that sets the iss and sub keys to the same value, testing@secure.istio.io. This causes Istio to generate the attribute requestPrincipal with the value testing@secure.istio.io/testing@secure.istio.io:
```
TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.26/security/tools/jwt/samples/demo.jwt -s) && echo "$TOKEN" | cut -d '.' -f2 - | base64 --decode
```

6. Verify that a request with a valid JWT is allowed:
```
$ oc exec "$(oc get pod -l app=curl -o jsonpath={.items..metadata.name})" -c curl -- curl "http://httpbin:8000/headers" -sS -o /dev/null -H "Authorization: Bearer $TOKEN" -w "%{http_code}\n"
```
```
OUTPUT: 
200 ( A REQUEST WITH A VALID TOKEN WORKS FINE!!)
```

7. The following command **updates** the require-jwt authorization policy to also require the **JWT to have a claim named groups** containing the value **group1**:
```
$ oc apply -f 04.authorization-policy-group1.yaml
```
```    
OUTPUT: 
authorizationpolicy.security.istio.io/require-jwt configured
```

8. Get the JWT that sets the groups claim to a list of strings: group1 and group2:
```
$ TOKEN_GROUP=$(curl https://raw.githubusercontent.com/istio/istio/release-1.26/security/tools/jwt/samples/groups-scope.jwt -s) && echo "$TOKEN_GROUP" | cut -d '.' -f2 - | base64 --decode
```
```
OUTPUT: 
{"exp":3537391104,"groups":["group1","group2"],"iat":1537391104,"iss":"testing@secure.istio.io","scope":["scope1","scope2"],"sub":"testing@secure.istio.io"}
```

9. Verify that a request with the JWT that includes group1 in the groups claim is allowed:
```
$ oc exec "$(oc get pod -l app=curl -n foo -o jsonpath={.items..metadata.name})" -c curl -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -H "Authorization: Bearer $TOKEN_GROUP" -w "%{http_code}\n"
```
```
OUTPUT:
200 (request allowed!!)
```

10. Verify that a request with a JWT, which doesn’t have the groups claim **is rejected**:
```
$ oc exec "$(oc get pod -l app=curl -n foo -o jsonpath={.items..metadata.name})" -c curl -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -H "Authorization: Bearer $TOKEN" -w "%{http_code}\n"
```
```
OUTPUT:
403 (request with INVALID TOKEN is NOT ALLOWED!)
```

