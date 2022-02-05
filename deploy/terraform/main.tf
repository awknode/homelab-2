terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    argocd = {
      source = "oboukili/argocd"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}
provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_password = var.pm_password
  pm_user = var.pm_user
  pm_tls_insecure = "true"
} 

resource "null_resource" "create_template" {
  connection {
    type     = "ssh"
    user     = var.pm_ssh_user
    host     = var.pm_ssh_host
    password = var.pm_ssh_password
  }

  provisioner "remote-exec" {
    inline = [
      "sudo qm destroy 999",
      "sudo qm destroy 998",
      "sudo rm -rf debian-11-nocloud-amd64.qcow2",
      "sudo wget https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-nocloud-amd64.qcow2",
      "sudo qm create 998 -name template-vm -memory 1024 -net0 virtio,bridge=${var.pm_bridge} -cores 1 -sockets 1",

      # Import the OpenStack disk image to Proxmox storage
      "sudo qm importdisk 998 debian-11-nocloud-amd64.qcow2 local",

      # Attach the disk to the virtual machine
      "sudo qm set 998 -scsihw virtio-scsi-pci -virtio0  /var/lib/vz/images/998/vm-998-disk-0.raw",

      # Add a serial output
      "sudo qm set 998 -serial0 socket",

      # configure cloud init networking
      "sudo qm set 998 --ipconfig0 ip=dhcp",

      # Set the bootdisk to the imported Openstack disk
      "sudo qm set 998 -boot c -bootdisk virtio0",

      # Enable the Qemu agent
      "sudo qm set 998 -agent 1",

      # Allow hotplugging of network, USB and disks
      "sudo qm set 998 -hotplug disk,network,usb",

      # Add a single vCPU (for now)
      "sudo qm set 998 -vcpus 1",

      # Add a video output
      "sudo qm set 998 -vga qxl",

      # Set a second hard drive, using the inbuilt cloudinit drive
      "sudo qm set 998 -ide2 local:cloudinit",

      # ssh key for cloud init
      "echo ${var.ssh_public_key} > mykey.pub",
      "sudo qm set 998 --sshkey mykey.pub",

      # Resize the primary boot disk (otherwise it will be around 2G by default)
      # This step adds another 8G of disk space, but change this as you need to
      "sudo qm resize 998 virtio0 +8G",

      ###
      "sudo virt-customize -a /var/lib/vz/images/998/vm-998-disk-0.raw --install qemu-guest-agent,cloud-init,cloud-initramfs-growroot,open-iscsi,lsscsi,sg3-utils,multipath-tools,scsitools,nfs-common",
      "sudo virt-customize -a /var/lib/vz/images/998/vm-998-disk-0.raw --append-line '/etc/multipath.conf:defaults {'",
      "sudo virt-customize -a /var/lib/vz/images/998/vm-998-disk-0.raw --append-line '/etc/multipath.conf:    user_friendly_names yes'",
      "sudo virt-customize -a /var/lib/vz/images/998/vm-998-disk-0.raw --append-line '/etc/multipath.conf:    find_multipaths yes'",
      "sudo virt-customize -a /var/lib/vz/images/998/vm-998-disk-0.raw --append-line '/etc/multipath.conf:}'",
      "sudo virt-customize -a /var/lib/vz/images/998/vm-998-disk-0.raw --run-command 'systemctl enable open-iscsi.service'",
      "sudo virt-customize -a /var/lib/vz/images/998/vm-998-disk-0.raw --run-command 'echo fs.inotify.max_user_instances = 8192 >> /etc/sysctl.conf'",
      "sudo virt-customize -a /var/lib/vz/images/998/vm-998-disk-0.raw --run-command 'echo fs.inotify.max_user_watches = 524288 >> /etc/sysctl.conf'",

      # Convert the VM to the template
      "sudo qm clone 998 999 --name template --full true",

      # convert the clone to a template
      "sudo qm template 999",
    ]
  }
  count = var.pm_build_template == "yes" ? 1 : 0
}
/*
resource "null_resource" "linkerd-trust-anchor-certificate" {
  provisioner "local-exec" {
    command = <<EOF
      step-cli certificate create root.linkerd.cluster.local ../linkerd_keys/linkerd-ca.crt ../linkerd_keys/linkerd-ca.key \
      --profile root-ca --no-password --insecure --force
EOF
  }
  count = var.linkerd_gen_certs == "yes" ? 1 : 0
}
resource "null_resource" "linkerd-issuer-certificate" {
  provisioner "local-exec" {
    command = <<EOF
      step-cli certificate create identity.linkerd.cluster.local ../linkerd_keys/linkerd-issuer.crt ../linkerd_keys/linkerd-issuer.key \
        --profile intermediate-ca --not-after 8760h --no-password --insecure \
        --ca ../linkerd_keys/linkerd-ca.crt --ca-key ../linkerd_keys/linkerd-ca.key --force
EOF
  }
  count = var.linkerd_gen_certs == "yes" ? 1 : 0
}
*/
resource "proxmox_vm_qemu" "k3s-master-01" {
  agent = 1
  onboot = true
  name = var.k3s_nodename_01
  target_node = var.proxmox_node_name
  clone = "template"
  full_clone = true
  os_type = "cloud-init"
  sockets = 1
  cores = var.cores_k3s_01
  memory = var.memory_k3s_01
  scsihw            = "virtio-scsi-pci"
  ipconfig0 = "ip=dhcp"
  sshkeys = var.ssh_public_key
  ciuser = "debian"
  disk {
    type            = "virtio"
    storage = "local"
    size = var.k3s_disksize_01
  }
  lifecycle {
     ignore_changes = [
       network
     ]
  }
  network {
    model = "virtio"
    bridge = var.k3s_bridge_01
    macaddr = var.k3s_macaddr_01
  }
  provisioner "local-exec" {
    command = <<EOT
    k3sup install \
      --ip ${proxmox_vm_qemu.k3s-master-01.default_ipv4_address} \
      --user debian \
      --cluster \
      --k3s-version ${var.kubernetes_version} \
      --k3s-extra-args '--no-deploy=traefik --node-external-ip=${var.k3s_external_ip_node_01} --advertise-address=${var.k3s_internal_ip_node_01} --node-ip=${var.k3s_internal_ip_node_01}'
    EOT
  }
}

resource "proxmox_vm_qemu" "k3s-master-02" {
  agent = 1
  onboot = true
  name = var.k3s_nodename_02
  target_node = var.proxmox_node_name
  clone = "template"
  full_clone = true
  os_type = "cloud-init"
  sockets = 1
  cores = var.cores_k3s_02
  memory = var.memory_k3s_02
  scsihw            = "virtio-scsi-pci"
  ipconfig0 = "ip=dhcp"
  sshkeys = var.ssh_public_key
  ciuser = "debian"
  disk {
    type            = "virtio"
    storage = "local"
    size = var.k3s_disksize_02
  }
  lifecycle {
     ignore_changes = [
       network
     ]
  }
  network {
    model = "virtio"
    bridge = var.k3s_bridge_02
    macaddr = var.k3s_macaddr_02
  }
  provisioner "local-exec" {
    command = <<EOT
    k3sup join \
      --ip  ${proxmox_vm_qemu.k3s-master-02.default_ipv4_address} \
      --user debian \
      --server \
      --server-user debian \
      --server-ip ${proxmox_vm_qemu.k3s-master-01.default_ipv4_address} \
      --k3s-version ${var.kubernetes_version} \
      --k3s-extra-args '--no-deploy=traefik --node-external-ip=${var.k3s_external_ip_node_02} --advertise-address=${var.k3s_internal_ip_node_02} --node-ip=${var.k3s_internal_ip_node_02}'
    EOT
  }
  depends_on = [
    proxmox_vm_qemu.k3s-master-01
  ]
}
resource "proxmox_vm_qemu" "k3s-master-03" {
  agent = 1
  onboot = true
  name = var.k3s_nodename_03
  target_node = var.proxmox_node_name
  clone = "template"
  full_clone = true
  os_type = "cloud-init"
  sockets = 1
  cores = var.cores_k3s_03
  memory = var.memory_k3s_03
  scsihw            = "virtio-scsi-pci"
  ipconfig0 = "ip=dhcp"
  sshkeys = var.ssh_public_key 
  ciuser = "debian"
  disk {
    type            = "virtio"
    storage = "local"
    size = var.k3s_disksize_03
  }
  lifecycle {
     ignore_changes = [
       network
     ]
  }
  network {
    model = "virtio"
    bridge = var.k3s_bridge_03
    macaddr = var.k3s_macaddr_03
  }
  provisioner "local-exec" {
    command = <<EOT
    k3sup join \
      --ip  ${proxmox_vm_qemu.k3s-master-03.default_ipv4_address} \
      --user debian \
      --server \
      --server-user debian \
      --server-ip ${proxmox_vm_qemu.k3s-master-01.default_ipv4_address} \
      --k3s-version ${var.kubernetes_version} \
      --k3s-extra-args '--no-deploy=traefik --node-external-ip=${var.k3s_external_ip_node_03} --advertise-address=${var.k3s_internal_ip_node_03} --node-ip=${var.k3s_internal_ip_node_03}'
    EOT
  }
  depends_on = [
    proxmox_vm_qemu.k3s-master-02
  ]
}
provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig"
  }
}

resource "helm_release" "cert-manager" {
  name        = "cert-manager"
  chart       = "cert-manager"
  repository  = "https://charts.jetstack.io"
  create_namespace = true
  set {
    name = "installCRDs"
    value = "true"
  }
  namespace = "cert-manager"
  depends_on = [
    proxmox_vm_qemu.k3s-master-01,
    proxmox_vm_qemu.k3s-master-02,
    proxmox_vm_qemu.k3s-master-03
  ]
}


resource "time_sleep" "wait_30_seconds" {
  depends_on = [helm_release.cert-manager]
  create_duration = "30s"
}

# This resource will create (at least) 30 seconds after null_resource.previous
resource "null_resource" "next" {
  depends_on = [time_sleep.wait_30_seconds]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  create_namespace = true 
  namespace = "argocd"
  version = "3.33.2"
  
  values = [
    "${file("argocd-values.yaml")}"
  ]

  depends_on = [
    null_resource.next,
    proxmox_vm_qemu.k3s-master-01,
    proxmox_vm_qemu.k3s-master-02,
    proxmox_vm_qemu.k3s-master-03
  ]
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
resource "helm_release" "bootstrap-core-apps" {
  name       = "bootstrap-core-apps"
  # disaster recovery: uncomment next file / and read deploy/disaster-recovery/README.md
  # chart      = "./../helm/bootstrap-apps-recovery"
  chart      = "./../helm/bootstrap-core-apps"
  create_namespace = true 
  namespace = "argocd"

  depends_on = [
    helm_release.argocd
  ]
}
resource "helm_release" "bootstrap-optional-apps" {
  name       = "bootstrap-optional-apps"
  # disaster recovery: uncomment next file / and read deploy/disaster-recovery/README.md
  # chart      = "./../helm/bootstrap-apps-recovery"
  chart      = "./../helm/bootstrap-optional-apps"
  create_namespace = true 
  namespace = "argocd"
  depends_on = [
    helm_release.bootstrap-core-apps
  ]
}
