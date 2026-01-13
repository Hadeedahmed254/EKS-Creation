/*
output "cluster_id" {
  value = aws_eks_cluster.cicd.id
}

output "node_group_id" {
  value = aws_eks_node_group.cicd_worker.id
}
*/

output "vpc_id" {
  value = aws_vpc.cicd_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.cicd_subnet[*].id
}
/*
output "sonar_eip" {
  value = aws_eip.sonar_eip.public_ip
}




output "jenkins_eip" {
  value = aws_eip.jenkins_eip.public_ip
}


output "nexus_public_ip" {
  value = aws_instance.nexus.public_ip
}
*/
output "Server_ip" {
  value = aws_instance.Server.public_ip
}