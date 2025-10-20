function fish_prompt
    # Gruvbox colors
    set -l color_path 8ec07c
    set -l color_separator fe8019

    set -l full_path (pwd)
    set -l path_to_process (string replace -- "$HOME" "~" $full_path)
    set -l path_parts (string split / $path_to_process)
    set -l truncated_parts

    if test (count $path_parts) -gt 0
        set -l first_part $path_parts[1]
        if test "$first_part" = "~"
            set -a truncated_parts "~"
        else if test "$first_part" = ""
        else
            set -a truncated_parts (string sub --length 6 $first_part)
        end
    end

    if test (count $path_parts) -gt 1
        for i in (seq 2 (count $path_parts))
            set part $path_parts[$i]
            if test -n "$part"
                set -a truncated_parts (string sub --length 6 $part)
            end
        end
    end

    set -l display_path "?"
    if test "$full_path" = "/"
        set display_path "/"
    else if test (count $truncated_parts) -gt 0
        set display_path (string join / $truncated_parts)
        if test (string sub -s 1 -l 1 $full_path) = "/" && test (string sub -s 1 -l 1 $display_path) != "~"
            set display_path "/$display_path"
        end
    else
        if test "$full_path" = "/"
            set display_path "/"
        end
    end

    set_color $color_path
    echo -n $display_path
    set_color normal

    set_color $color_separator
    echo -n ' > '
    set_color normal
end
