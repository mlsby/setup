.PHONY: all xcode homebrew apps git pyenv ohmyzsh plugins termium extensions

all: xcode homebrew apps git pyenv ohmyzsh plugins termium extensions

xcode:
	@echo "Checking Xcode Command Line Tools..."
	@if ! xcode-select -p >/dev/null 2>&1; then \
		echo "Installing Xcode Command Line Tools..."; \
		xcode-select --install; \
		while ! xcode-select -p >/dev/null 2>&1; do sleep 5; done; \
	else \
		echo "Xcode Command Line Tools already installed."; \
	fi

homebrew:
	@echo "Checking Homebrew..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		if ! grep -q "/opt/homebrew/bin/brew shellenv" ~/.zshrc; then \
			echo "Adding brew to zshrc"; \
			echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc; \
		fi; \
		eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	else \
		echo "Homebrew already installed."; \
	fi
	@echo "Updating Homebrew..."
	@brew update

apps: homebrew
	@echo "Installing applications..."
	@brew install --cask google-chrome spotify cursor 1password slack docker scroll-reverser || true
	@brew install git htop || true

git: homebrew
	@echo "Setting up Git..."
	@git config --global user.name "Lucas Molsby"
	@git config --global user.email "lucas.molsby@gmail.com"
	@git config --global push.autoSetupRemote true
	@git config --global pull.rebase false
	@echo "Generating SSH key..."
	@if [ ! -f "$$HOME/.ssh/id_ed25519.pub" ]; then \
		ssh-keygen -t ed25519 -C "lucas.molsby@gmail.com" -N "" -f "$$HOME/.ssh/id_ed25519"; \
	else \
		echo "SSH key already exists."; \
	fi
	@echo "Please add the following public key to your GitHub account:"
	@cat "$$HOME/.ssh/id_ed25519.pub"
	@echo "Press Enter once you have added the key to GitHub..."
	@read

pyenv: homebrew
	@echo "Setting up pyenv..."
	@if ! command -v pyenv >/dev/null 2>&1; then \
		brew install pyenv; \
		echo 'export PYENV_ROOT="$$HOME/.pyenv"' >> ~/.zshrc; \
		echo 'export PATH="$$PYENV_ROOT/bin:$$PATH"' >> ~/.zshrc; \
		echo 'eval "$$(pyenv init --path)"' >> ~/.zshrc; \
	else \
		echo "pyenv already installed."; \
	fi
	@export PYENV_ROOT="$$HOME/.pyenv"; \
	export PATH="$$PYENV_ROOT/bin:$$PATH"; \
	eval "$$(pyenv init -)"; \
	PYENV_VERSION=$$(pyenv latest --known 3); \
	pyenv install $$PYENV_VERSION || true; \
	pyenv global $$PYENV_VERSION

ohmyzsh:
	@echo "Installing Oh My Zsh..."
	@if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		sh -c "$$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	else \
		echo "Oh My Zsh already installed."; \
	fi

plugins: ohmyzsh
	@echo "Installing Oh My Zsh plugins..."
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then \
		git clone git@github.com:zsh-users/zsh-syntax-highlighting.git "$$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"; \
	fi
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/plugins/you-should-use" ]; then \
		git clone git@github.com:MichaelAquilina/zsh-you-should-use.git "$$HOME/.oh-my-zsh/custom/plugins/you-should-use"; \
	fi
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/plugins/zsh-bat" ]; then \
		git clone git@github.com:fdellwing/zsh-bat.git "$$HOME/.oh-my-zsh/custom/plugins/zsh-bat"; \
	fi
	@if grep -q "plugins=(" ~/.zshrc; then \
		sed -i '' 's/plugins=(.*)/plugins=(git zsh-syntax-highlighting you-should-use zsh-bat)/' ~/.zshrc; \
	else \
		echo 'plugins=(git zsh-syntax-highlighting you-should-use zsh-bat)' >> ~/.zshrc; \
	fi

termium:
	@echo "Installing Termium..."
	@curl -L https://github.com/Exafunction/codeium/releases/download/termium-v0.2.0/install.sh | bash
	@echo "\033[1mTermium installed successfully!\033[0m"
	@echo "Please follow the instructions above to finalize Termium installation."

extensions:
	@echo "Installing Cursor extensions..."
	@if ! command -v cursor >/dev/null 2>&1; then \
		echo "Error: Cursor not found. Please install Cursor first using 'make apps'"; \
		exit 1; \
	fi
	@curl -s https://raw.githubusercontent.com/mlsby/setup/main/cursor/extensions.txt | while read extension; do \
		if ! cursor --list-extensions | grep -q "$$extension"; then \
			echo "Installing $$extension..."; \
			cursor --install-extension "$$extension"; \
		else \
			echo "$$extension already installed."; \
		fi \
	done
