if [[ "$(uname)" = "Linux" ]]; then
	alias ls='ls --color=auto'
	alias ll='ls --color=auto -alh'
	alias la='ls --color=auto -la'
elif [[ "$(uname)" = "Darwin" ]]; then
	alias ls='ls -G'
	alias ll='ls -G -alh'
	alias la='ls -G -la'
fi

alias grep='grep --color=auto'
alias cp='cp -v'
alias mv='mv -v'
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias du='du -sh' # calculate disk usage for a folder
alias myip="curl https://ipinfo.io/json | jq"

alias zshconf="$EDITOR $HOME/.zshrc"
alias localconf="$EDITOR $HOME/.localrc"
