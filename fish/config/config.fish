set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"

set -gx PATH $HOME/.asdf/shims $PATH
# status --is-interactive; and source ~/.asdf/asdf.fish
# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

direnv hook fish | source

set -gx PATH \
    /usr/local/bin \
    /home/rhimmelbauer/.asdf/shims \
    /home/rhimmelbauer/.local/bin \
    /usr/local/go/bin \
    /home/rhimmelbauer/.asdf/plugins/python/shims \
    /home/rhimmelbauer/.asdf/installs/python/3.14.5t/bin \
    /home/rhimmelbauer/.cargo/bin \
    /usr/local/sbin \
    /usr/sbin \
    /usr/bin \
    /sbin \
    /bin \
    /usr/games \
    /usr/local/games \
    /snap/bin


fish_django
fish_docker
fish_git
fish_tmux
fish_venv
fish_mlp
starship init fish | source
