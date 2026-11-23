{
  flake.modules.homeManager.programs = {
    pkgs,
    config,
    isWSL,
    ...
  }:

  {
    programs.bash =
      let
        inherit (config.home) homeDirectory;

        # Windows rejected Nixpkgs' MinGW niperelay package with error 193, and
        # removing MinGW's strip step (`dontStrip = true`) fixes the failure. We
        # could simply override `dontStrip` instead of defining a custom
        # derivation, but:
        #
        #   - npiperelay is pure Go, so we can target Windows with the Linux Go
        #     compiler and cgo disabled, avoiding cross GCC, binutils, and
        #     Windows runtime libraries.
        #   - With Nixpkgs 26.05 on WSL, our native Go build requires 59 MiB
        #     from the binary cache (217 MiB unpacked) vs. 226 MiB (887 MiB
        #     unpacked) for the MinGW build.
        npiperelay = pkgs.stdenvNoCC.mkDerivation {
          inherit (pkgs.pkgsCross.mingwW64.windows.npiperelay)
            pname
            version
            src;

          nativeBuildInputs = [ pkgs.go ];
          dontStrip = true;

          env = {
            GOOS = "windows";
            inherit (pkgs.go) GOARCH;
            CGO_ENABLED = "0";
            GOTOOLCHAIN = "local";
          };

          buildPhase = ''
            runHook preBuild
            export GOCACHE="$TMPDIR/go-cache"
            go build -mod=vendor -trimpath -o npiperelay.exe .
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -Dm755 npiperelay.exe "$out/bin/npiperelay.exe"
            runHook postInstall
          '';
        };

        agent-bridge =
          pkgs.writeShellApplication {
            name = "agent-bridge";
            text = builtins.readFile ./agent-bridge.sh;

            runtimeEnv.NPIPERELAY = "${npiperelay}/bin/npiperelay.exe";

            runtimeInputs = [
              pkgs.socat
              pkgs.iproute2 # for ss
              pkgs.util-linux # for flock and setsid
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
  };
}
