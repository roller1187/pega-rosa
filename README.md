# Summary

This repository can be used to deploy PEGA on a OpenShift self-managed or managed service. So far, it has ben tested to work on ROSA, ROSA GovCloud and traditional OCP.

# Usage

The instructions laid out below, are based on the instructions provided from [PEGA docs](https://github.com/pegasystems/pega-helm-charts/tree/master/docs) to deploy the application:

**NOTE:** This deployment was tested on ROSA 4.15.45, using a bastion host with OS version RHEL 8.6

## Deployment steps

1. Clone this repo

2. Install Helm: [instructions](https://github.com/pegasystems/pega-helm-charts/blob/master/docs/prepping-local-system-runbook-linux.md#installing-helm)
   
3. Install the OpenShift CLI (oc): [instructions](https://docs.openshift.com/container-platform/4.15/cli_reference/openshift_cli/getting-started-cli.html)

4. Obtain the following 3 PEGA container images provided by [PEGA](https://github.com/pegasystems/pega-helm-charts/blob/master/docs/prepping-local-system-runbook-linux.md#downloading-a-pega-platform-installer-docker-image):

  - pega-docker.downloads.pega.com/platform/installer
  - pega-docker.downloads.pega.com/platform/pega
  - pega-docker.downloads.pega.com/platform-services/search-n-reporting-service-os

5. Create a new namespace
```bash
oc new-project pega
```

6. Expose the OpenShift internal registry and login:
```bash
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
export REGISTRY=`oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}'`

podman login -u `oc whoami` -p `oc whoami --show-token` ${REGISTRY}
```

7. Load the local images and tag them:

```bash
podman load -i pega_23_1_1.tar
podman load -i pega_srs.tar
podman load -i pega_23_install.tar

podman tag pega-docker.downloads.pega.com/platform/pega:23.1.1 ${REGISTRY}/default/pega:23.1.1
podman tag pega-docker.downloads.pega.com/platform-services/search-n-reporting-service-os:1.35.0 ${REGISTRY}/default/search-n-reporting-service-os:1.35.0
podman tag pega-docker.downloads.pega.com/platform/installer:23.1.1 ${REGISTRY}/default/installer:23.1.1
```

8. Push local images to the OpenShift internal registry
```bash
podman push ${REGISTRY}/pega/pega:23.1.1
podman push ${REGISTRY}/pega/search-n-reporting-service-os:1.35.0
podman push ${REGISTRY}/pega/installer:23.1.1
```

9. Deploy Openseach using the following steps:

```bash
# Assign required privileges for the service account
oc adm policy add-scc-to-user privileged -z default
```

```bash
# Create PVCs
oc apply -f opensearch.yaml
```

```bash
# Add Helm repo and install Opensearch
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm install opensearch opensearch/opensearch --version 2.17.0 --namespace pega
oc scale statefulset opensearch-cluster-master --replicas=0
```

```bash
# Add a password and disable SSL
oc set env statefulset/opensearch-cluster-master OPENSEARCH_INITIAL_ADMIN_PASSWORD=Openshift123!
oc set env statefulset/opensearch-cluster-master plugins.security.disabled=true
oc set env statefulset/opensearch-cluster-master plugins.security.ssl.http.enabled=false

# Scale pods down before adding environment variables
oc scale statefulset opensearch-cluster-master --replicas=3
```

10. Deploy PostgreSQL using the postgres-12.yaml file:

```bash
oc apply -f postgres-12.yaml
```

11. Deploy Kafka:
  - Install the Streams for Apache Kafka operator using the [documentation](https://docs.redhat.com/en/documentation/red_hat_streams_for_apache_kafka/2.8/html/getting_started_with_streams_for_apache_kafka_on_openshift/proc-deploying-cluster-operator-hub-str#proc-deploying-cluster-operator-hub-str)
  - Deploy a Kafka cluster and name it 'pega-kafka-cluster'
  **NOTE:** The name of the Kafka cluster is important as it will be referenced later in PEGA deployment process (pega.yaml)

12. Add the PEGA Helm repo:

```bash
helm repo add pega https://pegasystems.github.io/pega-helm-charts
```

13. Modify the values in the backingservices.yaml file within this repo as follows [reference](https://github.com/pegasystems/pega-helm-charts/blob/master/docs/Deploying-Pega-on-openshift.md#updating-the-backingservicesyaml-helm-chart-values-for-the-srs-supported-when-installing-or-upgrading-to-pega-infinity-86-and-later):

```yaml
k8sProvider: <SET TO 'openshift'>
deploymentName: <SET TO THE DESIRED NAME FOR THE OPENSHIFT DEPLOYMENT>
srs.srsRuntime.srsImage: <REPLACE WITH THE LOCATION OF YOUR `pega-docker.downloads.pega.com/platform-services/search-n-reporting-service-os` IMAGE PREVIOUSLY LOADED TO THE INTERNAL REGISTRY>
srs.srsStorage.provisionInternalESCluster: <SET TO 'false' TO USE THE PREVIOUSLY DEPLOYED OPENSEARCH CLUSTER>
srs.srsStorage.domain: <SET TO THE OPENSEARCH SERVICE ADDRESS>
srs.srsStorage.port: <SET THIS TO THE OPENSEARCH SERVICE PORT>
srs.srsStorage.protocol: <SET TO 'http' SINCE SSL SHOULD BE DISABLED>
srs.srsStorage.tls.enabled: <SET TO 'false'>
srs.srsStorage.authCredentials.username: <SET TO 'admin'>
srs.srsStorage.authCredentials.password: <SET TO 'Openshift123!'>
```

14. Run the Helm chart for the backingservices using the following command:

```bash
helm install backingservices pega/backingservices --namespace pega --values backingservices.yaml
```
**NOTE:** The default NetworkPolicy in the backingservices Helm template uses a podSelector that must be patched to work with Opensearch:

```bash
oc patch networkpolicy/pega-search-networkpolicy --type=json -p '[{"op": "add", "path": "/spec/egress/0/to/0/podSelector/matchLabels", "value": {app.kubernetes.io/name: "opensearch"}}]'
```

15. Modify the values in the pega.yaml file within this repo as follows [reference](https://github.com/pegasystems/pega-helm-charts/blob/master/docs/Deploying-Pega-on-openshift.md#updating-the-pegayaml-helm-chart-values):

```yaml
provider: <SET TO 'openshift'>
jdbc.url: <SET TO 'jdbc:postgresql://postgresql-12.pega.svc.cluster.local:5432/postgres'>
jdbc.driverClass: <SET TO 'org.postgresql.Driver'>
jdbc.dbType: <SET TO 'postgres'>
jdbc.driverUri: <SET TO 'https://jdbc.postgresql.org/download/postgresql-42.7.5.jar'>
jdbc.username: <SET TO 'postgres'>
jdbc.password: <SET TO 'postgres'>
jdbc.rulesSchema: <SET TO 'rules'> 
jdbc.dataSchema: <SET TO 'data'>
docker.pega.image: <REPLACE WITH THE LOCATION OF YOUR `pega-docker.downloads.pega.com/platform/pega` IMAGE PREVIOUSLY LOADED TO THE INTERNAL REGISTRY>
tier.ingress.domain: <SET TO THE OPENSHIFT ROUTE FOR PEGA WEB USING THE FOLLOWING FORMAT: '<app_name>-<namespace>.apps.<FQDN>'. e.g. 'pega-pega.apps.aromero.z72i.p1.openshiftusgov.com'>
cassandra.enabled: <SET TO 'false'>
cassandra.persistence.enabled: <SET TO 'false'>
pegasearch.externalSearchService: <SET TO 'true'>
pegasearch.externalURL: <SET TO 'http://opensearch-cluster-master.pega.svc.cluster.local:9200' WHICH IS THE SERVICE POINTING TO OPENSEARCH>
installer.image: <REPLACE WITH THE LOCATION OF YOUR `pega-docker.downloads.pega.com/platform/installer` IMAGE PREVIOUSLY LOADED TO THE INTERNAL REGISTRY>
installer.upgrade.pegaRESTUsername: <SET TO 'pega'>
installer.upgrade.pegaRESTPassword: <SET TO 'pega'>
hazelcast.enabled: <SET TO 'false'>
stream.bootstrapServer: <SET TO 'pega-kafka-cluster-kafka-bootstrap.pega.svc.cluster.local:9092' WHICH IS THE SERVICE FOR THE KAFKA BROKERS>
```

16. Run the Helm Chart for the database schema creation and PEGA Web deployment using the following command:

```bash
helm install pega pega/pega --namespace pega --values pega.yaml
```
**NOTE:** The database install process takes about 20 minutes to complete, followed by the PEGA Web deployment

## Testing the User Interface:
Once the PEGA Web pod comes online, you can access the PEGA Web container using the route specified in the pega.yaml Helm configuration file (tier.ingress.domain):

1. Access the UI

2. On initial login, must use the following credentials:
  - username: administrator@pega.com
  - password: ADMIN_PASSWORD

**NOTE:** You will be asked to replace your password upon first login.

