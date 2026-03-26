variable "prefix" {
  description = "Resource naming prefix (e.g., teleios-daniel-dev)"
  type = string
}
 
variable "buckets" {
  description = "Map of bucket configs - key becomes the bucket suffix"
  type = map(object({
    versioning_enabled = bool
    expiration_days = number
  }))
  default = {
    assets = { versioning_enabled = true,  expiration_days = 365 }
    logs = { versioning_enabled = false, expiration_days = 30  }
    backups = { versioning_enabled = true,  expiration_days = 90  }
  }
}
 
variable "tags" {
  description = "Additional tags to apply to all resources"
  type = map(string)
  default = {}
}

