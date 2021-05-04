######################## UTILS BEGIN ########################

setup_color() {
    # Only use colors if connected to a terminal
    if [ -t 1 ]; then
        RED=$(printf '\033[91m')
        GREEN=$(printf '\033[92m')
        YELLOW=$(printf '\033[93m')
        BLUE=$(printf '\033[94m')
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

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

check_command() {
    if ! command_exists $@;
    then
        error "$@ is not installed"
        exit 1
    fi
}

error() {
    echo "${RED}[ERRO]${RESET}: $@" >&2
}

warn() {
    echo "${YELLOW}[WARN]${RESET}: $@" >&1
}

info() {
    echo "${BLUE}[INFO]${RESET}: $@" >&1
}

ok() {
    echo "${GREEN}[ OK ]${RESET}: $@" >&1
}

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

######################## UTILS END ########################

######################## VARIABLES BEGIN ########################

_REMOTE_REPO="https://github.com/LazyMechanic/configs.git"
_LOCAL_REPO="lazymechanic.configs"
_ZSH_CUSTOM=""
_FONTS_DIR="$_LOCAL_REPO/fonts"
_DOTFILES_DIR="$_LOCAL_REPO/dotfiles"

_INSTALL_ZSH_THEME_SCRIPT="$_LOCAL_REPO/scripts/install-zsh-theme.py"

######################## VARIABLES END ########################

check_oh_my_zsh() {  
    if [[ -z "$_ZSH_CUSTOM" ]];
    then
        error "Oh-my-zsh custom themes directory is empty"
        exit 1
    fi

    # if [[ ! -d "$_ZSH_CUSTOM" ]];
    # then
    #     error "Oh-my-zsh custom themes directory not exists"
    #     exit 1
    # fi
}

clone_project() {
    info "Start clone project..."
    
    if [[ -d "$_LOCAL_REPO" ]];
    then
        answer=$(yes_no "'$_LOCAL_REPO' already exists, remove dir and clone again?" "y")
        if [ "$answer" == "y" ];
        then
            info "Remove '$_LOCAL_REPO' directory..."
            rm -rf "$_LOCAL_REPO"
            ok "Done!"
        else
            ok "Do nothing"
            return
        fi
    fi
    
    git clone \
        -c core.eol=lf \
        -c core.autocrlf=false \
        "$_REMOTE_REPO" "$_LOCAL_REPO" 
    if [[ ! $? -eq 0 ]];
    then
        error "git clone of '$_REMOTE_REPO' repo failed"
        exit 1
    fi
    
    ok "Done!"
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
                echo "p10klean"
                return
                ;;
            "Powerlevel10k (classic)")
                echo "p10kclassic"
                return
                ;;
            "Powerlevel10k (rainbow)")
                echo "p10krainbow"
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

install_zsh_theme() {
    info "Start install zsh theme..."
    
    theme=$(select_theme)
    python3 \
        "$_INSTALL_ZSH_THEME_SCRIPT" \
        --zsh-custom "$_ZSH_CUSTOM" \
        "$theme" 
    if [[ ! $? -eq 0 ]];
    then
        error "Install zsh theme failed"
        exit 1
    fi
    
    ok "Done!"
    info "Start zsh session and call 'source ~/.zshrc'"
}

install_fonts() {
    info "Start install fonts..."
    
    # Check if need setup custom fonts
    answer=$(yes_no "Install custom fonts?" "y")
    if [ "$answer" == "y" ];
    then
        local_fonts_dir="$HOME/.local/share/fonts"
        mkdir -p "$local_fonts_dir"
        
        fonts=$(ls "$_FONTS_DIR")
        info "Font files to be installed:"
        for f in $fonts
        do
            echo " - $f"
        done
        
        cp "$_FONTS_DIR/." "$local_fonts_dir/"

        ok "Done!"
    else
        ok "Do nothing"
        return
    fi
}

install_dotfiles() {
    info "Install dependencies"
    pacman -Syu
    pacman -S                       \
        zsh                         \
        bat                         \
        exa                         \
        feh                         \
        yad                         \
        rofi                        \
        dmenu                       \
        dunst                       \
        picom                       \
        polybar                     \
        xdotool                     \
        autorandr                   \
        playerctl                   \
        lxappearance-gtk3           \
        aur/i3-gaps-next-git        \
        extra/xorg-xbacklight       \
        aur/zsh-autosuggestions-git
    ok "Done!"

    info "Install oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    ok "Done!"

    info "Copy dotfiles"

    local_dfiles_dir="$HOME"       
    cp -r "$_DOTFILES_DIR/." "$local_dfiles_dir/"

    ok "Done!"

    info "Don\'t forget to change shell by \'chsh -s $(which zsh)\'"

    return
}

select_action() {
    PS3='Please enter action: '
    options=("Install zsh theme" "Install fonts" "Install dotfiles" "Exit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Install zsh theme")
                echo "zsh"
                return
                ;;
            "Install fonts")
                echo "fonts"
                return
                ;;
            "Install dotfiles")
                echo "dotfiles"
                return
                ;;
            "Exit")
                echo "exit"
                return
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

main_loop() {
    while true
    do
        action=$(select_action)
        case $action in
            "zsh")
                install_zsh_theme
                ;;
            "fonts")
                install_fonts
                ;;
            "dotfiles")
                sudo sh -c "$(declare -f install_dotfiles); install_dotfiles"
                ;;
            "exit")
                return
                ;;
        esac
    done
}

remove_project() {
    answer=$(yes_no "Remove cloning project?" "y")
    if [ "$answer" == "y" ];
    then
        info "Start remove project..."
        rm -rf "$_LOCAL_REPO"
        ok "Done!"
    else
        ok "Do nothing"
        return
    fi
}

main() {
    setup_color

    # Check commands
    check_command git
    check_command sed
    check_command source
    check_command python3
    check_command pacman
    
    # If no has argument
    if [[ $# != 1 ]];
    then
        error "invalid argument, 1st argument must be \$ZSH_CUSTOM"
    fi

    _ZSH_CUSTOM="$1"

    # Check if zsh custom dir exists
    check_oh_my_zsh

    clone_project
    main_loop
    remove_project
}

main $@