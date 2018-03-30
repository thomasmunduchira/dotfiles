# Dont continue on error
set -e

brew tap caskroom/versions
brew cask install java8
brew install pyenv
brew install pyenv-virtualenv
brew install pyenv-virtualenvwrapper
pyenv install 2.7.14
pyenv install 3.6.5
brew install elixir
brew install nvm
brew install yarn
brew install r
brew install pandoc
brew install grip
brew install postgresql
brew install clisp

