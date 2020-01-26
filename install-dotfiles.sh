 #!/bin/sh
 set -e
 
 REMOTE="https://github.com/LazyMechanic/configs.git"
 LOCAL="~/configs"
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
    
    git clone "$REMOTE" "$LOCAL" || {
		error "git clone of '$REMOTE' repo failed"
		exit 1
    }
}


function setup_dotfiles() {
    dotfiles=( $(ls -a "$DOTFILES_DIR" | grep "\.[a-zA-Z0-9]+") )
    
    for f in $remote_dotfiles
    do
        if [[ -f "~/$f" ]];
        then
            mv "~/$f" "~/$f.backup"
        fi
        
        cp "$DOTFILES_DIR/$f" ~/
    done
}

function setup_custom_theme() {
    if [[ -n "$ZSH_CUSTOM" ]];
    then
        cp "$CUSTOM_THEME_DIR" "$ZSH_CUSTOM/themes/"
    else
        error "oh-my-zsh custom themes directory not found"
        return
    fi
}

function init_shell() {
    zsh="which zsh"
    if ! command_exists "$zsh";
    then
        error "zsh is not installed"
        return
    fi
    
    $zsh -l
    source ~/.zshrc
}

function main() {
    clone_project
    setup_color
    setup_dotfiles
    setup_custom_theme
    init_shell
}

main
