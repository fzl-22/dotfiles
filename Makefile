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
	@find "$(REPO_HOME)" -type f | while read -r file; do \
		relpath=$${file#"$(REPO_HOME)"/}; \
		target="$(HOME)/$$relpath"; \
		if [ -e "$$target" ] && [ ! -L "$$target" ]; then \
			echo "Backing up existing $$target to $(BACKUP_DIR)/$$relpath"; \
			mkdir -p "$(BACKUP_DIR)/$$(dirname "$$relpath")"; \
			mv "$$target" "$(BACKUP_DIR)/$$relpath"; \
		fi; \
		mkdir -p "$$(dirname "$$target")"; \
		echo "Symlinking $$target -> $$file"; \
		ln -sf "$$file" "$$target"; \
	done
	@echo "Installation complete!"

sync: ## Sync dotfiles with the remote repository (pull, commit, push)
	@echo "Syncing dotfiles with remote..."
	@git pull --rebase || echo "No remote or pull failed, continuing..."
	@git add .
	@if git diff --staged --quiet; then \
		echo "No changes to commit."; \
	else \
		git commit -m "chore: sync dotfiles $$(date +'%Y-%m-%d %H:%M:%S')"; \
		git push || echo "Push failed. Please check your remote configuration."; \
		echo "Successfully synced changes!"; \
	fi

backup: ## Create a backup of currently installed dotfiles that are tracked in this repo
	@echo "Creating backup in $(BACKUP_DIR)..."
	@if [ ! -d "$(REPO_HOME)" ]; then \
		echo "No dotfiles found in $(REPO_HOME)."; \
		exit 1; \
	fi
	@find "$(REPO_HOME)" -type f | while read -r file; do \
		relpath=$${file#"$(REPO_HOME)"/}; \
		target="$(HOME)/$$relpath"; \
		if [ -e "$$target" ] && [ ! -L "$$target" ]; then \
			mkdir -p "$(BACKUP_DIR)/$$(dirname "$$relpath")"; \
			cp -a "$$target" "$(BACKUP_DIR)/$$relpath"; \
		fi; \
	done
	@echo "Backup complete!"
