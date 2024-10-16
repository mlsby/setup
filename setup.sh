#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting setup..."

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Xcode Command Line Tools if not installed
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  # Wait until the installation is done
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
else
  echo "Xcode Command Line Tools already installed."
fi

# Install Homebrew if not installed
if ! command_exists brew; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to the PATH
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

echo "Updating Homebrew..."
brew update

# Install applications using Homebrew Cask
echo "Installing applications..."

apps=(
  google-chrome
  spotify
  cursor
  1password
  slack
  docker
  git
)

for app in "${apps[@]}"; do
  brew install --cask "$app" || echo "$app is already installed."
done

# Install pyenv
if ! command_exists pyenv; then
  echo "Installing pyenv..."
  brew install pyenv
  # Add pyenv init to shell
  if [[ -f ~/.zshrc ]]; then
    echo -e '\n# Pyenv Initialization' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
  elif [[ -f ~/.bash_profile ]]; then
    echo -e '\n# Pyenv Initialization' >> ~/.bash_profile
    echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
  fi
else
  echo "pyenv already installed."
fi

# Install Oh My Zsh and plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh is already installed."
fi

# Install Oh My Zsh plugins
echo "Installing Oh My Zsh plugins..."

# Install zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
else
  echo "zsh-syntax-highlighting is already installed."
fi

# Install you-should-use
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use" ]; then
  git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use"
else
  echo "you-should-use is already installed."
fi

# Install zsh-bat
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-bat" ]; then
  git clone https://github.com/jeffreytse/zsh-bat.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-bat"
else
  echo "zsh-bat is already installed."
fi

# Update .zshrc to use the specified plugins
echo "Updating .zshrc with plugins..."
if grep -q "plugins=(" ~/.zshrc; then
  sed -i '' 's/plugins=(.*)/plugins=(git zsh-syntax-highlighting you-should-use zsh-bat)/' ~/.zshrc
else
  echo "plugins=(git zsh-syntax-highlighting you-should-use zsh-bat)" >> ~/.zshrc
fi

# Add Cursor function to .zshrc
echo "Adding Cursor function to .zshrc..."
cursor_app_path="$HOME/Applications/Cursor.App"
if ! grep -q "function cursor" ~/.zshrc; then
  echo "function cursor {
      $cursor_app_path \$@
  }" >> ~/.zshrc
fi

# Source the .zshrc to apply the changes
source ~/.zshrc

# Create repo directory and add .vscode/extensions.json
echo "Setting up recommended Cursor extensions..."
mkdir -p ~/repo/.vscode
cat <<EOL > ~/repo/.vscode/extensions.json
{
  "recommendations": [
    "matangover.mypy",
    "ms-python.pylint",
    "charliermarsh.ruff",
    "ms-python.python",
    "ms-python.debugpy"
  ]
}
EOL

# Install Termium
echo "Installing Termium (Codeium terminal client)..."
curl -L https://github.com/Exafunction/codeium/releases/download/termium-v0.2.0/install.sh | bash
echo -e "\n\033[1mTermium installed successfully!\033[0m"
echo "Please follow the instructions above to finalize Termium installation."

# Prompt to open Cursor for recommended extensions
echo -e "\nWould you like to open Cursor to install recommended extensions? (y/n)"
read -r open_cursor
if [[ "$open_cursor" == "y" || "$open_cursor" == "Y" ]]; then
  echo "Opening repo directory..."
  open ~/repo
else
  echo "You can manually open Cursor later to install the recommended extensions."
fi

echo "Setup complete!"