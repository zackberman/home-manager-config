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
    ./neovim
    ./ssh
    ./starship
    ./tmux
    ./zellij
  ];
}
