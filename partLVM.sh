sudo parted /dev/sda -- mklabel gpt

# EFI
sudo parted /dev/sda -- mkpart ESP fat32 1MiB 1025MiB
sudo parted /dev/sda -- set 1 boot on

# Partition LVM
sudo parted /dev/sda -- mkpart primary 1025MiB 100%
sudo parted /dev/sda -- set 2 lvm on

sudo pvcreate /dev/sda2
sudo vgcreate ubuntu-vg /dev/sda2
sudo lvcreate -L 60G -n lvroot ubuntu-vg
sudo lvcreate -L 100G -n lvhome ubuntu-vg
sudo lvcreate -L 40G -n lvvar ubuntu-vg
sudo lvcreate -L 20G -n lvtmp ubuntu-vg
sudo lvcreate -L 8G -n lvswap ubuntu-vg

sudo mkfs.vfat -F32 /dev/sda1
sudo mkfs.ext4 /dev/ubuntu-vg/lvroot
sudo mkfs.ext4 /dev/ubuntu-vg/lvhome
sudo mkfs.ext4 /dev/ubuntu-vg/lvvar
sudo mkfs.ext4 /dev/ubuntu-vg/lvtmp
sudo mkswap /dev/ubuntu-vg/lvswap
