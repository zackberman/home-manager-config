{
  config,
  pkgs,
  homeDirectory,
  isWSL,
  agent-bridge,
  ...
}:

{
  imports = [
    ./alacritty
    ./bash
    ./fzf
    ./neovim
    ./ssh
    ./starship
    ./tmux
  ];
}
