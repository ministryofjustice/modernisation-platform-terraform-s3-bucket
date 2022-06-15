variable "networking" {

  type = list(any)

}
variable "prevent_destroy" {
  type        = bool
  description = "Set if the bucket can be destroyed"
  default     = false
}
variable "rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}