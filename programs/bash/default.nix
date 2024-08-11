{
  pkgs,
  homeDirectory,
  isWSL,
  agent-bridge,
  ...
}:

{
  programs.bash =
    let
      agent-bridge =
        pkgs.writeShellApplication {
          name          = "agent-bridge";
          text          = builtins.readFile ./agent-bridge.sh;
          runtimeInputs = [
            pkgs.socat
            pkgs.toybox # for pgrep and setsid
          ];
        };

    in {
      enable = true;
      initExtra = ''
        function ll() { eza -algF --group-directories-first "$@"; }
        function tree() { eza -T "$@"; }

      '' + (pkgs.lib.optionalString isWSL ''
        "${agent-bridge}/bin/agent-bridge"
      '');

      shellAliases = {
        dirs = "dirs -v";
      };

      # don't put duplicate lines or lines starting with space in the history
      historyControl = [ "ignoredups" "ignorespace" ];

      sessionVariables =
        let
          display = { DISPLAY = ":0"; };
          ssh_auth_sock =
            if pkgs.stdenv.isDarwin
            then { SSH_AUTH_SOCK = homeDirectory + "/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"; }
            else if isWSL
            then { SSH_AUTH_SOCK = homeDirectory + "/.1password/agent.sock"; }
            else {};

          # Bash completions weren't working for individual applications in
          # macOS, and this fixes it. Possibly this should also apply to WSL,
          # but I wasn't running into issues.
          xdg_data_dirs =
            pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
              XDG_DATA_DIRS = homeDirectory + "/.nix-profile/share";
            };
        in
          display // ssh_auth_sock // xdg_data_dirs;
    };
}
