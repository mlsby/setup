# Setup script for Mac

On a new computer, run: 
```zsh
curl -s https://raw.githubusercontent.com/mlsby/setup/main/Makefile | make -f -
```

## Cursor setup 
Cursor is installed with the script above, however, the extensions are not. To install them first install the cursor cli by opening cursor and running `Shell Command: Install 'cursor' command` by searching (F1). 
Next run the following command: 
```zsh
curl -s https://raw.githubusercontent.com/mlsby/setup/main/Makefile | make -f - extensions
```
