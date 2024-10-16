#!/bin/zsh

echo "Installing extensions..."

# Download the cursor/extensions.txt file from this repo
curl -O https://raw.githubusercontent.com/mlsby/setup/main/cursor/extensions.txt

# Check if cursor is installed by attempting to run cursor -v
if [ ! -x "$(command -v cursor)" ]; then
  echo "cursor command not found. Please install cursor by opening the app and running 'Shell Command: Install 'cursor' command' from the Command Palette (F1)."
  exit 1
fi


# Loop through the extensions in the file
while read -r line; do
  # Check if the extension is installed
  if ! cursor --list-extensions | grep -q "$line"; then
    # If not, install the extension using "cursor --install-extension <extension-name>"
    cursor --install-extension "$line"
  else
    echo "$line is already installed."
  fi
done < extensions.txt

# Remove the extensions.txt file
rm extensions.txt


