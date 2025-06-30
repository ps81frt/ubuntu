#!/bin/bash
# Auteur: ps81frt
DISK="/dev/sda"
VG_NAME="ubuntu-vg"
LV_ROOT="lvroot"
LV_HOME="lvhome"
LV_VAR="lvvar"
LV_TMP="lvtmp"
LV_SWAP="lvswap"

echo "Effacement et partitionnement du disque $DISK"

parted --script $DISK \
  mklabel gpt \
  mkpart primary fat32 1MiB 1025MiB \
  set 1 boot on \
  mkpart primary 1025MiB 100% \
  set 2 lvm on

pvcreate ${DISK}2
vgcreate $VG_NAME ${DISK}2

lvcreate -L 60G -n $LV_ROOT $VG_NAME
lvcreate -L 100G -n $LV_HOME $VG_NAME
lvcreate -L 40G -n $LV_VAR $VG_NAME
lvcreate -L 20G -n $LV_TMP $VG_NAME
lvcreate -L 8G -n $LV_SWAP $VG_NAME

mkfs.vfat -F32 ${DISK}1
mkfs.ext4 /dev/$VG_NAME/$LV_ROOT
mkfs.ext4 /dev/$VG_NAME/$LV_HOME
mkfs.ext4 /dev/$VG_NAME/$LV_VAR
mkfs.ext4 /dev/$VG_NAME/$LV_TMP
mkswap /dev/$VG_NAME/$LV_SWAP

echo "Partition EFI : ${DISK}1"
echo "Volumes logiques :"
echo " Root : /dev/$VG_NAME/$LV_ROOT"
echo " Home : /dev/$VG_NAME/$LV_HOME"
echo " Var  : /dev/$VG_NAME/$LV_VAR"
echo " Tmp  : /dev/$VG_NAME/$LV_TMP"
echo " Swap : /dev/$VG_NAME/$LV_SWAP"
