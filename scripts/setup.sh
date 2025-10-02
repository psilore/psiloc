#!/bin/sh

HOST="$1"

sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  gnupg \
  software-properties-common \
  dconf-editor \
  curl \
  htop \
  git \
  zsh \

# remove unwanted packages
sudo apt-get remove gnome-robots gnome-chess aisleriot five-or-more gnome-mahjongg tali four-in-a-row gnome-klotski gnome-mines gnome-nibbles gnome-2048 gnome-sudoku gnome-taquin gnome-tetravex hitori lightsoff quadrapassel swell-foop iagno -y
sudo apt-get remove	deja-dup goldendict gnote yelp totem brasero brasero-common cheese sound-juicer gnome-sound-recorder -y
sudo apt-get remove eog simple-scan shotwell -y
sudo apt-get remove pidgin hexchat transmission-gtk remmina deluge deluge-common deluge-gtk thunderbird -y
sudo apt-get remove firefox-esr -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# setup cron-job
cp ~/backup.sh /home/"$USER"/backup.sh
(crontab -u "$USER" -l 2>/dev/null; echo "0 0 */1 * * /home/$USER/backup.sh $HOST") | crontab -u "$USER" -

# setup 1password
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt-get update && sudo apt-get install 1password -y

# setup google chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get update && sudo apt-get install ./google-chrome-stable_current_amd64.deb -y

# setup tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update && sudo apt-get install tailscale -y

# setup terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform -y

# setup docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# setup vscode
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt-get update && sudo apt-get install code -y

# setup oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# clone & setup fuzzyfinder
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
"$HOME"/.fzf/install

# clone & setup zsh plugins
if [ -d "$HOME/.oh-my-zsh" ]; then
  git clone --depth 1 -- https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}"/plugins/fzf-tab
  git clone --depth 1 -- https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
  git clone --depth 1 -- https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
  git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
fi
                                                                                        
# install Source Code pro fonts
mkdir -p ~/.fonts/adobe-fonts/source-code-pro
git clone --depth 1 https://github.com/adobe-fonts/source-code-pro.git ~/.fonts/adobe-fonts/source-code-pro
fc-cache -f -v ~/.fonts/adobe-fonts/source-code-pro

# load gnome-terminal profile config
if command -v dconf >&2; then
  dconf load /org/gnome/terminal/legacy/profiles:/ < ~/gnome-terminal-profiles.dconf
fi

# setup zsh as default shell
chsh -s "$(which zsh)"
$SHELL --version

# setup basic ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh
sudo ufw enable
