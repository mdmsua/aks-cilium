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
  timeout           = 60
}
