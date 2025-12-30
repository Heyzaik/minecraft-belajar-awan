output "vpc_id" {
  value = aws_vpc.minecraft_vpc.id
}

output "subnet_id" {
  value = aws_subnet.minecraft_subnet.id
}
