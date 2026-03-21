# --- Begin Oh My Zsh initialization ---
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

plugins=(
  copybuffer
  copyfile
  copypath
  docker
  git
  gitignore
  golang
  kubectl
  node
  npm
  uv
  yarn
  zsh-interactive-cd
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
# --- End Oh My Zsh initialization ---

# Brew
eval $(/opt/homebrew/bin/brew shellenv)

# --- Locale Settings ---
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# --- Android Development ---
# export ANDROID_HOME="$HOME/Library/Android/sdk"
# export ANDROID_NDK_HOME="$ANDROID_HOME/ndk"

# --- Go Development ---
export GOPATH="$HOME/Developments/go"
export GOBIN="$GOPATH/bin"

# --- PATH Configuration ---
# Note: We append to the existing PATH ($PATH) to preserve system paths.
# Order matters: The beginning of the list takes priority.
export PATH="$GOBIN:$PATH"
# export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# --- Custom Workflow & Cleanup Aliases ---
# Added by setup.sh script from your custom scripts collection.
alias startday="$HOME/Scripts/start-day.sh"
alias cleanupprojects="$HOME/Scripts/cleanup-projects.sh"
alias cleanupdocker="$HOME/Scripts/cleanup-docker.sh"
alias cleanupmobile="$HOME/Scripts/cleanup-mobile.sh"
alias cleanupcaches="$HOME/Scripts/cleanup-caches.sh"
# --- End of Custom Aliases ---

# iTerm2 Shell Integration
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh" || true

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use  # This loads nvm
[[ -r $NVM_DIR/bash_completion ]] && \. $NVM_DIR/bash_completion

# Fastfetch
fastfetch

