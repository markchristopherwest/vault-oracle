terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.24.0"
    }
  }
}

provider "vault" {
  # Configuration options
  # address = "http://127.0.0.1:8200"
  # skip_tls_verify = true
}
resource "vault_mount" "db" {
  path = "oracle"
  type = "database"
}

resource "vault_database_secret_backend_connection" "oracle" {
  backend       = vault_mount.db.path
  name          = "oracle"
  allowed_roles = ["dev", "prod"]

  oracle {
    connection_url = "(DESCRIPTION=(ADDRESS=(host=oracle://oracle-db)(protocol=TCP)(port=1521))(CONNECT_DATA=(SERVICE_NAME=ORCLCDB)))"
  }
}

# configure a static role with period-based rotations
resource "vault_database_secret_backend_static_role" "period_role" {
  backend             = vault_mount.db.path
  name                = "my-period-role"
  db_name             = vault_database_secret_backend_connection.oracle.name
  username            = "example"
  rotation_period     = "3600"
  rotation_statements = ["ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"]
}

# configure a static role with schedule-based rotations
resource "vault_database_secret_backend_static_role" "schedule_role" {
  backend             = vault_mount.db.path
  name                = "my-schedule-role"
  db_name             = vault_database_secret_backend_connection.oracle.name
  username            = "example"
  rotation_schedule   = "0 0 * * SAT"
  rotation_window     = "172800"
  rotation_statements = ["ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"]
}

# resource "vault_database_secret_backend_role" "role" {
#   backend             = vault_mount.db.path
#   name                = "dev"
#   db_name             = vault_database_secret_backend_connection.oracle.name
#   creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
# }