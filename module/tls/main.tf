resource "tls_private_key" "key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "key-pair" {
  key_name   = "key-pair"
  public_key = tls_private_key.key.public_key_openssh
}

# private key
resource "aws_secretsmanager_secret" "key-private" {
  name = "key-private"
  description = "private ssh key"
}

resource "aws_secretsmanager_secret_version" "key-private" {
  secret_id     = aws_secretsmanager_secret.key-private.id
  secret_string = tls_private_key.key.private_key_pem
}

resource "aws_secretsmanager_secret" "key-private-openssh" {
  name = "key-private-openssh"
  description = "private openssh ssh key"
}

resource "aws_secretsmanager_secret_version" "key-private-openssh" {
  secret_id     = aws_secretsmanager_secret.key-private-openssh.id
  secret_string = tls_private_key.key.private_key_openssh
}

# public key
resource "aws_secretsmanager_secret" "key-public" {
  name = "key-public"
  description = "public ssh key"
}

resource "aws_secretsmanager_secret_version" "key-public" {
  secret_id     = aws_secretsmanager_secret.key-public.id
  secret_string = tls_private_key.key.public_key_pem
}

# public key fingerprint md5
resource "aws_secretsmanager_secret" "key-public-fingerprint-md5" {
  name = "key-public-fingerprint-md5"
  description = "public ssh key fingerprint md5"
}

resource "aws_secretsmanager_secret_version" "key-public-fingerprint-md5" {
  secret_id     = aws_secretsmanager_secret.key-public-fingerprint-md5.id
  secret_string = tls_private_key.key.public_key_fingerprint_md5
}

# public key fingerprint sha256
resource "aws_secretsmanager_secret" "key-public-fingerprint-sha256" {
  name = "key-public-fingerprint-sha256"
  description = "public ssh key fingerprint sh256"
}

resource "aws_secretsmanager_secret_version" "key-public-fingerprint-sha256" {
  secret_id     = aws_secretsmanager_secret.key-public-fingerprint-sha256.id
  secret_string = tls_private_key.key.public_key_fingerprint_sha256
}
