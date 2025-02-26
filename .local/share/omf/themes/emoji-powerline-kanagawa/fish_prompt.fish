# name: emoji-powerline
# 
# based on agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for FISH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).

## Set this options in your config.fish (if you want to :])
# set -g theme_display_user yes
# set -g theme_hide_hostname yes
# set -g theme_hide_hostname no
# set -g default_user your_normal_user

set -g current_bg NONE

set hard_space \u2060
set icon_root '🌏'
set icon_home '🏡'
#set icon_root '/'
#set icon_home '~'

set prompt_text '→'

# Kanagawa Colors
set colour_text_path "#DCD7BA" # fujiWhite
set colour_text_dirty "#C34043" # autumnRed
set colour_text_clean "#76946A" # autumnGreen
set colour_commit "#DCD7BA" # fujiWhite (for Git commit hash)
set colour_branch "#E6C384" # carpYellow (for Git branch name)

set colour_path "#7E9CD8" # crystalBlue
set colour_dirty "#C34043" # autumnRed
set colour_clean "#76946A" # autumnGreen

set segment_separator \uE0B0
set segment_splitter \uE0B1
set right_segment_separator \uE0B0

# ===========================
# Helper methods
# ===========================

set -g __fish_git_prompt_showdirtystate yes
set -g __fish_git_prompt_char_dirtystate '📂'
set -g __fish_git_prompt_char_cleanstate '📁'

function parse_git_dirty
    set -l submodule_syntax
    set submodule_syntax "--ignore-submodules=dirty"
    set git_dirty (command git status --porcelain $submodule_syntax  2> /dev/null)
    if [ -n "$git_dirty" ]
        if [ $__fish_git_prompt_showdirtystate = yes ]
            echo -n "$__fish_git_prompt_char_dirtystate"
        end
    else
        if [ $__fish_git_prompt_showdirtystate = yes ]
            echo -n "$__fish_git_prompt_char_cleanstate"
        end
    end
end

# ===========================
# Segments functions
# ===========================

function prompt_segment -d "Function to draw a segment"
    set -l bg
    set -l fg
    if [ -n "$argv[1]" ]
        set bg $argv[1]
    else
        set bg normal
    end
    if [ -n "$argv[2]" ]
        set fg $argv[2]
    else
        set fg normal
    end
    if [ "$current_bg" != NONE -a "$argv[1]" != "$current_bg" ]
        set_color -b $bg
        set_color $current_bg
        echo -n "$segment_separator "
        set_color -b $bg
        set_color $fg
    else
        set_color -b $bg
        set_color $fg
        echo -n " "
    end
    set current_bg $argv[1]
    if [ -n "$argv[3]" ]
        echo -n -s $argv[3] " "
    end
end

function prompt_finish -d "Close open segments"
    if [ -n $current_bg ]
        set_color -b normal
        set_color $current_bg
        echo -n "$segment_separator "
    end
    set -g current_bg NONE
end

# ===========================
# Theme components
# ===========================

function prompt_virtual_env -d "Display Python virtual environment"
    if test "$VIRTUAL_ENV"
        prompt_segment "#C8C093" "#16161D" (basename $VIRTUAL_ENV) # oldWhite on sumiInk0
    end
end

function prompt_user -d "Display current user if different from $default_user"
    if [ "$theme_display_user" = yes ]
        if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
            set USER (whoami)
            get_hostname
            if [ $HOSTNAME_PROMPT ]
                set USER_PROMPT $USER@$HOSTNAME_PROMPT
            else
                set USER_PROMPT $USER
            end
            prompt_segment "#FF9E3B" "#1F1F28" $USER_PROMPT # roninYellow on sumiInk1
        end
    else
        get_hostname
        if [ $HOSTNAME_PROMPT ]
            prompt_segment "#FF9E3B" "#1F1F28" $HOSTNAME_PROMPT # roninYellow on sumiInk1
        end
    end
end

function get_hostname -d "Set current hostname to prompt variable $HOSTNAME_PROMPT if connected via SSH"
    set -g HOSTNAME_PROMPT ""
    if [ "$theme_hide_hostname" = no -o \( "$theme_hide_hostname" != yes -a -n "$SSH_CLIENT" \) ]
        set -g HOSTNAME_PROMPT (hostname)
    end
end

function prompt_dir -d "Display the current directory"
    prompt_segment $colour_path $colour_text_path (string trim (string join " $segment_splitter " (string split '/' (string replace -r '^\/$' "$icon_root$hard_space" (string replace -r '^\/(.+?)' "$icon_root/\$1" (string replace -r '^\~' "$icon_home$hard_space" (string trim (prompt_pwd))))))))
end

function prompt_git -d "Display the current git state"
    set -l ref
    set -l dirty
    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set dirty (parse_git_dirty)
        set ref (command git symbolic-ref HEAD 2> /dev/null)
        if [ $status -gt 0 ]
            set -l branch (command git show-ref --head -s --abbrev | head -n1 2> /dev/null)
            set ref "➦ $branch "
        end
        set branch_symbol \uE0A0
        set -l branch (string join " $segment_splitter " (string split '/' (echo $ref | sed "s-refs/heads/-$branch_symbol -")))
        if [ "$dirty" = "$__fish_git_prompt_char_dirtystate" ]
            prompt_segment $colour_dirty $colour_branch "$branch $dirty" # Use $colour_branch for branch name
        else
            prompt_segment $colour_clean $colour_branch "$branch $dirty" # Use $colour_branch for branch name
        end
    end
end

function prompt_status -d "the symbols for a non zero exit status, root and background jobs"
    if [ $RETVAL -ne 0 ]
        prompt_segment "#E82424" "#1F1F28" "⚠️ " # samuraiRed on sumiInk1
    end

    # if superuser (uid == 0)
    set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
        prompt_segment "#FF9E3B" "#1F1F28" "⚡" # roninYellow on sumiInk1
    end

    # Jobs display
    if [ (jobs -l | wc -l) -gt 0 ]
        prompt_segment "#6A9589" "#1F1F28" "⚙" # waveAqua1 on sumiInk1
    end
end

# ===========================
# Apply theme
# ===========================

function fish_prompt
    set -g RETVAL $status
    prompt_status
    prompt_virtual_env
    prompt_user
    prompt_dir
    type -q git; and prompt_git
    prompt_finish
    echo ""
    prompt_segment $colour_path $colour_text_path $prompt_text
    prompt_finish
end
