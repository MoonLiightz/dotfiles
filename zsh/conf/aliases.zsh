# Some aliases from the ZSH plugins we don't like to use for various reasons. 
# We "unalias" them here.
unalias yh	# conflicts with "yh - YAML Highlighter"

if [[ "$(uname)" = "Linux" ]]; then
	alias ls='ls --color=auto'
	alias ll='ls --color=auto -alh'
	alias la='ls --color=auto -la'
elif [[ "$(uname)" = "Darwin" ]]; then
	if [[ -x "$(command -v eza)" ]]; then
		alias ls="eza -l -g --icons --git"
		alias ll="eza -la -g --icons --git"
		alias llt="eza -la -g --tree --icons --git"
		alias lltd="llt --ignore-glob 'node_modules|.git|.next|.vscode|.idea'"
	else
		alias ls='ls -G'
		alias ll='ls -G -alh'
		alias la='ls -G -la'
	fi
fi

alias grep='grep --color=auto'
alias cp='cp -v'
alias mv='mv -v'
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias src="omz reload"

alias zshconf="$EDITOR $HOME/.zshrc"
alias localconf="$EDITOR $HOME/.localrc"

alias tmm="tmux-sessionizer main"
alias du='du -sh' # calculate disk usage for a folder
alias myip="curl -s https://ipinfo.io/json | jq"
alias lg="lazygit"

[[ -x "$(command -v batcat)" ]] && alias bat='batcat'

# kubectl / kubernetes
alias k="kubectl"
alias kg="kubectl get"
alias kgp="kubectl get pod"
alias kgpow="kubectl get pod -o wide"
alias kgall="kubectl get --all-namespaces all"
alias kdp="kubectl describe pod"
alias kctx="kubectx"
alias kns="kubens"
