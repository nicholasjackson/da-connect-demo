/*
output "server_ssh_private_key" {
  value = "${tls_private_key.server.private_key_pem}"
}
*/

output "postgres_fqdn" {
  value = "${azurerm_postgresql_server.emojify_db.fqdn}"
}

output "postgres_user" {
  value = "${azurerm_postgresql_server.emojify_db.administrator_login}"
}

output "postgres_password" {
  value = "${azurerm_postgresql_server.emojify_db.administrator_login_password}"
}

output "postgres_database" {
  value = "${azurerm_postgresql_database.emojify_db.name}"
}

output "redis_fqdn" {
  value = "${azurerm_redis_cache.emojify_cache.hostname}"
}

output "redis_port" {
  value = "${azurerm_redis_cache.emojify_cache.port}"
}

output "redis_key" {
  value = "${azurerm_redis_cache.emojify_cache.primary_access_key}"
}
