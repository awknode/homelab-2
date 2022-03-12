## deploy/terraform/proxmox-debian-11-template section
# variable "pm_ssh_user" {
#     type = string
#     default = "loeken" 
# }
# variable "pm_ssh_host" {
#     type = string
#     default = "172.16.137.14" 
# }
# variable "pm_ssh_password" {
#     type = string
#     default = "demotime" 
# }
# variable "ssh_public_key" {
#     type = string
#     default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCXXVF7eU5PcGc6Jwb1hPwzBc+3gUpHWIwrUFaSM2tiJAHR3Ei/4ZwFPgegXzUtsisJEkUis+F7USPKn5PV35rAcj32rMItBSDj7jMlYJlTF99hXSO8bcw6ztpYbkkBH00rS2DOpQov1tVgCh+7YTkGTGQS9fRj7qA74AYOiyhGZa33ivDO2t59LSYyOO8sHC7yfdESlDFim9vT2bU1OSCnicLPoKLAI6OgNGg/1GTr1iEVCZ2nc5x7HoQ34jkoVZJFFWfd0B0YA95wzX8dnMej2eKsl5d4CoU/d/Q7zhwa04wxdTV5+dqLd2snlTk7/G8lNrv3iwCgqZPqK7afTGbvwv/GH86xeGchDDQr3W94tYbpLbu0KU7Bm1YKin4/1wKaxzeY9OrnFLBgQodxi0j9YMmGn8kkc3ygAoIFFc0FpcpYkWEAmbRkN3qxtn5qoCGtZ0pJX3wERiNS9IbW+k67JpQkDcmXdqfzA1FfTGbtAJUnTZTA1d0Zl31wjPXhuY8vOH1bobZVoUJIkdVpDS4QYqMYnv6rXlaTJGe9fJ0Bar9NLIYTeb7PRk1oTPcSoCJwV75Tvu38Hd3FkAMoGmDl6NiKDXlnQe7633sGBz2h2g5cPbLmkjwl7ZCD2hIimHGHy3mLEotdiFcfGkW7RWs+qJoaJ6YuCXYPu8IPns+gHw== loeken@0x00f"
# }
# variable "pm_bridge" {
#     type = string
#     default = "vmbr0"
# }
## deploy/terraform/k3s section
variable "ssh_public_key" {
    type = string
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCXXVF7eU5PcGc6Jwb1hPwzBc+3gUpHWIwrUFaSM2tiJAHR3Ei/4ZwFPgegXzUtsisJEkUis+F7USPKn5PV35rAcj32rMItBSDj7jMlYJlTF99hXSO8bcw6ztpYbkkBH00rS2DOpQov1tVgCh+7YTkGTGQS9fRj7qA74AYOiyhGZa33ivDO2t59LSYyOO8sHC7yfdESlDFim9vT2bU1OSCnicLPoKLAI6OgNGg/1GTr1iEVCZ2nc5x7HoQ34jkoVZJFFWfd0B0YA95wzX8dnMej2eKsl5d4CoU/d/Q7zhwa04wxdTV5+dqLd2snlTk7/G8lNrv3iwCgqZPqK7afTGbvwv/GH86xeGchDDQr3W94tYbpLbu0KU7Bm1YKin4/1wKaxzeY9OrnFLBgQodxi0j9YMmGn8kkc3ygAoIFFc0FpcpYkWEAmbRkN3qxtn5qoCGtZ0pJX3wERiNS9IbW+k67JpQkDcmXdqfzA1FfTGbtAJUnTZTA1d0Zl31wjPXhuY8vOH1bobZVoUJIkdVpDS4QYqMYnv6rXlaTJGe9fJ0Bar9NLIYTeb7PRk1oTPcSoCJwV75Tvu38Hd3FkAMoGmDl6NiKDXlnQe7633sGBz2h2g5cPbLmkjwl7ZCD2hIimHGHy3mLEotdiFcfGkW7RWs+qJoaJ6YuCXYPu8IPns+gHw== loeken@0x00f"
}
variable "pm_api_url" {
    type = string
    default = "https://172.16.137.14:8006/api2/json"
}
variable "pm_password" {
    type = string
    default = "demotime"
}
variable "pm_user" {
    type = string
    default = "root@pam"
}
variable "vm_node" {
    type = string
    default = "homeserver" 
}
variable "vm_mem" {
    type = string
    default = "10238" 
}
variable "kubernetes_version" {
    type = string
    default = "v1.21.7+k3s1"
}
variable "k3s_nodename_01" {
    type = string
    default = "k3s-master-01"
}
variable "k3s_nodename_02" {
    type = string
    default = "k3s-master-02"
}
variable "k3s_nodename_03" {
    type = string
    default = "k3s-master-03"
}
variable "k3s_internal_ip_node_01" {
    type = string
    default = "172.16.137.101"
}
variable "k3s_internal_ip_node_02" {
    type = string
    default = "172.16.137.102"
}
variable "k3s_internal_ip_node_03" {
    type = string
    default = "172.16.137.103"
}
variable "k3s_external_ip_node_01" {
    type = string
    default = "94.134.59.227"
}
variable "k3s_external_ip_node_02" {
    type = string
    default = "94.134.59.227"
}
variable "k3s_external_ip_node_03" {
    type = string
    default = "94.134.59.227"
}
variable "cores_k3s_01" {
    type = string
    default = "2"
}
variable "memory_k3s_01" {
    type = string
    default = "4096"
}
variable "cores_k3s_02" {
    type = string
    default = "2"
}
variable "memory_k3s_02" {
    type = string
    default = "4096"
}
variable "cores_k3s_03" {
    type = string
    default = "2"
}
variable "memory_k3s_03" {
    type = string
    default = "4096"
}
variable "proxmox_node_name" {
    type = string
    default = "homeserver"
}
variable "k3s_bridge_01" {
    type = string
    default = "vmbr0"
}
variable "k3s_macaddr_01" {
    type = string
    default = "8E:AB:AB:4C:CE:A0"
}
variable "k3s_bridge_02" {
    type = string
    default = "vmbr0"
}
variable "k3s_macaddr_02" {
    type = string
    default = "8E:AB:AB:4C:CE:A1"
}
variable "k3s_bridge_03" {
    type = string
    default = "vmbr0"
}
variable "k3s_macaddr_03" {
    type = string
    default = "8E:AB:AB:4C:CE:A2"
}
variable "k3s_disksize_01" {
    type = string
    default = "100G"
}
variable "k3s_disksize_02" {
    type = string
    default = "100G"
}
variable "k3s_disksize_03" {
    type = string
    default = "100G"
}