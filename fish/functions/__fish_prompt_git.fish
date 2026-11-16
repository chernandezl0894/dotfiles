function __fish_prompt_git --description 'Current git branch with a dirty marker'
    # Older or minimal setups may not have git at all; skip the segment.
    type -q git
    or return

    set -l branch (command git branch --show-current 2>/dev/null)
    or return

    # Detached HEAD: fall back to the short commit hash.
    if test -z "$branch"
        set branch (command git rev-parse --short HEAD 2>/dev/null)
        or return
    end

    # Keep long branch names from taking over a narrow prompt.
    if test (string length -- $branch) -gt 20
        set branch (string sub -l 20 -- $branch)"…"
    end

    # A single porcelain query covers staged, unstaged, and untracked files.
    set -l dirty ''
    if command git status --porcelain --ignore-submodules=all 2>/dev/null | string match -qr .
        set dirty '*'
    end

    printf '%s%s' $branch $dirty
end
