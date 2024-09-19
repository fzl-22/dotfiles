if status is-interactive
    # Commands to run in interactive sessions can go here
    load_nvm > /dev/null
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/ahmadfaisal/Developments/miniconda3/bin/conda
    eval /Users/ahmadfaisal/Developments/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/Users/ahmadfaisal/Developments/miniconda3/etc/fish/conf.d/conda.fish"
        . "/Users/ahmadfaisal/Developments/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/Users/ahmadfaisal/Developments/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

