#! /usr/bin/env bash

ENV=`dirname "$(readlink -f "$BASH_SOURCE")"`
LN="ln -fs"

# Install some packages
sudo apt update && sudo apt install -y python3-pip python3-venv curl git tmux \
  python3-full xclip zsh-autosuggestions zsh-syntax-highlighting vim-gtk3 ncal tree\
  gnupg software-properties-common flameshot kazam vlc aptitude nload aria2 \
  gcc make perl terminator jcal remmina keepassxc p7zip-full rar unrar bmon \
  gnome-tweaks gnome-shell-extension-manager ipython3 tldr nodejs xournalpp

if [[ $? -ne 0 ]]; then
  echo "Some packages failed to install"
  exit 1
fi

# Install fzf
read -p "Do you want to install fzf? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf ~/.fzf
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
fi

if [[ $? -ne 0 ]]; then
  echo "fzf failed to install"
  exit 1
fi

# Install oh-my-zsh
read -p "Do you want to install Oh My Zsh? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf ~/.oh-my-zsh
  yes | sh -c "$(curl -fsSL \
  https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ $? -ne 0 ]]; then
  echo "Oh My Zsh failed to install"
  exit 1
fi

# Set up ZSH as default shell
read -p "Do you want to set ZSH as the default shell? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  chsh -s $(which zsh)
fi

# Install Oh My Zsh Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install Vim plugins
read -p "Do you want to install Vim plugins? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  python3 -m venv ${HOME}/.vim/pyenv
fi

function linkfile {
	if [ -f $2 ]; then
		read -p "Do you want to overwrite sym-link: '$2'? [N/y] "
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			echo "Overwriting: $2"
		    # do dangerous stuff
		else
			return
		fi
	fi
	$LN $1 $2
}

# zsh
read -p "Do you want to update the .zshrc? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  linkfile "${ENV}/zshrc" "${HOME}/.zshrc"
fi

read -p "Do you want to update the .zsh_aliases? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  linkfile "${ENV}/zsh_aliases" "${HOME}/.zsh_aliases"
fi

# vim
read -p "Do you want to create .vimrc? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  linkfile "${ENV}/vimrc" "${HOME}/.vimrc"
  vim +PlugInstall +qall
fi

# default editor
read -p "Do you want to set vim as the default editor? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo 'export EDITOR=/usr/bin/vim' | sudo tee /etc/profile.d/editor.sh \
  > /dev/null
fi

# ssh
read -p "Do you want to update the SSH config? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  mkdir -p "${HOME}/.ssh/config.d"
  mkdir -p "${HOME}/.ssh/sshcontrolmasters"
  linkfile "${ENV}/sshconfig" "${HOME}/.ssh/config"
fi

# terminator
read -p "Do you want to update the Terminator config and theme? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  mkdir -p "${HOME}/.config/terminator"
  linkfile "${ENV}/terminatorconfig" "${HOME}/.config/terminator/config"
  linkfile "${ENV}/gtk.css" "${HOME}/.config/gtk-3.0/gtk.css"
fi

# change wallpaper
read -p "Do you want to change the wallpaper? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  gsettings set org.gnome.desktop.background picture-uri-dark \
    file://`pwd`/background.jpg
fi


# youtube
read -p "Do you want to add youtube script to your PATH? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  linkfile "${ENV}/youtube" "/usr/local/bin/yu"
fi

# passwordless switch to root
read -p "Do you want to enable passwordless switch from $USER to root? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER \
  > /dev/null
fi

# DevOps tools
read -p "Do you want to install DevOps tools? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash ${ENV}/devops-tools.sh
fi

# reboot for apply changes
read -p "Do you want to reboot? [N/y] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo reboot
fi
