resource "helm_release" "argocd" {
  repository        = "https://argoproj.github.io/argo-helm"
  chart             = "argo-cd"
  name              = "argocd"
  namespace         = "argocd"
  create_namespace  = true
  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true
  reuse_values      = true
  wait              = true
  wait_for_jobs     = true

  set {
    name  = "redis-ha.enabled"
    value = true
  }

  set {
    name  = "controller.replicas"
    value = 1
  }

  set {
    name  = "server.autoscaling.enabled"
    value = true
  }

  set {
    name  = "server.autoscaling.minReplicas"
    value = 2
  }

  set {
    name  = "repoServer.autoscaling.enabled"
    value = true
  }

  set {
    name  = "repoServer.autoscaling.minReplicas"
    value = 2
  }

  set {
    name  = "applicationSet.replicas"
    value = 2
  }
}
