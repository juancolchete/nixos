if [ -e "/etc/nixos/.env" ]; then
    source /etc/nixos/.env
fi
sudo chown -R juanc /etc/nixos
if [[ ! -z "server" ]]; then
  read -p 'server: ' server
fi
if [[ ! -z "share" ]]; then
  read -p 'share: ' share
fi
if [ ! -e "~/.ssh/github" ]; then
  gio copy smb://$server/$share/keys/github ~/.ssh/github
fi
if [ ! -e "~/.ssh/github.pub" ]; then
  gio copy smb://$server/$share/keys/github.pub ~/.ssh/github.pub
  chmod  400 ~/.ssh/github
fi
if [ ! -e "/etc/nixos/env.nix" ]; then
  gio copy smb://$server/$share/keys/envs/env.nix /etc/nixos/env.nix
fi
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
rustup use 1.79.0
touch /home/juanc/programs/solana/rust-toolchain.toml
rm /home/juanc/programs/solana/rust-toolchain.toml
touch /home/juanc/programs/solana/rust-toolchain.toml
echo '[toolchain]' >> /home/juanc/programs/solana/rust-toolchain.toml
echo 'channel = "1.79.0"' >> /home/juanc/programs/solana/rust-toolchain.toml
[ ! -d "/home/juanc/programs/solana" ] && runuser -u juanc git clone https://github.com/solana-labs/solana /home/juanc/programs/solana
sh /home/juanc/programs/solana/scripts/cargo-install-all.sh /home/juanc/program
