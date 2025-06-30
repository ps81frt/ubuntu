# Créer les volumes (taille à adapter)
sudo lvcreate -L 100G -n lvhome vgubuntu
sudo lvcreate -L 40G -n lvvar vgubuntu
sudo lvcreate -L 20G -n lvtmp vgubuntu

# Formater les volumes
sudo mkfs.ext4 /dev/vgubuntu/lvhome
sudo mkfs.ext4 /dev/vgubuntu/lvvar
sudo mkfs.ext4 /dev/vgubuntu/lvtmp

# Monter temporairement
sudo mkdir /mnt/lvhome /mnt/lvvar /mnt/lvtmp
sudo mount /dev/vgubuntu/lvhome /mnt/lvhome
sudo mount /dev/vgubuntu/lvvar /mnt/lvvar
sudo mount /dev/vgubuntu/lvtmp /mnt/lvtmp

# Copier les données
sudo rsync -aXS --progress /home/ /mnt/lvhome/
sudo rsync -aXS --progress /var/ /mnt/lvvar/
sudo rsync -aXS --progress /tmp/ /mnt/lvtmp/

# Sauvegarder fstab
sudo cp /etc/fstab /etc/fstab.bak

# Ajouter les volumes dans fstab
echo '/dev/vgubuntu/lvhome /home ext4 defaults 0 2' | sudo tee -a /etc/fstab
echo '/dev/vgubuntu/lvvar /var ext4 defaults 0 2' | sudo tee -a /etc/fstab
echo '/dev/vgubuntu/lvtmp /tmp ext4 defaults 0 2' | sudo tee -a /etc/fstab

# Démonter points temporaires
sudo umount /mnt/lvhome /mnt/lvvar /mnt/lvtmp

# Monter les nouveaux points
sudo mount /home
sudo mount /var
sudo mount /tmp
