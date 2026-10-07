persistence:
  enabled: false
admin:
  existingSecret: grafana-admin-credentials
  userKey: admin-user
  passwordKey: admin-password
resources:
  requests: {cpu: 50m, memory: 128Mi}
  limits: {cpu: 200m, memory: 256Mi}
serviceAccount:
  create: true
  name: grafana
  annotations:
    eks.amazonaws.com/role-arn: __GRAFANA_ROLE_ARN__
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
      - name: reference
        orgId: 1
        folder: reference
        type: file
        disableDeletion: false
        editable: true
        updateIntervalSeconds: 30
        options: {path: /var/lib/grafana/dashboards/reference}
dashboardsConfigMaps:
  reference: reference-grafana-dashboards
dashboards:
  default:
    istio-mesh: {gnetId: 7639, revision: 330, datasource: Prometheus}
    istio-service: {gnetId: 7636, revision: 329, datasource: Prometheus}
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        uid: prometheus
        type: prometheus
        url: http://prometheus-server.istio-system.svc:80
        access: proxy
        isDefault: true
        editable: false
      - name: CloudWatch
        uid: reference-cloudwatch
        type: cloudwatch
        access: proxy
        editable: false
        jsonData: {authType: default, defaultRegion: us-east-1}
