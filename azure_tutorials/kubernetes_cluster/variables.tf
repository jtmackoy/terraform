variable "access_key" {
  # Best practice: publish this to an environment variable using TM_VAR_ssh_pub_key_data
  # Hint (in PS): Set-Item -path env:TF_VAR_access_key -value "<insert key here>"
  #default = ""
}
variable "client_id" {
  # Best practice: publish this to an environment variable using TM_VAR_ssh_pub_key_data
  # Hint (in PS): Set-Item -path env:TF_VAR_client_id -value "<insert key here>"
  #default = ""
}
variable "client_secret" {
  # Best practice: publish this to an environment variable using TM_VAR_ssh_pub_key_data
  # Hint (in PS): Set-Item -path env:TF_VAR_client_secret -value "<insert key here>"
  #default = ""
}