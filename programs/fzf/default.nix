{
  pkgs,
  ...
}:

{
  programs.fzf =
    let defaultCommand = ''
      ${pkgs.ripgrep}/bin/rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null
    '';
  
    in {
      enable = true;
  
      # export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
      inherit defaultCommand;
  
      # export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      fileWidgetCommand = defaultCommand;
    };
}
