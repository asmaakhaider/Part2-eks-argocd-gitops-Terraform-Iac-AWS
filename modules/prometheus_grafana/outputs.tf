output "prometheus_release_name" {
  description = "Nom du release Helm pour Prometheus + Grafana"
  value       = helm_release.prometheus.name
}
