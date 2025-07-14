# Resource Helm Release
resource "helm_release" "external_dns" {
  count      = var.create_external_dns_controller ? 1 : 0
  depends_on = [aws_iam_role.ext_dns_iam_role]

  name      = "external-dns"
  namespace = "default"

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  set = [
    {
      name  = "image.repository"
      value = "registry.k8s.io/external-dns/external-dns"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "external-dns"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = "${aws_iam_role.ext_dns_iam_role[count.index].arn}"
    },
    {
      name  = "provider.name" # Defaults to aws anyway
      value = "aws"
    },
    {
      name  = "policy"
      value = "sync" # Default is 'upsert-only' which won't delete DNS records if the ingress resourse is deleted from the eks-cluster
    }
  ]

}
