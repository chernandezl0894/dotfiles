function __fish_prompt_pwd --description 'Working directory shortened to fit a narrow terminal'
    # prompt_pwd abbreviates intermediate directories (~/.c/fish), which is
    # usually enough. Truncate further from the left when the window is tiny.
    set -l dir (prompt_pwd)

    set -l columns 80
    if set -q COLUMNS
        set columns $COLUMNS
    end

    # Leave room for the git branch and for typing.
    set -l max (math "max(16, $columns - 20)")

    if test (string length -- $dir) -gt $max
        set -l tail (string sub -s -(math "$max - 2") -- $dir)

        # Drop the partial first component so the result starts on a path
        # boundary instead of half a directory name.
        if string match -q '*/*' -- $tail
            set tail (string replace -r '^[^/]*' '' -- $tail)
        end

        set dir "…$tail"
    end

    printf '%s' $dir
end
