#!/bin/bash
set -e

DISK="/dev/sda"
VG_NAME="ubuntu-vg"
LV_HOME="lvhome"
LV_VAR="lvvar"
LV_TMP="lvtmp"

# Démontage des partitions montées (adapte les partitions si besoin)
sudo umount -l ${DISK}1
sudo umount -l ${DISK}2
sudo umount -l ${DISK}3

# Créer la table de partitions GPT (attention, efface tout)
sudo parted --script $DISK mklabel gpt

# Créer partition EFI 1024MiB
sudo parted --script $DISK mkpart ESP fat32 1MiB 1025MiB
sudo parted --script $DISK set 1 boot on
sudo parted --script $DISK set 1 esp on

# Créer partition LVM pour le reste du disque
sudo parted --script $DISK mkpart primary 1025MiB 100%
sudo parted --script $DISK set 2 lvm on

# Formater la partition EFI
sudo mkfs.vfat -F32 ${DISK}1

# Préparer LVM
sudo pvcreate ${DISK}2
sudo vgcreate $VG_NAME ${DISK}2

sudo lvcreate -L 100G -n $LV_HOME $VG_NAME
sudo lvcreate -L 40G -n $LV_VAR $VG_NAME
sudo lvcreate -L 20G -n $LV_TMP $VG_NAME
sudo lvcreate -L 9G -n lvswap $VG_NAME

# Formater les volumes logiques
sudo mkfs.ext4 /dev/$VG_NAME/$LV_HOME
sudo mkfs.ext4 /dev/$VG_NAME/$LV_VAR
sudo mkfs.ext4 /dev/$VG_NAME/$LV_TMP
sudo mkswap /dev/$VG_NAME/lvswap

# Monter les partitions
sudo mkdir -p /mnt/boot/efi /mnt/home /mnt/var /mnt/tmp
sudo mount ${DISK}1 /mnt/boot/efi
sudo mount /dev/$VG_NAME/$LV_HOME /mnt/home
sudo mount /dev/$VG_NAME/$LV_VAR /mnt/var
sudo mount /dev/$VG_NAME/$LV_TMP /mnt/tmp
sudo swapon /dev/$VG_NAME/lvswap

echo "Partitionnement, LVM, formatage et montage terminés."
