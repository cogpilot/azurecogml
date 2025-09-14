# Neural Transport Module Variables

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where resources will be created"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for neural transport network integration"
}

variable "unique_seed" {
  type        = string
  description = "Unique seed for resource naming"
}

variable "transport_channels" {
  type        = number
  default     = 3
  description = "Number of parallel neural transport channels"
  
  validation {
    condition     = var.transport_channels >= 1 && var.transport_channels <= 10
    error_message = "Transport channels must be between 1 and 10."
  }
}

variable "bandwidth_limit_mbps" {
  type        = number
  default     = 100
  description = "Maximum bandwidth per transport channel in Mbps"
  
  validation {
    condition     = var.bandwidth_limit_mbps >= 10 && var.bandwidth_limit_mbps <= 10000
    error_message = "Bandwidth limit must be between 10 and 10000 Mbps."
  }
}

variable "enable_privacy_filter" {
  type        = bool
  default     = true
  description = "Enable privacy filtering for inter-city communication"
}

variable "audit_retention_days" {
  type        = number
  default     = 365
  description = "Number of days to retain audit logs"
  
  validation {
    condition     = var.audit_retention_days >= 30 && var.audit_retention_days <= 2555
    error_message = "Audit retention must be between 30 and 2555 days."
  }
}

variable "qos_priority_levels" {
  type        = number
  default     = 5
  description = "Number of Quality of Service priority levels"
  
  validation {
    condition     = var.qos_priority_levels >= 3 && var.qos_priority_levels <= 10
    error_message = "QoS priority levels must be between 3 and 10."
  }
}

variable "cognitive_cities" {
  type = map(object({
    tenant_id = string
    endpoint  = string
    priority  = string
  }))
  default = {}
  description = "Map of cognitive cities with their configuration"
}

variable "urban_domains" {
  type        = list(string)
  default     = ["transportation", "energy", "governance", "environment", "housing", "economy"]
  description = "List of urban domains for cognitive communication"
  
  validation {
    condition     = length(var.urban_domains) > 0
    error_message = "At least one urban domain must be specified."
  }
}

variable "enable_9p_protocol" {
  type        = bool
  default     = true
  description = "Enable Plan 9 inspired protocol features"
}

variable "neural_learning_enabled" {
  type        = bool
  default     = true
  description = "Enable neural learning and adaptation capabilities"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to all resources"
}