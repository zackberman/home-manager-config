{
  flake.modules.homeManager.programs = { config, lib, pkgs, ... }:
  let
    cfg = config.programs.karabiner;

    generated = (pkgs.formats.json {}).generate "karabiner.json"
      (import ./_data/settings.nix {
        inherit lib;
        inherit (cfg) remapFunctionRow;
      });

    installer = pkgs.writeShellScript "install-karabiner-config" ''
      set -euo pipefail
      export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.diffutils ]}
      source=$1
      target=$2
      if cmp -s "$source" "$target"; then
        exit 0
      fi
      mkdir -p "$(dirname "$target")"
      if [ -e "$target" ] || [ -L "$target" ]; then
        backup=$(mktemp "$target.backup.XXXXXXXX")
        cp -pL "$target" "$backup"
        echo "Backed up Karabiner configuration to $backup"
      fi
      temporary=$(mktemp "$(dirname "$target")/.karabiner.json.XXXXXXXX")
      trap 'rm -f "$temporary"' EXIT
      install -m 600 "$source" "$temporary"
      mv -fT "$temporary" "$target"
    '';
  in
  {
    options.programs.karabiner = {
      enable = lib.mkEnableOption "declarative Karabiner-Elements configuration";
      remapFunctionRow = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Remap F1 to Spotlight and F2 to the screenshot shortcut.";
      };
    };

    config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
      # Karabiner rewrites its configuration, replacing file symlinks. Install
      # a writable copy instead, and retain a backup whenever content changes.
      home.activation.karabiner = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${installer} ${generated} ${lib.escapeShellArg "${config.xdg.configHome}/karabiner/karabiner.json"}
      '';
    };
  };
}
