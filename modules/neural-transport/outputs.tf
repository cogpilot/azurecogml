# Neural Transport Module Outputs

output "transport_endpoint" {
  value       = azurerm_api_management.neural_gateway.gateway_url
  description = "Primary neural transport endpoint for cognitive cities"
}

output "service_bus_namespace" {
  value       = azurerm_servicebus_namespace.neural_transport.name
  description = "Service Bus namespace for neural transport"
}

output "transport_topics" {
  value = {
    for domain, topic in azurerm_servicebus_topic.cognitive_domains :
    domain => {
      id   = topic.id
      name = topic.name
    }
  }
  description = "Service Bus topics for each cognitive domain"
}

output "transport_subscriptions" {
  value = {
    for key, sub in azurerm_servicebus_subscription.tenant_subscriptions :
    key => {
      id   = sub.id
      name = sub.name
    }
  }
  description = "Service Bus subscriptions for tenant communication"
}

output "encryption_keys" {
  value = {
    for channel, key in azurerm_key_vault_key.transport_encryption :
    channel => {
      id      = key.id
      version = key.version
    }
  }
  description = "Encryption keys for neural transport channels"
  sensitive   = true
}

output "api_management_id" {
  value       = azurerm_api_management.neural_gateway.id
  description = "API Management instance ID for protocol translation"
}

output "telemetry_instrumentation_key" {
  value       = azurerm_application_insights.neural_transport_telemetry.instrumentation_key
  description = "Application Insights instrumentation key for transport telemetry"
  sensitive   = true
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.neural_transport_logs.id
  description = "Log Analytics workspace ID for audit logs"
}

output "transport_cache_account" {
  value = {
    name          = azurerm_storage_account.neural_transport_cache.name
    primary_key   = azurerm_storage_account.neural_transport_cache.primary_access_key
    connection_string = azurerm_storage_account.neural_transport_cache.primary_connection_string
  }
  description = "Storage account details for neural transport caching"
  sensitive   = true
}

output "cognitive_namespaces" {
  value       = local.cognitive_namespaces
  description = "Plan 9 inspired cognitive namespace hierarchy"
}

output "transport_channels_config" {
  value       = local.default_channels
  description = "Neural transport channel configurations"
}

output "resource_ids" {
  value = {
    service_bus_namespace = azurerm_servicebus_namespace.neural_transport.id
    api_management        = azurerm_api_management.neural_gateway.id
    key_vault            = azurerm_key_vault.neural_transport_keys.id
    application_insights = azurerm_application_insights.neural_transport_telemetry.id
    log_analytics        = azurerm_log_analytics_workspace.neural_transport_logs.id
    storage_account      = azurerm_storage_account.neural_transport_cache.id
  }
  description = "Resource IDs for all neural transport components"
}