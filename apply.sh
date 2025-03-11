if [ -f "/etc/nixos/.env" ]; then
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
if [ ! -f /etc/nixos/.env ]; then
    touch /etc/nixos/.env
    echo server=$server >> /etc/nixos/.env
    echo share=$share >> /etc/nixos/.env
   echo wakatimeApiKey=$wakatimeApiKey >> /etc/nixos/.env
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
if [ ! -f /etc/nixos/.env ]; then
  gio copy smb://$server/$share/keys/envs/.env /etc/nixos/.env
fi
curl https://raw.githubusercontent.com/juancolchete/nixos/refs/heads/main/configuration.nix -o /etc/nixos/configuration.nix 
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update 
sudo nixos-rebuild switch
if [ ! -d /home/juanc/.config/nvim ]; then
  git clone git@github.com:juancolchete/nvim.git /home/juanc/.config/nvim
fi
if [ ! -d /home/juanc/.wakatime ]; then
  mkdir /home/juanc/.wakatime
  cd /home/juanc/.wakatime
  wget https://github.com/wakatime/wakatime-cli/releases/download/v1.106.1/wakatime-cli-linux-amd64.zip
  unzip /home/juanc/.wakatime/wakatime-cli-linux-amd64 -d /home/juanc/.wakatime
  mv wakatime-cli-linux-amd64 wakatime-cli
  rm /home/juanc/.wakatime/wakatime-cli-linux-amd64.zip
  nvim +PlugInstall +qa
fi
if [ ! -f /home/juanc/.wakatime.cfg ]; then
  echo [settings] >> /home/juanc/.wakatime.cfg
  echo debug=false >> /home/juanc/.wakatime.cfg
  echo hidefilenames = false >> /home/juanc/.wakatime.cfg
  echo ignore = >> /home/juanc/.wakatime.cfg
  echo "    COMMIT_EDITMSG$" >> /home/juanc/.wakatime.cfg
  echo "    PULLREQ_EDITMSG$" >> /home/juanc/.wakatime.cfg
  echo "    MERGE_MSG$" >> /home/juanc/.wakatime.cfg
  echo "    TAG_EDITMSG$" >> /home/juanc/.wakatime.cfg
  echo api_key=$wakatimeApiKey >> /home/juanc/.wakatime.cfg
fi
chmod  400 /home/juanc/.ssh/github
eval "$(ssh-agent -s)"
ssh-add /home/juanc/.ssh/github
cd /etc/nixos
git config --global init.defaultBranch main
git init -b main
git config pull.rebase false
git remote -v | grep -w origin && git remote set-url origin git@github.com:juancolchete/nixos.git || git remote add origin git@github.com:juancolchete/nixos.git
rm configuration.nix
rm apply.sh
git pull origin main
git branch --set-upstream-to=origin/main main
git push --set-upstream origin main
source ~/.bashrc
mkdir -p /home/juanc/programs
cd /home/juanc/programs
[ ! -d "/home/juanc/programs/solana" ] && git clone -b v1.18 https://github.com/solana-labs/solana.git /home/juanc/programs/solana
sh /home/juanc/programs/solana/scripts/cargo-install-all.sh /home/juanc/programs
git clone git@github.com:juancolchete/nvim.git /home/juanc/.config/nvim
nvim --headless +PlugInstall +qa!
sudo wget https://github.com/dfinity/sdk/releases/download/0.25.0/dfx-0.25.0-x86_64-linux.tar.gz -O /home/juanc/programs/bin/dfx.tar.gz
sudo tar xzf /home/juanc/programs/bin/dfx.tar.gz -C /home/juanc/programs/bin/
