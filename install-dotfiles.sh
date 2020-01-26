#!/bin/sh
set -e

REMOTE="https://github.com/LazyMechanic/configs.git"
LOCAL="$HOME/lazymechanic.configs"
DOTFILES_DIR="$LOCAL/dotfiles"
CUSTOM_THEME_DIR="$DOTFILES_DIR/lazymechanic"
 
function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

function setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
        RESET=""
	fi
}

function clone_project() {
    if ! command_exists git;
    then
        error "git is not installed"
		exit 1
    fi
    
    if [[ -d "$LOCAL" ]];
    then
        rm -rf "$LOCAL"
    fi
    
    git clone \
        -c core.eol=lf \
        -c core.autocrlf=false \
        "$REMOTE" "$LOCAL" || {
		error "git clone of '$REMOTE' repo failed"
		exit 1
    }
}


function setup_dotfiles() {
    echo "Start setup dotfiles..."
    
    dotfiles=$(ls -a "$DOTFILES_DIR" | grep "\.[a-zA-Z0-9]")
    echo "File list which will be installed:"
    echo "$dotfiles"
    
    for f in $dotfiles
    do
        if [[ -f "$HOME/$f" ]];
        then
            mv "$HOME/$f" "$HOME/$f.backup"
        fi
       
        cp "$DOTFILES_DIR/$f" "$HOME/$f"
    done
    
    echo "Done!"
}

function setup_custom_theme() {
    echo "Start setup zsh custom theme..."
    
    if [[ -n "$ZSH_CUSTOM" ]];
    then
        cp "$CUSTOM_THEME_DIR" "$ZSH_CUSTOM/themes/"
    else
        error "oh-my-zsh custom themes directory not found"
        return
    fi
    
    echo "Done!"
}

function init_shell() {
    echo "Init zsh..."
    
    if [[ -z "$ZSH_VERSION" ]];
    then
        local _zsh="$(which zsh)"
        if ! command_exists "$_zsh";
        then
            error "zsh is not installed"
            exit 1
        fi
        
        $_zsh -l
    fi
    
    echo "Done!"
    source ~/.zshrc
}

function main() {
    echo "Dotfiles directory:         $DOTFILES_DIR"
    echo "Zsh custom theme directory: $CUSTOM_THEME_DIR"
    echo ""
    
    clone_project
    setup_color
    setup_dotfiles
    init_shell
    setup_custom_theme
}

main
