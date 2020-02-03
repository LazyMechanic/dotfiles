#!/bin/bash
set -e

REMOTE="https://github.com/LazyMechanic/configs.git"
LOCAL="$HOME/lazymechanic.configs"
DOTFILES_DIR="$LOCAL/dotfiles"
FONTS_DIR="$LOCAL/fonts"
CUSTOM_THEME_DIR="$DOTFILES_DIR/lazymechanic"
DEFAULT_THEME="robbyrussell"
THEME="$DEFAULT_THEME"
 
yes_no() {
    if [[ $# -eq 0 ]];
    then
        error "invalid argument for prompt, \$# is 0"
        exit 1
    fi
    
    text="$1"
    answer_prompt=""
    default_answer=""
    
    if [[ -n $2 ]]
    then
        case $2 in
            [Yy]* ) 
                answer_prompt="[Y/n]"
                default_answer="y"
                ;;
            [Nn]* ) 
                answer_prompt="[y/N]"
                default_answer="n"
                ;;
            * ) 
                error "invalid argument for prompt, \$2 must be [Y,y,N,n]"
                exit 1
                ;;
        esac
    fi
    
    while true; do
        read -p "$text $answer_prompt " yn
        case $yn in
            [Yy]* ) 
                echo "y"
                return
                ;;
            [Nn]* ) 
                echo "n"
                return
                ;;
            * )
                if [[ -z $yn ]];
                then
                    echo "$default_answer"
                    return
                fi
                ;;
        esac
    done
}
 
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

error() {
    echo ${RED}"ERROR: $@"${RESET} >&2
}

setup_color() {
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

clone_project() {
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


setup_dotfiles() {
    echo "Start setup dotfiles..."
    
    dotfiles=$(ls -a "$DOTFILES_DIR" | grep "\.[a-zA-Z0-9]")
    echo "Dotfiles to be installed:"
    for f in $dotfiles
    do
        echo " - $f"
    done
    
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

select_theme() {
    PS3='Please enter theme: '
    options=("LazyMechanic" "Powerlevel10k (lean)" "Powerlevel10k (classic)" "Powerlevel10k (rainbow)" "Default (robbyrussell)")
    select opt in "${options[@]}"
    do
        case $opt in
            "LazyMechanic")
                echo "lazymechanic"
                return
                ;;
            "Powerlevel10k (lean)")
                echo "p10k_lean"
                return
                ;;
            "Powerlevel10k (classic)")
                echo "p10k_classic"
                return
                ;;
            "Powerlevel10k (rainbow)")
                echo "p10k_rainbow"
                return
                ;;
            "Default (robbyrussell)")
                echo "default"
                return
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

install_p10k() {
    p10k_dir="$ZSH_CUSTOM/themes/powerlevel10k"
    if [[ -d "$p10k_dir" ]];
    then
        answer=$(yes_no "Powerlevel10k directory already exists, delete dir and clone repo?" "y")
        if [ "$answer" == "y" ];
        then
            echo "Remove Powerlevel10k directory..."
            rm -rf "$p10k_dir"
            echo "Done!"
        else
            echo "Do nothing"
            return
        fi
    fi

    echo "Clone Powerlevel10k repo..."
    git clone \
        --depth=1 \
        https://github.com/romkatv/powerlevel10k.git $p10k_dir || {
        error "git clone of 'https://github.com/romkatv/powerlevel10k.git' repo failed, try install manually"
        exit 1
    }
}

copy_p10k_config() {
    if [[ -z $1 ]];
    then
        error "invalid argument for copy_p10k_config()"
        exit 1
    fi
    
    f=$1
    
    cp "$HOME/$f" "$HOME/.p10k.zsh"
}

setup_theme() {
    echo "Start setup zsh theme..."
    
    theme=$(select_theme)
    case $theme in
        "lazymechanic")
            cp -r "$CUSTOM_THEME_DIR" "$ZSH_CUSTOM/themes/"
            THEME="lazymechanic/lazymechanic"
            ;;
        "p10k_lean")
            install_p10k
            THEME="powerlevel10k/powerlevel10k"
            copy_p10k_config ".p10k.zsh.lean"
            ;;
        "p10k_classic")
            install_p10k
            THEME="powerlevel10k/powerlevel10k"
            copy_p10k_config ".p10k.zsh.classic"
            ;;
        "p10k_rainbow")
            install_p10k
            THEME="powerlevel10k/powerlevel10k"
            copy_p10k_config ".p10k.zsh.rainbow"
            ;;
        "Default")
            THEME="$DEFAULT_THEME"
            ;;
    esac
    
    # Change theme in .zshrc
    if ! command_exists sed;
    then
        error "sed is not installed"
        exit 1
    fi
    
    sed -i -E "s~ZSH_THEME=\"[a-zA-Z0-9\/]*\"~ZSH_THEME=\"$THEME\"~" "$HOME/.zshrc"
    
    echo "Done!"
}

check_oh_my_zsh() {  
    if [[ -z "$ZSH_CUSTOM" ]];
    then
        error "oh-my-zsh custom themes directory not found"
        exit 1
    fi
}

install_fonts() {
    echo "Start install fonts..."
    
    # Check if need setup custom fonts
    answer=$(yes_no "Install custom fonts?" "y")
    if [ "$answer" == "y" ];
    then
        local_fonts_dir="$HOME/.local/share/fonts"
        mkdir -p "$local_fonts_dir"
        
        fonts=$(ls "$FONTS_DIR")
        echo "Font files to be installed:"
        for f in $fonts
        do
            echo " - $f"
        done
        
        for f in $fonts
        do
            cp "$FONTS_DIR/$f" "$local_fonts_dir/$f"
        done
        echo "Done!"
    else
        echo "Do nothing"
        return
    fi
}

remove_project() {
    echo "Start remove project..."
    
    answer=$(yes_no "Remove cloning project?" "y")
    if [ "$answer" == "y" ];
    then
        rm -rf "$LOCAL"
        echo "Done!"
    else
        echo "Do nothing"
        return
    fi
}

main() {
    setup_color
    
    # Expect 1 argument
    if [[ $# != 1 ]];
    then
        error "invalid argument, 1st argument must be \$ZSH_CUSTOM"
        exit 1
    fi
    
    ZSH_CUSTOM="$1"
    
    clone_project
    check_oh_my_zsh
    setup_dotfiles
    setup_theme
    install_fonts
    remove_project
    
    source ~/.bashrc
}

main $@
