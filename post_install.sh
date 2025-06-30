#!/bin/bash
# ============================================================================
# Auteur : ps81frt
# Déplace /home, /var et /tmp sur des volumes LVM séparés et supprime les anciens
# Sans fonctions, sans if, sans boucle
# ============================================================================

VG_NAME="ubuntu-vg"
LV_HOME="lvhome"
LV_VAR="lvvar"
LV_TMP="lvtmp"

lvcreate -L 100G -n $LV_HOME $VG_NAME
lvcreate -L 40G  -n $LV_VAR  $VG_NAME
lvcreate -L 20G  -n $LV_TMP  $VG_NAME

mkfs.ext4 /dev/$VG_NAME/$LV_HOME
mkfs.ext4 /dev/$VG_NAME/$LV_VAR
mkfs.ext4 /dev/$VG_NAME/$LV_TMP

mkdir -p /mnt/home
mkdir -p /mnt/var
mkdir -p /mnt/tmp

mount /dev/$VG_NAME/$LV_HOME /mnt/home
mount /dev/$VG_NAME/$LV_VAR  /mnt/var
mount /dev/$VG_NAME/$LV_TMP  /mnt/tmp

rsync -aAX /home/ /mnt/home/
rsync -aAX /var/  /mnt/var/
rsync -aAX /tmp/  /mnt/tmp/

rm -rf /home/*
rm -rf /var/*
rm -rf /tmp/*

cp /etc/fstab /etc/fstab.bak

echo "/dev/mapper/${VG_NAME}-${LV_HOME} /home ext4 defaults 0 2" >> /etc/fstab
echo "/dev/mapper/${VG_NAME}-${LV_VAR}  /var  ext4 defaults 0 2" >> /etc/fstab
echo "/dev/mapper/${VG_NAME}-${LV_TMP}  /tmp  ext4 defaults 0 2" >> /etc/fstab

echo "Opération terminée. Redémarre le système pour activer les montages."
