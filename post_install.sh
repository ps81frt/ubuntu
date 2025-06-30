#!/bin/bash
set -e

# Variables
DISK="/dev/sda"           # disque principal, adapte si besoin
VG_NAME="ubuntu-vg"
LV_HOME="lvhome"
LV_VAR="lvvar"
LV_TMP="lvtmp"

# 0. Vérifier que la partition EFI est montée
if ! mountpoint -q /boot/efi; then
  echo "Montage de la partition EFI..."
  mount /boot/efi
else
  echo "La partition EFI est déjà montée."
fi

# 1. Créer une partition LVM (si besoin)
parted --script $DISK \
  mkpart primary 1024MiB 100% \
  set 2 lvm on

# 2. Créer PV, VG, et LVs (à commenter si VG déjà existant)
pvcreate ${DISK}2
vgcreate $VG_NAME ${DISK}2

lvcreate -L 100G -n $LV_HOME $VG_NAME
lvcreate -L 40G -n $LV_VAR $VG_NAME
lvcreate -L 20G -n $LV_TMP $VG_NAME

# 3. Formater les volumes
mkfs.ext4 /dev/$VG_NAME/$LV_HOME
mkfs.ext4 /dev/$VG_NAME/$LV_VAR
mkfs.ext4 /dev/$VG_NAME/$LV_TMP

# 4. Monter temporairement
mkdir -p /mnt/lvhome /mnt/lvvar /mnt/lvtmp
mount /dev/$VG_NAME/$LV_HOME /mnt/lvhome
mount /dev/$VG_NAME/$LV_VAR /mnt/lvvar
mount /dev/$VG_NAME/$LV_TMP /mnt/lvtmp

# 5. Copier les données actuelles
echo "Copie des données vers LVM..."
rsync -aXS --progress /home/ /mnt/lvhome/
rsync -aXS --progress /var/ /mnt/lvvar/
rsync -aXS --progress /tmp/ /mnt/lvtmp/

# 6. Sauvegarder fstab
cp /etc/fstab /etc/fstab.bak

# 7. Ajouter entrées LVM dans fstab
echo "/dev/$VG_NAME/$LV_HOME /home ext4 defaults 0 2" >> /etc/fstab
echo "/dev/$VG_NAME/$LV_VAR /var ext4 defaults 0 2" >> /etc/fstab
echo "/dev/$VG_NAME/$LV_TMP /tmp ext4 defaults 0 2" >> /etc/fstab

# 8. Démonter les points temporaires
umount /mnt/lvhome /mnt/lvvar /mnt/lvtmp

# 9. Monter les nouveaux volumes
mount /home
mount /var
mount /tmp

echo "Configuration LVM terminée. Pense à redémarrer le système."

exit 0
