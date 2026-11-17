# OpenBao server configuration (mounted read-only). Single-node Raft storage (OpenBao dropped the file backend),
# static-key auto-unseal, and
# declarative self-initialization: the initialize blocks run once, on the first start with empty storage.
ui            = true
disable_mlock = true
api_addr      = "http://openbao:8200"
cluster_addr  = "http://openbao:8201"

storage "raft" {
  path    = "/openbao/file"
  node_id = "openbao"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

# Key file written from OPENBAO_UNSEAL_KEY by the container entrypoint on every start
seal "static" {
  current_key_id = "local-dev-1"
  current_key    = "file:///tmp/openbao-unseal.key"
}

initialize "policies" {
  request "admin-policy" {
    operation = "update"
    path      = "sys/policies/acl/admin"
    data = {
      policy = <<EOP
path "*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list", "scan", "sudo"]
}
EOP
    }
  }
}

initialize "authentication" {
  request "enable-userpass" {
    operation = "update"
    path      = "sys/auth/userpass"
    data = {
      type        = "userpass"
      description = "Local development logins"
    }
  }
  request "admin-user" {
    operation = "update"
    path      = "auth/userpass/users/admin"
    data = {
      password = {
        eval_type       = "string"
        eval_source     = "env"
        env_var         = "OPENBAO_ADMIN_PASSWORD"
        require_present = true
      }
      token_policies = ["admin"]
    }
  }
}

initialize "secrets" {
  request "enable-kv" {
    operation = "update"
    path      = "sys/mounts/secret"
    data = {
      type    = "kv"
      options = { version = "2" }
    }
  }
}
