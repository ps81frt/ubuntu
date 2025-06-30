#!/bin/bash
# ============================================================================
# Auteur : ps81frt
# Déplace /home, /var et /tmp sur des volumes LVM séparés et supprime les anciens
# ============================================================================

set -e

# Variables
VG_NAME="ubuntu-vg"
LV_HOME="lvhome"
LV_VAR="lvvar"
LV_TMP="lvtmp"

# Créer les volumes logiques
lvcreate -L 100G -n $LV_HOME $VG_NAME
lvcreate -L 40G  -n $LV_VAR  $VG_NAME
lvcreate -L 20G  -n $LV_TMP  $VG_NAME

# Formater
mkfs.ext4 /dev/$VG_NAME/$LV_HOME
mkfs.ext4 /dev/$VG_NAME/$LV_VAR
mkfs.ext4 /dev/$VG_NAME/$LV_TMP

# Monter temporairement
mkdir -p /mnt/home /mnt/var /mnt/tmp
mount /dev/$VG_NAME/$LV_HOME /mnt/home
mount /dev/$VG_NAME/$LV_VAR  /mnt/var
mount /dev/$VG_NAME/$LV_TMP  /mnt/tmp

# Copier les données
rsync -aAX /home/ /mnt/home/
rsync -aAX /var/  /mnt/var/
rsync -aAX /tmp/  /mnt/tmp/

# Vérifier que la copie s’est bien faite (exemple sur /home)
if [ -f /home/$USER/.bashrc ] && [ -f /mnt/home/$USER/.bashrc ]; then
    echo "Copie réussie, suppression des anciens dossiers..."
    rm -rf /home/*
    rm -rf /var/*
    rm -rf /tmp/*
else
    echo "Erreur : les données n'ont pas été copiées correctement. Abandon."
    exit 1
fi

# Sauvegarde fstab
cp /etc/fstab /etc/fstab.bak

# Ajouter les entrées au fstab
echo "/dev/mapper/${VG_NAME}-${LV_HOME} /home ext4 defaults 0 2" >> /etc/fstab
echo "/dev/mapper/${VG_NAME}-${LV_VAR}  /var  ext4 defaults 0 2" >> /etc/fstab
echo "/dev/mapper/${VG_NAME}-${LV_TMP}  /tmp  ext4 defaults 0 2" >> /etc/fstab

echo "Terminé. Redémarre pour utiliser les nouveaux volumes LVM."
