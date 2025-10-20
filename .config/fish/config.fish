if status is-interactive
    set -U fish_greeting ""

    alias ls='eza -al --color=always --group-directories-first'
    alias pi='sudo pacman -S'
    alias pr='sudo pacman -R'
    alias prr='sudo pacman -Rns'
    alias wofi='wofi --show drun'
    function sudo
        faillock --reset
        env WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR sudo $argv
    end
end
