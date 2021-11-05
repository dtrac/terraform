resource "null_resource" "example1" {
  provisioner "local-exec" {
    command     = "pwd"
    interpreter = ["/bin/bash", "-c"]
  }
}

output "null_resource" {
  value = null_resource.example1
}