terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefixo do nome do bucket (minúsculo, sem espaços). Um sufixo aleatório será adicionado."
  type        = string
  default     = "pipeline-test"
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.name_prefix}-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = {
    Project   = "pipeline-validation"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Nome do bucket criado para validar o pipeline"
}

