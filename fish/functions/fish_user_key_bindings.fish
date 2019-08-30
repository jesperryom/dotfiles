function fish_user_key_bindings -d "More vim like completion bindings"
  for mode in insert default visual
    bind -M $mode \cl forward-char
    bind -M $mode \ch backward-char
    bind -M $mode \cn down-or-search
    bind -M $mode \cp up-or-search
  end
end

fzf_key_bindings
