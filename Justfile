
install:
    just prometheus-stack-upgrade;
    just argo-workfklows-helm-upgrade;

reset-colima-kube-environment:
    colima stop;
    colima start --kubernetes;
    colima kube reset;




prometheus-stack-upgrade:
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
            --namespace prometheus \
            --create-namespace \
            --values helm/values/kube-prometheus-stack/values.yaml;


#prometheus-stack-exporter-fix:
#     kubectl -n prometheus patch ds prometheus-prometheus-node-exporter --type "json" -p '[{"op": "remove", "path" : "/spec/template/spec/containers/0/volumeMounts/2/mountPropagation"}]'


workflows-namespace-create:
    kubectl create namespace workflows;

argo-workfklows-helm-upgrade:
	helm upgrade --install argo-workflows argo/argo-workflows \
		--namespace argo \
		--create-namespace \
		--values helm/values/argo-workflows/values.yaml;


#prometheus-stack-install:
#    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false;



prometheus-stack-helm-show-values:
    helm show values prometheus-community/kube-prometheus-stack > prometheus-stack-values.yaml

#workflow-controller-metrics-servicemonitor-apply:
#    kubectl apply -n argo -f k8s/workflow-controller-metrics-servicemonitor.yaml


prometheus-port-forward:
    kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090 \
      --namespace prometheus


prometheus-ui-open:
    open http://localhost:9090

#workflow-hello-world-submit:
#    argo submit https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml --watch -n raas-pipeline

grafana-port-forward:
    kubectl port-forward svc/prometheus-grafana 8000:80 -n prometheus

grafana-secret:
    kubectl -n prometheus get secret prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

grafaba-open-ui:
    open "http://localhost:8000"

workflow-dag-submit-fast:
    argo submit  k8s/dag.yaml -p docker_version="2023.11.6" -p delay="0" -n workflows --serviceaccount argo-workflow --watch
workflow-dag-submit-normal:
    argo submit  k8s/dag.yaml -p docker_version="2023.11.9" -p delay="2" -n workflows --serviceaccount argo-workflow --watch
workflow-dag-submit-slow:
    argo submit  k8s/dag.yaml -p docker_version="2023.11.7" -p delay="5" -n workflows --serviceaccount argo-workflow --watch
workflow-dag-submit-slowest:
    argo submit  k8s/dag.yaml -p docker_version="2023.11.8" -p delay="9" -n workflows --serviceaccount argo-workflow --watch
workflow-dag-submit-fail_boardnet_converter:
    argo submit  k8s/dag.yaml -p docker_version="2023.11.10" -p delay="0" -p fail_boardnet_converter="yes" -n workflows --serviceaccount argo-workflow --watch


workflow-dag-template-apply:
    kubectl apply -f k8s/dag-template.yaml -n raas-pipeline;

workflow-dag-template-submit:
     argo submit -n raas-pipeline --from workflowtemplate/workflow-template-inner-dag --watch;


#workflow-dag-template-submit:
#    argo submit --from ./k8s/dag-template.yaml -n raas-pipeline --watch


argo-workflows-server-port-forward:
    kubectl port-forward service/argo-workflows-server 2746 -n argo;


argo-workflows-ui-open:
    open "http://0.0.0.0:2746/workflows"


#sample-install:
#      kubectl create deployment sample --image  quay.io/brancz/prometheus-example-app:v0.3.0
#      kubectl label deployment sample app=sample
#      kubectl expose deployment sample --port=7000 --target-port=8080 --name=sample --type=ClusterIP


service-port-forward:
    kubectl port-forward service/argo-workflows-workflow-controller 8080:8080 --namespace raas-argo-workflows

#create-service:
#    kubectl expose deployment raas-argo-workflows-system-workflow-controller --name argo-workflows-controller-service --port 8080 --target-port=9090


workflow-dag-template-failed-apply:
    kubectl apply -f k8s/dag-template-failed.yaml -n raas-pipeline;

workflow-dag-template-failed-submit:
     argo submit -n raas-pipeline --from workflowtemplate/workflow-template-inner-dag --watch;

delete-promethues-data:
   curl -X POST http://localhost:9090/api/v1/admin/tsdb/clean_tombstones;
   curl -X 'PUT' 'http://localhost:9090/api/v1/admin/tsdb/clean_tombstones'   -H 'accept: */*';
   curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={job="argo-workflows-workflow-controller"}';
   curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__="argo_workflows_rpu_workflows_result_counter"}';
   curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__="argo_workflows_rpu_workflows_duration_gauge"}';
   curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]=up&match[]=argo_workflows_rpu_workflows_duration_gauge{job="argo-workflows-workflow-controller"}'
   curl -X PUT 'http://localhost:9090/api/v1/admin/tsdb/clean_tombstones'   -H 'accept: */*';
   kubectl delete pod -l app.kubernetes.io/component=workflow-controller -n argo







grafana-dashboars-configmap-create:
      kubectl create configmap grafana-dashboards --from-file=dashboards -n prometheus;
      kubectl label configmap grafana-dashboards grafana_dashboard=true -n prometheus;

grafana-dashboars-configmap-to-file:
      kubectl get configmap grafana-dashboards -o yaml -n prometheus > grafana-dashboards-configmap.yaml


