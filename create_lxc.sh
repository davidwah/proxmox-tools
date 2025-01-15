#!/bin/bash

# Meminta input jumlah LXC
read -p "Masukkan jumlah LXC yang ingin dibuat: " jumlah_lxc

# Loop untuk membuat, menyalakan, dan mengkonfigurasi LXC
for i in $(seq -f "%02g" 1 $jumlah_lxc)
do
  echo "Membuat LXC dengan ID 100$i..."
  pct create 100$i local:vztmpl/{{image-template-lxc}}.tar.gz \
    -hostname LXC$i \
    -storage local-lvm \
    -memory 512 \
    -net0 name=eth0,bridge=vmbr0,ip=dhcp
  
  echo "Menyalakan LXC dengan ID 100$i..."
  pct start 100$i
  
  # Menunggu beberapa detik agar LXC selesai booting
  sleep 10
  
  echo "Menambahkan user login: user$i"
  pct exec 100$i -- useradd -m -s /bin/bash user$i
  
  # Mengatur password sesuai dengan user yang dibuat
  password="user$i"
  echo "Mengatur password untuk user$i"
  pct exec 100$i -- bash -c "echo -e \"$password\\n$password\" | passwd user$i"
  
  # Menambahkan user ke dalam grup sudo dan root
  echo "Menambahkan user$i ke dalam grup sudo dan root"
  pct exec 100$i -- usermod -aG sudo user$i
  pct exec 100$i -- usermod -aG root user$i
  
  # Mendapatkan alamat IP dari LXC
  ip_address=$(pct exec 100$i -- hostname -I | awk '{print $1}')
  echo "Alamat IP untuk LXC 100$i adalah: $ip_address"
  
  echo "LXC 100$i dengan user user$i dan password $password telah dibuat."
done

echo "Semua LXC telah selesai dibuat dan dikonfigurasi."
