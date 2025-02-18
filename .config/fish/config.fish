source /usr/share/cachyos-fish-config/cachyos-config.fish
zoxide init fish | source

# overwrite greeting
function fish_greeting
end
set -Ux CC clang
set -Ux CXX clang++

# fuzzy search w/ preview, open in terminal on select
function fs
    fzf --print-query --phony --prompt 'Search Files> ' \
        --delimiter ':' \
        --nth 1,2 \
        --bind "change:reload(rg --line-number --hidden --color=never --smart-case {q} || echo 'No matches')" \
        --preview 'bat --style=numbers --color=always --line-range :500 {1}' \
        --preview-window 'up:60%' \
        --bind 'enter:execute($EDITOR {1} +{2} </dev/tty >/dev/tty 2>&1)' </dev/null
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

#aliases
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias fd='fdfind'
alias cd='z'
alias zj="zellij"

#env
set -gx EDITOR nvim
set -Ux TERMINAL ghostty

fish_add_path ~/bin
