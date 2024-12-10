[ -d ".env" ] && source .env
sudo chown -R juanc /etc/nixos
source .env
if [[ -z "$var" ]]; then
  read -p 'server: ' server
fi
if [[ -z "$var" ]]; then
  read -p 'share: ' share
fi
gio copy smb://$server/$share/apply.sh /etc/nixos/apply.sh
gio copy smb://$server/$share/keys/github ~/.ssh/github
gio copy smb://$server/$share/keys/github.pub ~/.ssh/github.pub
gio copy smb://$server/$share/keys/envs/env.nix /etc/nixos/env.nix
chmod  400 ~/.ssh/github
curl https://raw.githubusercontent.com/juancolchete/nixos/refs/heads/main/configuration.nix -o /etc/nixos/configuration.nix 
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update 
sudo nixos-rebuild switch
cd /etc/nixos
git init
git remote -v | grep -w origin && git remote set-url origin git@github.com:juancolchete/nixos.git || git remote add origin git@github.com:juancolchete/nixos.git
git branch -m main
git push --set-upstream origin main
git pull
sh /home/juanc/programs/solana/scripts/cargo-install-all.sh /home/juanc/programs
