variable "create" {
  description = "whether to create the Cloudwatch log stream"
  type        = bool
  default     = true
}

variable "name" {
  description = "a name for the log stream"
  type        = string
  default     = "babel"
}

variable "log_group_name" {
  description = "a name of the log group"
  type        = string
  default     = "babel"
}
