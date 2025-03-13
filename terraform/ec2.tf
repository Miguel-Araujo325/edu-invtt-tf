resource "aws_instance" "ec2-public-edu-invtt" {
  ami                    = "ami-08e5424edfe926b43"  # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  associate_public_ip_address = true
  security_groups        = [aws_security_group.sg-public-edu-invtt]

  tags = {
    Name = "ec2-public-edu-invtt"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./key-ec2-public-edu-invtt")
    host        = self.public_ip

    bastion_host = aws_instance.ec2-public-edu-invtt.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("./key-ec2-public-edu-invtt")
  }

  provisioner "file" {
    source      = "./public.sh"
    destination = "/home/ubuntu/public.sh"
  }

  provisioner "file" {
    source      = "./key-ec2-private-edu-invtt.pem"
    destination = "/home/ubuntu/.ssh/key-ec2-private-edu-invtt.pem"
  }

  # Passa o IP privado do backend para o Nginx via user_data
  user_data = <<-EOF
              #!/bin/bash
              apt update && apt install -y aws-cli
              EOF
}

resource "aws_instance" "ec2-private-edu-invtt" {
  ami                    = "ami-08e5424edfe926b43"  # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  associate_public_ip_address = false
  security_groups        = [aws_security_group.sg-private-edu-invtt]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./key-ec2-private-edu-invtt")
    host        = self.private_ip

    bastion_host        = aws_instance.ec2-public-edu-invtt.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("./key-ec2-public-edu-invtt")
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/private.sh",
      "/home/ubuntu/private.sh"
    ]
  }

  tags = {
    Name = "ec2-private-edu-invtt"
  }
}

# ======================== Armazenando o IP do MySql no AWS SSM ========================

resource "aws_ssm_parameter" "private_ip" {
  name  = "/config/backend_private_ip"
  type  = "String"
  value = aws_instance.ec2-private-edu-invtt.private_ip
}

# ======================== Executando o Script de Configuração ========================
resource "null_resource" "configurar_frontend" {
  depends_on = [aws_instance.ec2-public-edu-invtt, aws_instance.ec2-private-edu-invtt]

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/deploy_front.sh",
      "/home/ubuntu/deploy_front.sh"
    ]
  }
}

# ======================== Outputs (para visualizar os IPs) ========================
output "nginx_public_ip" {
  description = "IP Público do Servidor Nginx"
  value       = aws_instance.ec2-public-edu-invtt.public_ip
}

output "backend_private_ip" {
  description = "IP Privado do Servidor MySQL"
  value       = aws_instance.ec2-private-edu-invtt.private_ip
}

