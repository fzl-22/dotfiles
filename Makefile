# Makefile for managing dotfiles

SHELL := /bin/bash
.PHONY: help add install sync backup

# Variables
REPO_DIR := $(shell pwd)
REPO_HOME := $(REPO_DIR)/home
BACKUP_DIR := $(REPO_DIR)/backup/$(shell date +%Y%m%d_%H%M%S)

help: ## Show this help message
	@echo "Dotfiles Management Utility"
	@echo ""
	@echo "Usage: make [target] [FILE=/path/to/file]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

$(REPO_HOME):
	@mkdir -p $(REPO_HOME)

add: $(REPO_HOME) ## Add a dotfile or directory to the repository (usage: make add FILE=~/.bashrc)
ifndef FILE
	$(error FILE is undefined. Usage: make add FILE=~/.bashrc)
endif
	@echo "Adding $(FILE) to repository..."
	@filepath="$(FILE)"; \
	filepath=$$(echo "$$filepath" | sed "s|^~/|$(HOME)/|"); \
	if [ "$$filepath" = "~" ]; then filepath="$(HOME)"; fi; \
	if [ ! -e "$$filepath" ]; then \
		echo "Error: $$filepath does not exist."; \
		exit 1; \
	fi; \
	filepath=$$(realpath "$$filepath"); \
	homedir=$$(realpath "$(HOME)"); \
	if [[ "$$filepath" != $$homedir/* ]]; then \
		echo "Error: File must be within your home directory ($$homedir)."; \
		exit 1; \
	fi; \
	relpath=$${filepath#$$homedir/}; \
	target="$(REPO_HOME)/$$relpath"; \
	rm -rf "$$target"; \
	mkdir -p "$$(dirname "$$target")"; \
	cp -a "$$filepath" "$$target"; \
	echo "Successfully added $$filepath to $$target"

install: ## Install dotfiles from the repository to $HOME (creates symlinks)
	@echo "Installing dotfiles to $(HOME)..."
	@if [ ! -d "$(REPO_HOME)" ]; then \
		echo "No dotfiles found in $(REPO_HOME)."; \
		exit 1; \
	fi
	@find "$(REPO_HOME)" -type d -name ".git" -prune -o -type f ! -name "*.zwc" ! -name "*.old" ! -name "*.mdb" ! -name ".DS_Store" -print | while read -r file; do \
		relpath=$${file#"$(REPO_HOME)"/}; \
		target="$(HOME)/$$relpath"; \
		if [ -e "$$target" ] && [ ! -L "$$target" ]; then \
			echo "Backing up existing $$target to $(BACKUP_DIR)/home/$$relpath"; \
			mkdir -p "$(BACKUP_DIR)/home/$$(dirname "$$relpath")"; \
			mv "$$target" "$(BACKUP_DIR)/home/$$relpath"; \
		fi; \
		mkdir -p "$$(dirname "$$target")"; \
		echo "Symlinking $$target -> $$file"; \
		ln -sf "$$file" "$$target"; \
	done
	@echo "Installation complete!"

sync: ## Sync tracked dotfiles from $HOME to the repository
	@echo "Syncing dotfiles from $(HOME) to repository..."
	@if [ ! -d "$(REPO_HOME)" ]; then \
		echo "No dotfiles found in $(REPO_HOME)."; \
		exit 1; \
	fi
	@find "$(REPO_HOME)" -type d -name ".git" -prune -o -type f ! -name "*.zwc" ! -name "*.old" ! -name "*.mdb" ! -name ".DS_Store" -print | while read -r file; do \
		relpath=$${file#"$(REPO_HOME)"/}; \
		source="$(HOME)/$$relpath"; \
		if [ -e "$$source" ]; then \
			if ! cmp -s "$$source" "$$file"; then \
				echo "Updating $$relpath in repository..."; \
				cp -a "$$source" "$$file"; \
			fi; \
		else \
			echo "Warning: $$source no longer exists in home directory."; \
		fi; \
	done
	@echo "Sync complete!"

backup: ## Create a backup of currently installed dotfiles that are tracked in this repo
	@echo "Creating backup in $(BACKUP_DIR)..."
	@if [ ! -d "$(REPO_HOME)" ]; then \
		echo "No dotfiles found in $(REPO_HOME)."; \
		exit 1; \
	fi
	@mkdir -p "$(BACKUP_DIR)"
	@find "$(REPO_HOME)" -type d -name ".git" -prune -o -type f ! -name "*.zwc" ! -name "*.old" ! -name "*.mdb" ! -name ".DS_Store" -print | while read -r file; do \
		relpath=$${file#"$(REPO_HOME)"/}; \
		target="$(HOME)/$$relpath"; \
		if [ -e "$$target" ] || [ -L "$$target" ]; then \
			echo "Backing up $$target"; \
			mkdir -p "$(BACKUP_DIR)/home/$$(dirname "$$relpath")"; \
			cp -Lp "$$target" "$(BACKUP_DIR)/home/$$relpath"; \
		fi; \
	done
	@if [ ! -d "$(BACKUP_DIR)/home" ] || [ -z "$$(ls -A "$(BACKUP_DIR)/home")" ]; then \
		rm -rf "$(BACKUP_DIR)" 2>/dev/null || true; \
		echo "No existing files to backup."; \
	else \
		echo "Backup complete!"; \
	fi
