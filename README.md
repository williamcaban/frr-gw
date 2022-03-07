# FRRouting Based OCP Multiple External Gateway 

> :heavy_exclamation_mark: *Red Hat does not provide commercial support for the content of these repos*

```bash
#############################################################################
DISCLAIMER: THESE ARE UNSUPPORTED COMMUNITY TOOLS.

THE REFERENCES ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#############################################################################
```

This repository contains an example lab configuration for using an FRR-based Pod with the OVN Kubernetes Multiple External Gateway capability.

To restrict the external gateway functionality to only work on a pre-selected set of namespaces, an example security profile using Kyverno has been included.

NOTE: At this moment Kyverno is an upstream project without a validated or certified Operator.

- Installing [Kyverno](https://kyverno.io/docs/introduction/)

    ```bash
    oc create -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/release/install.yaml
    ```
- Install NMState Operator (pre-requisite)
- Update the manifests to match your environment, then apply them in the following order
```bash
# Configure NMState Operator
# Note: update to match your environment
oc apply -f 01-nmstate-nodeselector.yaml

# Configure NMState for external and internal NICs
# Note: update to match your environment
oc apply -f 02-nmstate-external-net.yaml
oc apply -f 02-nmstate-internal-net.yaml

# Create "frr" namespace and multus network definitions
# Note: update to match your environment
oc apply -f 03-create-namespace.yaml
oc apply -f 03-network-definition.yaml

# Configure Kyverno security policy
# Note: update to match your environment
oc apply -f 05-kyverno-cluster-policy.yaml

# Create example Namespaces and Pods
# Note: update to match your environment
oc apply -f 07-dummy-ns-foo-bar.yml
oc apply -f 07-dummy-pod-bar.yaml
oc apply -f 07-dummy-pod-foo.yaml

# Create ConfigMap and Pod for external gateway
# Note: update to match your environment
oc apply -f 10-frr-configmap.yaml
oc apply -f 10-frr-pod.yaml
```

## TIPs

- Generating the static routes entries for nodes subnets
```bash
oc get nodes -o jsonpath='{range .items[*].metadata.annotations}{.k8s\.ovn\.org\/node\-subnets}{.k8s\.ovn\.org\/node\-primary\-ifaddr}{"\n"}{end}' | awk -F'["/]' '{print "ip route " $4"/"$5 " " $9}'
ip route 10.128.2.0/23 198.18.111.12
ip route 10.129.0.0/23 198.18.111.13
ip route 10.128.0.0/23 198.18.111.14
ip route 10.130.0.0/23 198.18.111.15
ip route 10.131.0.0/23 198.18.111.16
```

- A reference configuration for an upstream router is `99-frr-upstream-router.conf`