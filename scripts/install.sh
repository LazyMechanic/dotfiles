#!/usr/bin/env bash

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

######################## VARIABLES END ########################


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
            info "Try git pull repo..."
            
            old_dir = $(pwd)
            cd "$_LOCAL_REPO"
            git pull
            if [[ ! $? -eq 0 ]];
            then
                error "Failed"
                exit 1
            fi
            cd "$old_dir"

            ok "Done!"
            return
        fi
    fi
    
    git clone \
        -c core.eol=lf \
        -c core.autocrlf=false \
        "$_REMOTE_REPO" "$_LOCAL_REPO" 
    if [[ ! $? -eq 0 ]];
    then
        error "Failed"
        exit 1
    fi
    
    ok "Done!"
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
    
    # If no has argument
    if [[ $# != 1 ]];
    then
        error "invalid argument, 1st argument must be \$ZSH_CUSTOM"
    fi

    _ZSH_CUSTOM="$1"

    clone_project
    bash -c "$_LOCAL_REPO/scripts/install-impl.sh" "" $1
    remove_project
}

main $@