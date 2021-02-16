#!/usr/bin/env bash

DOTFILES="$(pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

export PATH="$DOTFILES/bin:$PATH"

# #######################################
# Print functions

title() {
    echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
    echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
    echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
    exit 1
}

warning() {
    echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
    echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
    echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

# #######################################
# Helper functions

get_linkables() {
    find -H "$DOTFILES" -maxdepth 3 -name '*.symlink'
}

create_symlink() {
    file=$1
    target=$2
    should_symlink=true

    if [ -e "$target" ]; then
        read -rn 1 -p "$(warning ~${target#$HOME}' already exists... Overwrite? [y/N] ')" overwrite
        echo -e # \n, next line
        if [[ $overwrite =~ ^([Yy])$ ]]; then
            rm -rf "$target"
            info "Removed $target"
        else
            should_symlink=false
        fi
    fi

    if $should_symlink; then
        info "Creating symlink for $target -> $file"
        ln -s "$file" "$target"
    fi
}

prompt_install() {
    default=y
    package=$1

    read -rn 1 -p "$(warning $package' is not installed. Would you like to install it? [Y/n] ')" install
    echo -e # \n, next line
    while [[ ! ${install:-$default} =~ ^([Yy])$ ]] && [[ ! ${install:-$default} =~ ^([Nn])$ ]] ; do
        read -rn 1 -p "$(error 'Wrong input. Would you like to install '$package'? [Y/n] ')" install
        echo -e # \n, next line
    done

    if [[ ${install:-$default} =~ ^([Yy])$ ]]; then
        info "Start the installation of $package"

        if [[ -x "$(command -v brew)" ]]; then
            brew install $1
        elif [[ -x "$(command -v apt-get)" ]]; then
            sudo apt-get install $1 -y
        elif [[ -x "$(command -v pkg)" ]]; then
            sudo pkg install $1
        elif [[ -x "$(command -v pacman)" ]]; then
            sudo pacman -S $1
        else
            warning "Cannot detect your package manager. Please install $package on your own and run this script again." 
        fi
    fi
} 

check_for_software() {
    # info "Checking if $1 is installed"
    if ! [[ -x "$(command -v $1)" ]]; then
        prompt_install $1
    else
        info "$1 is already installed"
    fi
}

# #######################################
# Setup functions

backup_setup() {
    title "Backing up symlinks"

    BACKUP_DIR=$HOME/dotfiles-backup

    if [[ ! -d "$BACKUP_DIR" ]]; then
        info "Creating backup directory at $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi

    for file in $(get_linkables); do
        filename=".$(basename "$file" '.symlink')"
        target="$HOME/$filename"
        if [ -f "$target" ]; then
            info "Backing up $filename"
            cp "$target" "$BACKUP_DIR"
        else
            warning "$filename does not exist at this location or is a symlink"
        fi
    done
}

setup_symlinks() {
    title "Creating symlinks"

    if [[ ! -e "$HOME/.dotfiles" ]]; then
        info "Adding symlink to dotfiles at $HOME/.dotfiles"
        ln -s "$DOTFILES" ~/.dotfiles
    fi

    for file in $(get_linkables); do
        target="$HOME/.$(basename "$file" '.symlink')"
        create_symlink $file $target
    done


    echo -e
    info "Installing configs to ~/.config"
    if [[ ! -d "$HOME/.config" ]]; then
        info "Creating ~/.config"
        mkdir -p "$HOME/.config"
    fi

    config_files=$(find "$DOTFILES/config" -maxdepth 1 -mindepth 1 2>/dev/null)
    for config in $config_files; do
        target="$HOME/.config/$(basename "$config")"
        create_symlink $config $target 
    done
}

setup_git() {
    title "Setting up Git"

    defaultName=$(git config user.name)
    defaultEmail=$(git config user.email)
    defaultGithub=$(git config github.user)
    defaultSigningkey=$(git config user.signingkey)
    defaultGpgsign=$(git config commit.gpgsign)

    read -rp "Name [$defaultName]: " name
    read -rp "Email [$defaultEmail]: " email
    read -rp "Github username [$defaultGithub]: " github
    read -rp "Signingkey [$defaultSigningkey]: " signingkey
    read -rp "GPG sign [$defaultGpgsign]: " gpgsign

    git config -f ~/.gitconfig.local user.name "${name:-$defaultName}"
    git config -f ~/.gitconfig.local user.email "${email:-$defaultEmail}"
    git config -f ~/.gitconfig.local github.user "${github:-$defaultGithub}"
    git config -f ~/.gitconfig.local user.signingkey "${signingkey:-$defaultSigningkey}"
    git config -f ~/.gitconfig.local commit.gpgsign "${gpgsign:-$defaultGpgsign}"

    if [[ "$(uname)" == "Darwin" ]]; then
        git config --global credential.helper "osxkeychain"
    else
        read -rn 1 -p "Save user and password to an unencrypted file to avoid writing? [y/N] " save
        if [[ $save =~ ^([Yy])$ ]]; then
            git config --global credential.helper "store"
        else
            git config --global credential.helper "cache --timeout 3600"
        fi
    fi
}

setup_shell() {
    title "Configuring shell"

    [[ -n "$(command -v brew)" ]] && zsh_path="$(brew --prefix)/bin/zsh" || zsh_path="$(which zsh)"
    if ! grep -q "$zsh_path" /etc/shells; then
        info "adding $zsh_path to /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    if [[ "$SHELL" != "$zsh_path" ]]; then
        if chsh -s "$zsh_path" ; then
            info "Default shell changed to $zsh_path"
        else
            warning "Cant't set the default shell to $zsh_path. Please fix this and change the default shell to zsh by yourself."
        fi
    fi
}

setup_zsh() {
    title "Setting up zsh"

    check_for_software zsh

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing oh-my-zsh"
        curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
    else
        info "oh-my-zsh is already installed"
    fi

    zsh_custom_path=$(eval echo ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom})
    
    if [[ ! -d "$zsh_custom_path/plugins/zsh-completions" ]]; then
        info "Installing zsh plugin zsh-completions"
        git clone https://github.com/zsh-users/zsh-completions $zsh_custom_path/plugins/zsh-completions
    else
        info "zsh-completions is already installed"
    fi

    if [[ ! -d "$zsh_custom_path/plugins/zsh-autosuggestions" ]]; then
        info "Installing zsh plugin zsh-autosuggestions"
        git clone https://github.com/zsh-users/zsh-autosuggestions $zsh_custom_path/plugins/zsh-autosuggestions
    else
        info "zsh-autosuggestions is already installed"
    fi

    if [[ ! -d "$zsh_custom_path/plugins/zsh-syntax-highlighting" ]]; then
        info "Installing zsh plugin zsh-syntax-highlighting"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $zsh_custom_path/plugins/zsh-syntax-highlighting
    else
        info "zsh-syntax-highlighting is already installed"
    fi
    
    if [[ ! -d "$zsh_custom_path/themes/powerlevel10k" ]]; then
        info "Installing zsh theme powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $zsh_custom_path/themes/powerlevel10k
    else
        info "powerlevel10k is already installed"
    fi
}

setup_homebrew() {
    title "Setting up Homebrew"

    if ! [[ -x "$(command -v brew)" ]]; then
        info "Homebrew is not installed, installing..."
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login

        if [[ "$(uname)" == "Linux" ]]; then
            test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
            test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            # test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
            test -r ~/.bashrc && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.bashrc
        fi
    fi

    brew analytics off

    brew bundle --file homebrew/Brewfile


    # install fzf
    if [[ ! -e "$HOME/.fzf.zsh" ]]; then
        echo -e
        "$(brew --prefix)"/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    fi
}

setup_packages() {
    title "Setting up packages"

    check_for_software htop
    check_for_software zsh
    check_for_software tmux
    check_for_software jq
    check_for_software file
    check_for_software tree
    check_for_software vim
    check_for_software neofetch


    # httpie
    if [[ ! -x "$(command -v http)" ]]; then
        prompt_install httpie
    else
        info "httpie is already installed"
    fi

    # fd-find alias fd
    if [[ ! -x "$(command -v fdfind)" ]] && [[ ! -x "$(command -v fd)" ]]; then
        prompt_install fd-find
    else
        info "fd is already installed"
    fi
    if [[ -x "$(command -v fdfind)" ]] && [[ ! -x "$(command -v fd)" ]]; then
        [[ ! -d "$HOME/.local/bin" ]] && mkdir -p "$HOME/.local/bin"
        ln -s $(which fdfind) ~/.local/bin/fd
    fi

    # fzf
    if [[ ! -x "$(command -v fzf)" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    else
        info "fzf is already installed"
    fi

    # lf
    check_for_software lf
    if [[ $? -ne 0 ]]; then
        warning "Can't install lf, please install it on your own."
    fi
}

# #######################################
# Main

main() {
    case "$1" in
        backup)
            backup_setup
            ;;
        link)
            setup_symlinks
            ;;
        git)
            setup_git
            ;;
        shell)
            setup_shell
            ;;
        zsh)
            setup_zsh
            ;;
        homebrew)
            setup_homebrew
            ;;
        packages)
            setup_packages
            ;;
        all)
            setup_symlinks
            [[ $2 = "--no-homebrew-setup" ]] && setup_packages || setup_homebrew
            setup_zsh
            setup_shell
            setup_git
            ;;
        *)
            echo -e $"\nUsage: $(basename "$0") $1 { backup | link | homebrew | packages | zsh | shell | git | all [--no-homebrew-setup] }\n"
            exit 1
            ;;
    esac

    echo -e
    success "Done."
}

# Call main
main $1 $2
