function fish_prompt --description 'Two-line prompt that stays readable on narrow screens'
    set -l last_status $status
    set -l marker '❯'
    if set -q fish_prompt_char
        set marker $fish_prompt_char
    end

    # First line: working directory and, when inside a repository, the git
    # branch plus a "*" marker for uncommitted changes.
    set_color $fish_prompt_color_cwd
    printf '%s' (__fish_prompt_pwd)

    set -l git (__fish_prompt_git)
    if test -n "$git"
        set_color $fish_prompt_color_git
        printf ' %s' $git
    end
    printf '\n'

    # Second line: only the prompt marker, so the command always has room to
    # grow even in a very narrow window.
    if test (id -u) -eq 0
        set_color --bold $fish_prompt_color_error
        printf '# '
    else if test $last_status -eq 0
        set_color $fish_prompt_color_success
        printf '%s ' $marker
    else
        set_color $fish_prompt_color_error
        printf '%s ' $marker
    end

    set_color normal
end
