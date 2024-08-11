{
  pkgs,
  ...
}:

{
  programs.starship = {
    enable = true;
    settings = {
      battery.disabled = true;
      python = {
        python_binary = [ "${pkgs.python3}/bin/python3" ];
      };
    };
  };
}
