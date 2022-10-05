autoload -U compinit && compinit

compdef _dotfiles dotfiles

# zstyle ':completion:*' verbose yes
# zstyle ':completion:*:descriptions' format '%B%d%b'
# zstyle ':completion:*:messages' format '%d'
# zstyle ':completion:*:warnings' format 'No matches for: %d'
# zstyle ':completion:*' group-name ''

_comp_options+=(globdots)
zstyle ':completion:*' special-dirs false

# disable sort when completing `git checkout`
# zstyle ':completion:*:git-checkout:*' sort false

# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'

# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# env vars etc
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'

# brew
# zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word'

# preview some basics using less
zstyle ':fzf-tab:complete:(ls|exa|cat|chmod|tail|cd|mv|rm|vim|nano):*' fzf-preview 'less -R ${(Q)realpath}'

# git
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'echo $realpath; git diff $realpath | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"commit tag") git show --color=always $word ;;
	*) git show --color=always $word | delta ;;
	esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
	esac'

# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# fzf flags
zstyle ':fzf-tab:*' fzf-flags --height 80%

# fzf bindings
zstyle ':fzf-tab:complete:*' fzf-bindings 'alt-up:preview-page-up' 'alt-down:preview-page-down'

