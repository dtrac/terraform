# ===================
# Basics

variable "prefix" {
  type    = string
  default = "uk-"
}

variable "suffix" {
  type    = string
  default = "-resource"
}

locals {
  my_local = "${var.prefix}test${var.suffix}"
}

output "test" {
  value = local.my_local
}

# ===============
# Slightly less basic

# map(...): a collection of values where each is identified by a string label.
variable "my_map" {
  type        = map(string)
  description = "(optional) describe your variable"
  default = {
    key1 = "val1"
    key2 = "val2"
  }
}

# set(...): a collection of unique values that do not have any secondary identifiers or ordering.
variable "my_set" {
  type        = set(number)
  description = "(optional) describe your variable"
  default     = [1, 2, 3]
}

# list(...): a sequence of values identified by consecutive whole numbers starting with zero.
variable "my_list" {
  type        = list(any)
  description = "(optional) describe your variable"
  default     = [1, "two", true]
}

output "my_map" {
  value = var.my_map["key1"]
}

output "my_set" {
  value = tolist(var.my_set)[0]
}

output "my_list" {
  value = var.my_list[0]
}