# Neural Transport Channels - Main Configuration
# Implements 9P-inspired protocol for cognitive city communication

locals {
  neural_transport_name = "neural-transport-${substr(var.unique_seed, 0, 8)}"
  
  # Transport channel configurations
  default_channels = {
    critical = {
      priority    = 1
      bandwidth   = var.bandwidth_limit_mbps * 0.4  # 40% for critical services
      queue_depth = 1000
      encryption  = "AES256"
    }
    standard = {
      priority    = 2  
      bandwidth   = var.bandwidth_limit_mbps * 0.4  # 40% for standard traffic
      queue_depth = 500
      encryption  = "AES256"
    }
    background = {
      priority    = 3
      bandwidth   = var.bandwidth_limit_mbps * 0.2  # 20% for background sync
      queue_depth = 100
      encryption  = "AES128"
    }
  }
  
  # Cognitive domain namespaces (Plan 9 inspired)
  cognitive_namespaces = [
    "/cognitive-cities/domains/transportation",
    "/cognitive-cities/domains/energy", 
    "/cognitive-cities/domains/governance",
    "/cognitive-cities/domains/environment",
    "/cognitive-cities/domains/housing",
    "/cognitive-cities/domains/economy",
    "/cognitive-cities/neural-transport/channels",
    "/cognitive-cities/cognitive-swarms/coordination",
    "/cognitive-cities/meta-cognition/self-reflection"
  ]
}

# Service Bus Namespace for Neural Transport
resource "azurerm_servicebus_namespace" "neural_transport" {
  name                = local.neural_transport_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  
  # Enable partitioning for better performance
  zone_redundant = true
  
  tags = merge(var.tags, {
    module = "neural-transport"
    purpose = "cognitive-city-communication"
  })
}

# Service Bus Topics for different cognitive domains  
resource "azurerm_servicebus_topic" "cognitive_domains" {
  for_each = toset(var.urban_domains)
  
  name         = "cognitive-${replace(each.value, "_", "-")}"
  namespace_id = azurerm_servicebus_namespace.neural_transport.id
  
  # Enable partitioning and duplicate detection
  enable_partitioning     = true
  duplicate_detection_history_time_window = "PT10M"
  
  # Auto-delete after 14 days of inactivity
  auto_delete_on_idle = "P14D"
}

# Service Bus Subscriptions for each tenant
resource "azurerm_servicebus_subscription" "tenant_subscriptions" {
  for_each = {
    for pair in setproduct(var.urban_domains, keys(var.cognitive_cities)) :
    "${pair[0]}-${pair[1]}" => {
      domain = pair[0]
      tenant = pair[1]
    }
  }
  
  name     = "subscription-${each.value.tenant}"
  topic_id = azurerm_servicebus_topic.cognitive_domains[each.value.domain].id
  
  max_delivery_count = 10
  auto_delete_on_idle = "P14D"
  
  # Message filtering based on tenant properties
  default_message_ttl = "PT30M"
}

# API Management for protocol translation and routing
resource "azurerm_api_management" "neural_gateway" {
  name                = "${local.neural_transport_name}-apim"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = "Cognitive Cities Neural Transport"
  publisher_email     = "neural-transport@cognitive-cities.ai"
  
  sku_name = "Developer_1"  # Use Standard_1 for production
  
  # Virtual network integration
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.subnet_id
  }
  
  tags = merge(var.tags, {
    module = "neural-transport"
    component = "api-gateway"
  })
}

# API Management API for 9P Protocol Translation
resource "azurerm_api_management_api" "ninep_protocol" {
  name                = "ninep-cognitive-transport"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.neural_gateway.name
  revision            = "1"
  display_name        = "9P Cognitive Transport Protocol"
  path                = "cognitive-transport"
  protocols           = ["https"]
  
  description = "9P-inspired protocol for cognitive city communication"
  
  service_url = azurerm_servicebus_namespace.neural_transport.endpoint
}

# Key Vault for transport encryption keys
resource "azurerm_key_vault" "neural_transport_keys" {
  name                = "${local.neural_transport_name}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  sku_name = "standard"
  
  # Network access restrictions
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [var.subnet_id]
  }
  
  tags = merge(var.tags, {
    module = "neural-transport"
    component = "key-management"
  })
}

# Generate encryption keys for each transport channel
resource "azurerm_key_vault_key" "transport_encryption" {
  for_each = local.default_channels
  
  name         = "transport-channel-${each.key}"
  key_vault_id = azurerm_key_vault.neural_transport_keys.id
  key_type     = "RSA"
  key_size     = 2048
  
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify", 
    "wrapKey"
  ]
  
  tags = merge(var.tags, {
    channel = each.key
    priority = each.value.priority
  })
  
  depends_on = [azurerm_key_vault_access_policy.neural_transport_policy]
}

# Key Vault access policy for neural transport
resource "azurerm_key_vault_access_policy" "neural_transport_policy" {
  key_vault_id = azurerm_key_vault.neural_transport_keys.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  
  key_permissions = [
    "Create",
    "Delete", 
    "Get",
    "List",
    "Update",
    "Decrypt",
    "Encrypt",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey"
  ]
  
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

# Application Insights for transport telemetry
resource "azurerm_application_insights" "neural_transport_telemetry" {
  name                = "${local.neural_transport_name}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  
  # Retention for neural transport analytics
  retention_in_days = var.audit_retention_days
  
  tags = merge(var.tags, {
    module = "neural-transport"
    component = "telemetry"
  })
}

# Log Analytics Workspace for transport logs
resource "azurerm_log_analytics_workspace" "neural_transport_logs" {
  name                = "${local.neural_transport_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  
  # Retention for audit compliance
  retention_in_days = var.audit_retention_days
  
  tags = merge(var.tags, {
    module = "neural-transport"
    component = "audit-logs"
  })
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Storage Account for neural transport state and caching
resource "azurerm_storage_account" "neural_transport_cache" {
  name                     = replace("${local.neural_transport_name}cache", "-", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Enable versioning and soft delete for audit trail
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = var.audit_retention_days
    }
  }
  
  tags = merge(var.tags, {
    module = "neural-transport"
    component = "knowledge-cache"
  })
}