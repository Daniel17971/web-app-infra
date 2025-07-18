output "vpc_id" {
  value = aws_vpc.web-app.id
}

output "public_subnet_ids" {
   value = [for subnet in values(aws_subnet.public) : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in values(aws_subnet.private) : subnet.id]
}
