# homelab

## motivation

I've recently changed from an android phone to a second hand iphone se 2020. At the same time i started to renovate my flat ( smart home aspects ). These 2 events ( and a few other smaller events ) made me want to claim ownership of my own data, migrate away from services such as google, apple and the clouds - ideally without losing the convenience it gives me. I used to run a homeserver with proxmox managed by ansible playbooks before - but since its 2022 and kubernetes is a thing i wanted to use kubernetes for this project. I also want this stuff to be "secure".


## the hardware
I see a lot of ppl attempting to run their homelab in high availability - i dont really plan to run any "critical applications", these i would run in the clouds. I ll by running the entire stack on a single server ( that happens to have a bunch of disks ), we ll be running 4 vms in proxmox, 3 that form a k3s cluster and 1 that provides storage ( truenas ). If you want to attempt to run it in ha you can run the 3 k3s nodes on 3 seperated hardware, provide a redundant truenas and off you go...

![img](docs/img/proxmox-vms.png)

## proxmox installation
proxmox installation is quite forward. I ll be installing debian 11 with full disk encryption on a single ssd ( feel free to go redundant here ). and then i ll update the debian 11 to become a proxmox ve7 host ( the proxmox installer doesnt come with a convenient way to do full disk encryption).

As for storage I have a 4Unit server with 24hdd slots with a HBA - since this is PCI device i ll simply pass this pci device with all disks to the truenas instance. if you dont have a similar device you can still pass in storage from the disks to the truenas vm using proxmox.

I also do use proxmox to configure simple firewall rules on the hosts - but that is pretty much it. Once proxmox is running we can start using this repository to create vms etc.

### proxmox debian 11 template
as the image build process is a one off thing i ve moved it to a seperate folder to reduce confusion :)

To get started building an image we first need to set some values in the variables.tf. This file will contain variables specific to your own setup - this is why the repo doesnt come with the file directly but with a variables.tf.example, you then create a variables.tf based of variables.tf.example - this allows you to pull changes from github.com/loeken/homelab at a later stage and dont have your variables.tf overwritten - while you can still compare the structure of both files for changes.

```
cd deploy/terraform
cp variables.tf.example variables.tf
```

the terraform script to build the template only references the first 3 variables inside the variables.tf file. now lets build a template

```
cd proxmox-debian-11-template
terraform init
terraform plan
terraform apply
```

then we can create the k3s cluster
```
cd ../k3s
terraform init
terraform plan
terraform apply
```
