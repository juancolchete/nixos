if [ -e "/etc/nixos/.env" ]; then
    source /etc/nixos/.env
fi
sudo chown -R juanc /etc/nixos
if [[ -z "$server" ]]; then
  read -p 'server: ' server
fi
if [[ -z "$share" ]]; then
  read -p 'share: ' share
fi
if [[ -z "$wakatimeApiKey" ]]; then
  read -p 'wakatimeApiKey: ' wakatimeApiKey
fi
if [ ! -f ~/.ssh/github ]; then
  gio copy smb://$server/$share/keys/github ~/.ssh/github
  chmod  400 ~/.ssh/github
fi
if [ ! -f ~/.ssh/github.pub ]; then
  gio copy smb://$server/$share/keys/github.pub ~/.ssh/github.pub
fi
if [ ! -f /etc/nixos/env.nix ]; then
  gio copy smb://$server/$share/keys/envs/env.nix /etc/nixos/env.nix
fi
echo ''
[settings]
debug=false
hidefilenames = false
ignore =
    COMMIT_EDITMSG$
    PULLREQ_EDITMSG$
    MERGE_MSG$
    TAG_EDITMSG$
api_key=$wakatimeApiKey
'' >> ~/.wakatime.cfg
curl https://raw.githubusercontent.com/juancolchete/nixos/refs/heads/main/configuration.nix -o /etc/nixos/configuration.nix 
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update 
sudo nixos-rebuild switch
cd /etc/nixos
git init
git config pull.rebase false
git remote -v | grep -w origin && git remote set-url origin git@github.com:juancolchete/nixos.git || git remote add origin git@github.com:juancolchete/nixos.git
git branch -m main
git branch --set-upstream-to=origin/main main
git pull
source ~/.bashrc
mkdir -p /home/juanc/programs
[ ! -d "/home/juanc/programs/solana" ] && git clone -b v1.18 https://github.com/solana-labs/solana.git /home/juanc/programs/solana
sh /home/juanc/programs/solana/scripts/cargo-install-all.sh /home/juanc/programs

