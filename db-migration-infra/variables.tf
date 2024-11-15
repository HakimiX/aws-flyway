variable "env" {
  default     = "dev"
  description = "The environment to deploy to"
}

variable "region" {
  description = "The AWS region to deploy resources"
  default     = "eu-west-1"
}

variable "account_id" {
  description = "The AWS account ID"
  default     = "some-account-id"
}

variable "profile" {
  description = "The AWS profile to use"
  default     = "some-profile"
}

variable "stack_name" {
  description = "The name of the stack"
  default     = "some-stack-name"
}

variable "lambda" {
  description = "Lambda function configuration"
  type = object({
    timeout     = number
    memory_size = number
  })
}