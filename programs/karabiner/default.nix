{ config, lib, pkgs, ... }:
let
  cfg = config.programs.karabiner;

  generated = (pkgs.formats.json {}).generate "karabiner.json"
    (import ./settings.nix { inherit lib; inherit (cfg) keyboard; });

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
    keyboard = lib.mkOption {
      type = lib.types.enum [ "keychron_v5" "glove80" ];
      default = "keychron_v5";
      description = "Keyboard rules to install; only one ruleset is active at a time.";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    # Karabiner rewrites its configuration, replacing file symlinks. Install
    # a writable copy instead, and retain a backup whenever content changes.
    home.activation.karabiner = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${installer} ${generated} ${lib.escapeShellArg "${config.xdg.configHome}/karabiner/karabiner.json"}
    '';
  };
}
