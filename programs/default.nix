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
    ./git
    ./home-manager
    ./karabiner
    ./neovim
    ./ssh
    ./starship
    ./tmux
    ./zellij
  ];
}
