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
wget -qO ~/Downloads/1password-latest.deb https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb
sudo apt-get update && sudo apt-get install ~/Downloads/1password-latest.deb -y

# setup google chrome
wget -qO ~/Downloads/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get update && sudo apt-get install ~/Downloads/google-chrome-stable_current_amd64.deb -y

# setup tailscale
curl -fsSL https://tailscale.com/install.sh | sh

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
  git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM"/plugins/zsh-autocomplete
fi

# install Source Code Nerd fonts single user
wget -qO ~/Downloads/SourceCodePro.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip
unzip -o ~/Downloads/SourceCodePro.zip -d ~/Downloads/SourceCodePro
mkdir -p ~/.local/share/fonts
cp ~/Downloads/SourceCodePro ~/.local/share/fonts/
fc-cache -fv

# load gnome-terminal profile config
if command -v dconf >&2; then
  dconf load /org/gnome/terminal/legacy/profiles:/ < ./config/terminal/colors/monokai-dark.dconf
fi

# setup zsh as default shell
chsh -s "$(which zsh)"
$SHELL --version

# setup basic ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh
sudo ufw enable
