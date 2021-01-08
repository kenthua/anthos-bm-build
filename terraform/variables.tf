variable "services" {
  type = list(string)
}

variable "project_id" {
  type = string
}

variable "connect_agent_sa" {
    type = string
}

variable "connect_register_sa" {
    type = string
}

variable "logging_monitoring_sa" {
    type = string
}