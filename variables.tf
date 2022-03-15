variable "user_range" {
  type        = string
  default     = "10.0.192.0/20"
  description = "An IP address within this range on the network will be generated for each connected user."
}
