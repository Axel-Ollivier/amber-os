# Amber OS
PACKAGES := ghostty zsh starship bat fastfetch conky rofi gtk cinnamon-applets

.DEFAULT_GOAL := help
.PHONY: help install stow theme icons activate greeter

help: ## List available targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sed -E 's/:.*## / - /' | sort

install: stow theme icons activate ## Full install (dotfiles + theme + icons, applied)
	@echo "Amber installed. Restart Cinnamon (or log out/in) to apply everywhere."

stow: ## Symlink dotfiles into $HOME
	stow $(PACKAGES)

theme: ## Build the Amber Cinnamon/GTK theme
	theme/build-amber-theme.sh

icons: ## Build the Amber-Icons monochrome icon set
	icons/build-amber-icons.sh

activate: ## Apply theme and icons via gsettings
	gsettings set org.cinnamon.theme name 'Amber'
	gsettings set org.cinnamon.desktop.interface gtk-theme 'Amber'
	gsettings set org.cinnamon.desktop.wm.preferences theme 'Amber'
	gsettings set org.cinnamon.desktop.interface icon-theme 'Amber-Icons'

greeter: ## Install the amber LightDM lock screen (needs sudo)
	sudo bash lightdm/setup-greeter.sh
