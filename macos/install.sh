# Dont continue on error
set -e

cd ..

ZSH_THEME="guri.zsh-theme"

CURRENT_PATH=$(pwd)
VIM_DIR="vim"
BASH_DIR="bash"
ZSH_DIR="zsh"
GIT_DIR="git"
MACOS_DIR="macos"

BASH_IT_CONFIG="$HOME/.bash_it"
OH_MY_ZSH_CONFIG="$HOME/.oh-my-zsh"
VIM_CONFIG="$HOME/.vim"
NEOVIM_CONFIG="$HOME/.config/nvim"
NEOVIM_LOCAL="$HOME/.local/share/nvim/site"

BASH_FILES=("bashrc" "bash_profile")
ZSH_FILES=("zshrc")
GIT_FILES=("gitignore")
VIM_FILES=("vimrc")

CONFIG_SCRIPTS=("os" "chrome")

command_exists() {
  type "$1" &>/dev/null
}

symlink_multiple() {
  source_dir="$1"
  files="$2"

  for file in $files; do
    echo "    Linking .$file!"
    ln -sf "$CURRENT_PATH/$source_dir/$file" "$HOME/.$file"
  done
}

install_brew() {
  echo "    Installing brew!"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

install_bash_it() {
  echo "    Installing bash_it!"
  rm -rf "$BASH_IT_CONFIG"
  git clone --depth=1 https://github.com/Bash-it/bash-it.git "$BASH_IT_CONFIG"
  "$BASH_IT_CONFIG/install.sh" --no-modify-config
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

load_oh_my_zsh_theme() {
  echo "    Loading Oh My Zsh theme"
  ln -sf "$CURRENT_PATH/$ZSH_DIR/$ZSH_THEME" "$OH_MY_ZSH_CONFIG/themes/$ZSH_THEME"
}

install_powerline_fonts() {
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf fonts
}

install_zsh_syntax_highlighting() {
  brew install zsh-syntax-highlighting
}

install_nvim() {
  echo "    Installing neovim!"
  brew install neovim
}

configure_nvim() {
  echo "   Linking init.vim with vimrc!"
  ln -sf "$CURRENT_PATH/$ZSH_DIR/$ZSH_THEME" "$ZSH_DIR/init.vim"
}

install_plug() {
  echo "    Installing Plug!"
  curl -fLo "$VIM_CONFIG"/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  curl -fLo "$NEOVIM_LOCAL"/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_tmux() {
  brew install tmux
}

if ! command_exists curl; then
  echo "Need curl to finish installation! Exiting script."
  exit 3
fi

echo "[ Homebrew ]"

if ! command_exists brew; then
  install_brew
fi

echo "[ Bash ]"

mkdir -p "$BASH_IT_CONFIG"

install_bash_it
symlink_multiple $BASH_DIR $BASH_FILES

echo "[ ZSH ]"

if ! command_exists zsh; then
  install_zsh
fi

mkdir -p "$OH_MY_ZSH_CONFIG/themes"

install_oh_my_zsh
symlink_multiple $ZSH_DIR $ZSH_FILES
load_oh_my_zsh_theme
install_powerline_fonts
install_zsh_syntax_highlighting

echo "[ Git ]"

symlink_multiple $GIT_DIR $GIT_FILES

echo "[ Vim/Neovim ]"

if ! command_exists nvim; then
  install_nvim
fi

mkdir -p "$VIM_CONFIG/autoload"
mkdir -p "$NEOVIM_LOCAL/autoload"
mkdir -p "$NEOVIM_CONFIG"

install_plug
symlink_multiple $VIM_DIR $VIM_FILES
configure_nvim

install_tmux
