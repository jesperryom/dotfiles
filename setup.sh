#!/bin/bash
trap 'ret=$?; test $ret -ne 0 && printf "Failed!\n" >&2; exit $ret' EXIT
set -e

read -p 'Is this your personal computer? [y/n] ' personal

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Disable Gatekeeper if active
if spctl --status > /dev/null; then
  echo "Gatekeeper enabled, enter password to disable..."
  sudo spctl --master-disable
  echo "Gatekeeper disabled."
fi


echo -n "Checking command line tools installation..."
if ! type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
   test -d "${xpath}" && test -x "${xpath}"; then
   echo " Not installed. Install and run script again."
   xcode-select --install
   EXIT
fi
echo " OK!"

if ! command -v brew >/dev/null; then
  echo "Installing Homebrew..."
  curl -fsS \
    'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
    export PATH="/usr/local/bin:$PATH"
fi

echo -n "Looking for missing brew packages... "
if ! brew bundle check --file="$script_path/homebrew/brewfile" >/dev/null; then
  echo "Dependencies missing! Brewing..."
  brew bundle install --file="$script_path/homebrew/brewfile" --force
  brew services start yabai
  brew services start skhd
fi
if [ "$personal" == "y" ]; then
  if ! brew bundle check --file="$script_path/homebrew/personal" >/dev/null; then
    echo "More dependencies missing! Brewing some more..."
    brew bundle install --file="$script_path/homebrew/personal" --force
  fi
fi
echo "Done!"

echo -n "Installing fzf... "
echo y | $(brew --prefix)/opt/fzf/install >/dev/null && echo "Done!"

echo -n "Installing pip packages... "
pip3 install --upgrade pynvim dotbot pip pip-review >/dev/null && echo "Done!"
dotbot -c "$script_path/install.conf.yaml" >/dev/null

if ! cd ~/.config/nvim/pack/minpac/opt/minpac >/dev/null; then
  echo -n "Pulling minpac repo... "
  mkdir -p ~/.config/nvim/pack/minpac/opt/minpack
  git clone https://github.com/k-takata/minpac.git ~/.config/nvim/pack/minpac/opt/minpac
  echo "Done!"
fi

echo -n "Pulling base16-shell repo... "
if ! cd ~/.config/base16-shell >/dev/null; then
  git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
  echo "Done!"
else
  cd ~/.config/base16-shell && git pull
fi

echo -n "Pulling base16-kitty repo... "
if ! cd ~/.config/base16-kitty >/dev/null; then
  git clone https://github.com/kdrag0n/base16-kitty.git ~/.config/base16-kitty
  echo "Done!"
else
  cd ~/.config/base16-kitty && git pull
fi

defaults write com.matryer.BitBar pluginsDirectory "~/.config/bitbar"
defaults write com.matryer.BitBar userConfigDisabled -bool true

echo -n "Installing node... "
fnm install 10 >/dev/null && fnm use 10 >/dev/null

echo -n "Installing global NPM packages... "
npm install --loglevel silent --no-progress -g \
  $(cat "$script_path/npm-global-packages" | tr '\n' ' ') >/dev/null
echo "Done!"

echo "Installation finished!"

if ! grep -q $(which fish) "/etc/shells"; then
  sudo sh -c "echo $(which fish) >> /etc/shells"
  chsh -s $(which fish)
fi
