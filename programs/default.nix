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
    ./home-manager
    ./karabiner
    ./neovim
    ./ssh
    ./starship
    ./tmux
    ./zellij
  ];
}
