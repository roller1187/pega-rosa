oc new-project pega

oc apply -f postgres-12.yaml

oc apply -f opensearch.yaml

oc adm policy add-scc-to-user privileged -z default

oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
export REGISTRY=`oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}'`
echo $REGISTRY
podman login -u `oc whoami` -p `oc whoami --show-token` ${REGISTRY}

podman load -i pega_23_1_1.tar
podman load -i pega_srs.tar
podman load -i pega_23_install.tar

podman tag pega-docker.downloads.pega.com/platform/pega:23.1.1 ${REGISTRY}/default/pega:23.1.1
podman push ${REGISTRY}/default/pega:23.1.1
podman tag pega-docker.downloads.pega.com/platform-services/search-n-reporting-service-os:1.35.0 ${REGISTRY}/default/search-n-reporting-service-os:1.35.0
podman push ${REGISTRY}/default/search-n-reporting-service-os:1.35.0
podman tag pega-docker.downloads.pega.com/platform/installer:23.1.1 ${REGISTRY}/default/installer:23.1.1
podman push ${REGISTRY}/default/installer:23.1.1


