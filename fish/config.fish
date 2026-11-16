# Fish configuration managed by the dotfiles repository.
#
# The prompt is split over two lines (functions/fish_prompt.fish) so long
# paths and git branches never push the command you are typing off a narrow
# screen. Colors use the terminal's ANSI palette, so they follow whatever
# Alacritty theme is active.

if status is-interactive
    # No greeting banner; the prompt is information enough.
    set -g fish_greeting

    # Prompt appearance. ANSI names keep these readable on light and dark
    # terminal themes (the Alacritty default here is Sweetie Light).
    #
    # These use a custom prefix instead of fish_color_* because fish's default
    # theme stores its own fish_color_* values as universal variables, which
    # would take precedence over globals set here. Syntax highlighting and
    # autosuggestion colors therefore come from fish's theme; use
    # `fish_config theme` to change them.
    set -g fish_prompt_char '❯'
    set -g fish_prompt_color_cwd blue
    set -g fish_prompt_color_git magenta
    set -g fish_prompt_color_success green
    set -g fish_prompt_color_error red

    # Abbreviations expand as you type but stay readable in history, which
    # makes them safer than aliases for commands you may want to edit.
    abbr --add ll 'ls -lah'
    abbr --add la 'ls -lah'
    abbr --add gs 'git status -sb'
    abbr --add gd 'git diff'
    abbr --add gl 'git log --oneline --graph --decorate -20'
    abbr --add ga 'git add'
    abbr --add gc 'git commit'
    abbr --add tm 'tmux new -A -s main'
    abbr --add ta 'tmux attach'
end

# Make the tools installed by bootstrap.sh available in every shell.
fish_add_path --global --move $HOME/.local/bin $HOME/.cargo/bin $HOME/go/bin

# Editor used by git, tmux, and other CLI tools.
set -q EDITOR; or set -gx EDITOR nvim
set -q VISUAL; or set -gx VISUAL nvim
set -q PAGER; or set -gx PAGER less
