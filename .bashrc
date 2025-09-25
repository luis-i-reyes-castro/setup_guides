# Tab size (8 -> 4)
tabs -4

# GIT
# Setup colors
blue="\[\033[0;34m\]"
cyan="\[\033[0;36m\]"
green="\[\033[0;32m\]"
purple="\[\033[0;35m\]"
yellow="\[\033[93m\]"
reset="\[\033[0m\]"
# Setup PS1
# '\u' adds the name of the current user to the prompt
# '\$(__git_ps1)' adds git-related stuff
# '\W' adds the name of the current directory
export PS1="$cyan\u$yellow\$(__git_ps1)$green \W $ $reset"
# Show unstaged (*) and staged (+) changes next to the branch name
export GIT_PS1_SHOWDIRTYSTATE=1
# Activate git prompt
source ~/.git-prompt.sh

# PE: Python environment
source ~/pe/bin/activate
