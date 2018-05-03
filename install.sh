# Don't continue on error
set -e

# Define constants
ZSH_THEME="guri.zsh-theme"

CURRENT_PATH=$(pwd)
VIM_DIR="vim"
BASH_DIR="bash"
ZSH_DIR="zsh"
GIT_DIR="git"
TMUX_DIR="tmux"
MACOS_DIR="macos"
GNUPG_DIR="gnugp"

BASH_IT_CONFIG="$HOME/.bash_it"
OH_MY_ZSH_CONFIG="$HOME/.oh-my-zsh"
VIM_CONFIG="$HOME/.vim"
NEOVIM_CONFIG="$HOME/.config/nvim"
NEOVIM_LOCAL="$HOME/.local/share/nvim/site"
GNUPG="$HOME/.gnupg"

BASH_FILES=(bashrc bash_profile)
ZSH_FILES=(zshrc)
GIT_FILES=(gitignore gitconfig)
VIM_FILES=(vimrc)
TMUX_FILES=("tmux.conf")
GNUPG_FILES=("gpg.conf" "gpg-agent.conf")

command_exists() {
  type "$1" &>/dev/null
}

symlink_multiple() {
  source_dir="$1"
  files="$2"

  for file in $files; do
    echo "    Linking $file!"
    ln -sf "$CURRENT_PATH/$source_dir/$file" "$HOME/.$file"
  done
}

install_fonts() {
  echo "    Installing Powerline fonts!"
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf ./fonts
}

install_brew() {
  echo "    Installing brew!"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

upgrade_brew() {
  echo "    Upgrading and cleaning up brew formulae!"
  brew upgrade
  brew cleanup
}

install_bash_it() {
  echo "    Installing bash_it!"
  rm -rf "$BASH_IT_CONFIG"
  git clone --depth=1 https://github.com/Bash-it/bash-it.git "$BASH_IT_CONFIG"
  "$BASH_IT_CONFIG/install.sh" --no-modify-config
}

configure_bash() {
  echo "    Configuring bash!"
  symlink_multiple $BASH_DIR $BASH_FILES
}

install_zsh() {
  echo "    Installing zsh!"
  brew install zsh
}

install_oh_my_zsh() {
  echo "    Installing Oh My Zsh!"
  rm -rf "$OH_MY_ZSH_CONFIG"
  curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
}

configure_zsh() {
  echo "    Configuring zsh!"
  symlink_multiple $ZSH_DIR $ZSH_FILES
  ln -sf "$CURRENT_PATH/$ZSH_DIR/$ZSH_THEME" "$OH_MY_ZSH_CONFIG/themes/$ZSH_THEME"
  # Syntax highlighting
  rm -rf $OH_MY_ZSH_CONFIG/custom/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $OH_MY_ZSH_CONFIG/custom/plugins/zsh-syntax-highlighting
  # Autosuggestions
  rm -rf $OH_MY_ZSH_CONFIG/custom/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions $OH_MY_ZSH_CONFIG/custom/plugins/zsh-autosuggestions
}

install_git() {
  echo "    Installing git!"
  brew install git
}

configure_git() {
  echo "    Configuring git!"
  symlink_multiple $GIT_DIR $GIT_FILES
}

install_vim() {
  echo "    Installing vim!"
  brew install vim
}

install_nvim() {
  echo "    Installing neovim!"
  brew install neovim
}

install_vim_plug() {
  echo "    Installing Plug for vim!"
  curl -fLo "$VIM_CONFIG"/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_neovim_plug() {
  echo "    Installing Plug for neovim!"
  curl -fLo "$NEOVIM_LOCAL"/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

configure_vim() {
  echo "    Configuring vim!"
  symlink_multiple $VIM_DIR $VIM_FILES
  ln -sf "$CURRENT_PATH/$VIM_DIR/colors" "$HOME/.$VIM_DIR/colors"
}

configure_nvim() {
  echo "    Configuring neovim!"
  ln -sf "$CURRENT_PATH/$VIM_DIR/vimrc" "$NEOVIM_CONFIG/init.vim"
  ln -sf "$CURRENT_PATH/$VIM_DIR/colors" "$NEOVIM_CONFIG/colors"
}

install_tmux() {
  echo "    Installing tmux!"
  brew install tmux
}

install_tpm() {
  rm -rf ~/.tmux/plugins/tpm
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

configure_tmux() {
  symlink_multiple $TMUX_DIR $TMUX_FILES
}

install_gnugp() {
  echo "    Installing gnupg!"
  brew install gnupg
}

configure_gnupg() {
  echo "    Configuring gnupg!"
  symlink_multiple $GNUPG_DIR $GNUPG_FILES
}

if ! command_exists curl; then
  echo "Need curl to finish installation! Exiting script."
  exit 3
fi

echo "[ Fonts ]"
install_fonts

echo "[ Homebrew ]"
if ! command_exists brew; then
  install_brew
fi
upgrade_brew

echo "[ Bash ]"
mkdir -p "$BASH_IT_CONFIG"
install_bash_it
configure_bash

echo "[ ZSH ]"
install_zsh
mkdir -p "$OH_MY_ZSH_CONFIG/themes"
install_oh_my_zsh
configure_zsh

echo "[ Git ]"
install_git
configure_git

echo "[ Vim ]"
install_vim
mkdir -p "$VIM_CONFIG/autoload"
install_vim_plug
configure_vim

echo "[ Neovim ]"
install_nvim
mkdir -p "$NEOVIM_LOCAL/autoload"
mkdir -p "$NEOVIM_CONFIG"
install_neovim_plug
configure_nvim

echo "[ Tmux ]"
install_tmux
install_tpm
configure_tmux

