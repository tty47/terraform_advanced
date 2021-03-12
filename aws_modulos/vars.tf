
variable "id_clave" {
  description = "Identificador de la clave"
  type        = string
}

variable "region_aws" {
  description = "Region de AWS donde crear la clave"
  type        = string
}
variable "profile_aws" {
  description = "Perfil de la cuenta con la que crear la clave"
  type        = string
  default     = "default"

}