# Packer Debian 11 (bullseye) for Proxmox

The main purpose is to set up my home labs environments. So check it two or more times to use it in a production environment because I hadn't focused on production requirements.

**In brief** This project generates a (Qemu) Debian Proxmox template using preseed to get an unattended Debian installation and some customization after through cloud-init.

### Usage

#### Create your own variables.json

Setup your connection.

```
cp variables.pkr.hcl.example variables.pkr.hcl
```

#### Run Packer

Before this step is mostly possible that you want to customize preseed.cfg (preseed.pkrtpl), cloud.cfg or debian-11-bullseye.pkr.hcl.

Note that preseed is preprocessed by templatefile() function.

```
packer build --var-file=variables.pkr.hcl debian-11-bullseye.pkr.hcl
```

After ends, you will have a new Qemu template on your Proxmox.
