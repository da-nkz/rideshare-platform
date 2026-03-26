output "cluster_name" {
  description = "EKS cluster name"
  value = aws_eks_cluster.this.name
}
 
output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value = aws_eks_cluster.this.endpoint
}
 
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data"
  value = aws_eks_cluster.this.certificate_authority[0].data
}
 
output "cluster_security_group_id" {
  description = "Cluster security group ID"
  value = aws_security_group.cluster.id
}
 
output "node_security_group_id" {
  description = "Node security group ID"
  value = aws_security_group.node.id
}
 
output "node_group_arn" {
  description = "ARN of the managed node group"
  value = aws_eks_node_group.this.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL"
  value       = aws_iam_openid_connect_provider.this.url
}