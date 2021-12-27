packer {
  required_version = "~> 1.7.8"
  required_plugins {
     proxmox-iso = {
       version = ">= 1.0.3"
       source  = "github.com/hashicorp/proxmox"
     }
  }
}

variable "proxmox_host" {
  type =  string
  default = "localhost:8006"
}

variable "proxmox_node" {
  type = string
  default = "proxmox"
}

variable "proxmox_api_user" {
  type = string
  default = "packer"
}

variable "proxmox_api_password" {
  type = string
  default = "changeme!"
  sensitive = true
}

variable "boot_wait" {
  type    = string
  default = "3s"
}

variable "ssh_key" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRvPrOkNMLPBT8KZWPyXX+VwF+y4yaA3xgzFFOoMx2KhLdMwQhMd7Irg96hqc8rKYvFpiPM7MhTSZtH83KlAA9di1kHgxi/X7qTJI447kVtsEiWpiipF6Ffu6Ej8D6GXGe4vz019WsATVcle8pWVeOw+ztFGkLgSwLEuskWPvPOmZrS4WfivyeCfChXHhDvdsxZ0bHzKWMlk2S/Xb9w8GrOrhvM7uTt7tZj4ln20XFVDfK/XBRH2tk2OfROT0aHVV5moohe5Go5gxGE+UrnTTD0a3/Am3jfOc1jqEBg8WB4tpjAQ74avJm5fSYOYUzq4ZyVpCgm/hRyiynYQDgb/QeuqUEElmqxCZmMas6PVNUa9fTksI2Ta0x05CBRc1iuYqUY8PQem+JC/HBYexFIg/sQ+xa8F19Y4W8NKGQvhal8/tfjFY1IuBy0ezMBO2vmQsd5c5UujKjE023JVOumSwiWDLCOy45cE4644Hs7sy23pM1PKs7wkHdsfd17Im4mJPNvePUfANpfKBkt7op5pBHACn+69xiLr1IBDQ04o93B2nEAEsKudY89QBjYrj31HELjx8bNL5qDnJiVZhc/TqzOgg67VulxhJultwCNqimZ/IsI7NOVyomn7lIYBgUJy4dM0ipYnKkUfqhhhR49PyNlsvFtB2SC6JiU0lOcUIuow== mati@centuripe"
}

variable "root_password" {
  type = string
  default = "packer"
  sensitive = true
}

variable "vm_name" {
  type    = string
  default = "debian-11.2.0-amd64"
}

variable "vm_domain" {
  type    = string
  default = "matiasferrigno.com.ar"
}

variable "vm_root_disk_size" {
  type = string
  default = "30G"
}

variable "iso_file" {
  type    = string
  default = "local:iso/debian-11.2.0-amd64-netinst.iso"
}

variable "preseed_file" {
  type    = string
  default = "preseed.cfg"
}

variable "system_clock_in_utc" {
  type    = string
  default = "true"
}

variable "country" {
  type    = string
  default = "AR"
}

variable "domain" {
  type    = string
  default = ""
}

variable "sockets" {
  type    = string
  default = "1"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "keyboard" {
  type    = string
  default = "en"
}

variable "language" {
  type    = string
  default = "en"
}

variable "locale" {
  type    = string
  default = "en_US"
}

variable "mirror" {
  type    = string
  default = "debian.unnoba.edu.ar"
}

variable "timezone" {
  type    = string
  default = "America/Argentina/Buenos_Aires"
}

source "proxmox-iso" "debian11-template" {
  node                 = var.proxmox_node
  vm_name              = var.vm_name
  template_description = "Debian 11 cloud-init template. Built on ${legacy_isotime("2006-01-02T15:04:05Z")}"

  proxmox_url          = "https://${var.proxmox_host}/api2/json"
  username             = var.proxmox_api_user
  password             = var.proxmox_api_password

  boot_command         = ["<wait><wait><wait>c<wait><wait><wait>", "linux /install.amd/vmlinuz ", "auto=true ", "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed_file} ", "hostname=${var.vm_name} ", "domain=${var.domain} ", "interface=auto ", "vga=788 noprompt quiet --<enter>", "initrd /install.amd/initrd.gz<enter>", "boot<enter>"]
  boot_wait            = var.boot_wait

  cloud_init              = true
  cloud_init_storage_pool = "local"

  bios                 = "ovmf"
  efidisk	       = "local"
  os                   = "l26"
  machine	       = "pc-q35-6.1"

  sockets              = var.sockets
  cores                = var.cpus
  cpu_type             = "host"
  memory               = var.memory

  scsi_controller      = "virtio-scsi-single"

  disks {
    disk_size         = var.vm_root_disk_size
    format            = "raw"
    storage_pool      = "local"
    storage_pool_type = "Directory"
    type              = "scsi"
  }

  insecure_skip_tls_verify = true
  iso_file                 = var.iso_file
  unmount_iso              = true

  network_adapters {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  ssh_password = var.root_password
  ssh_username = "root"

  http_content = {
      "/preseed.cfg" = templatefile("preseed.pkrtpl", {
        language = var.language,
        country = var.country,
        timezone = var.timezone,
        locale = var.locale,
        keyboard = var.keyboard,
        vm_name = var.vm_name,
        vm_domain = var.vm_domain,
        mirror = var.mirror,
        system_clock_in_utc = var.system_clock_in_utc,
        ssh_password = var.root_password,
        ssh_key = var.ssh_key
      }),
  }
}

build {

  sources = ["source.proxmox-iso.debian11-template"]

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    content = templatefile("cloud.pkrtpl", {
        timezone = var.timezone,
        mirror = var.mirror,
        ssh_key = var.ssh_key
    })
  }

}
