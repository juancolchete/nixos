sudo chown -R juanc /etc/nixos
sudo mount -t cifs smb://192.168.100.120/ /mnt/TRUENAS
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update 
sudo nixos-rebuild switch
