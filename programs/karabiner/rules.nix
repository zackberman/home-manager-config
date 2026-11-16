{ lib, keyboard }:
let
  bundle = import ./bundles.nix;
  condition = type: bundles: {
    type = "frontmost_application_${type}";
    bundle_identifiers = bundles;
  };
  ifTerm = condition "if" bundle.terminalEmulators;
  unlessStandard = condition "unless" bundle.standard;
  ifCitrix = condition "if" bundle.citrix;

  # Preserve optional modifiers, omitted mandatory modifiers, and rule order
  # from karabiner-windows-mode's Jsonnet definitions.
  input = key: modifiers: {
    key_code = key;
    modifiers = { optional = [ "any" ]; }
      // lib.optionalAttrs (modifiers != null) { mandatory = modifiers; };
  };
  output = key: modifiers: { key_code = key; }
    // lib.optionalAttrs (modifiers != null) { inherit modifiers; };
  rule = description: from: to: appCondition: {
    inherit description;
    manipulators = [ ({
      type = "basic";
      inherit from;
      to = [ to ];
    } // lib.optionalAttrs (appCondition != null) {
      conditions = [ appCondition ];
    }) ];
  };
  remap = description: key: modifiers: toKey: toModifiers: appCondition:
    rule description (input key modifiers) (output toKey toModifiers) appCondition;

  common =
    map (key: remap "${lib.toUpper key} (Command)" key [ "command" ] key [ "option" ] ifTerm)
      [ "h" "j" "k" "l" ]
    ++ [
      (remap "Home [+Terminal Emulators]" "home" null "a" [ "control" ] ifTerm)
      (remap "End [+Terminal Emulators]" "end" null "e" [ "control" ] ifTerm)
      # tmux uses Option+1/2 because Ctrl+PageUp/Down do not work in Terminal.
      (remap "Ctrl+PageUp [+Terminal Emulators]" "page_up" [ "control" ] "1" [ "option" ] ifTerm)
      (remap "Ctrl+PageDown [+Terminal Emulators]" "page_down" [ "control" ] "2" [ "option" ] ifTerm)
      (remap "Delete [+Finder]" "delete_forward" null "delete_or_backspace" [ "command" ] (condition "if" bundle.finder))
      (remap "Spotlight" "f1" null "spacebar" [ "command" ] null)
      (remap "Screenshot" "f2" null "5" [ "command" "shift" ] null)
      (remap "Insert (Ctrl)" "delete_forward" [ "control" ] "insert" [ "control" ] null)
      (remap "Insert (Shift)" "delete_forward" [ "shift" ] "insert" [ "shift" ] null)
    ]
    # These no-ops must precede the Ctrl+arrow rules. macOS Spaces is set to
    # Ctrl+Option+arrow; Citrix needs a separate modifier translation.
    ++ map (direction: remap "Move ${direction} a space" "${direction}_arrow"
      [ "control" "option" ] "${direction}_arrow" [ "control" "option" ] null)
      [ "left" "right" ]
    ++ map (direction: remap "Move ${direction} a space" "${direction}_arrow"
      [ "control" "command" ] "${direction}_arrow" [ "control" "option" ] ifCitrix)
      [ "left" "right" ]
    ++ [
      (remap "Multi-line editing [+Sublime Text]" "l" [ "control" "shift" ] "l"
        [ "command" "shift" ] (condition "if" bundle.sublimeText))
    ]
    ++ lib.concatMap (binding: [
      (remap "Insert (${binding.label}) [+Terminal Emulators]" "insert" [ binding.modifier ]
        binding.key [ "command" ] (condition "unless" (bundle.hypervisors ++ bundle.ides ++ bundle.remoteDesktops)))
      (remap "Insert (${binding.label})" "insert" [ binding.modifier ] binding.key [ "command" ] unlessStandard)
    ]) [
      { label = "Ctrl"; modifier = "control"; key = "c"; }
      { label = "Shift"; modifier = "shift"; key = "v"; }
    ]
    ++ lib.concatMap (binding: [
      (remap binding.label binding.key null binding.horizontal [ "command" ] unlessStandard)
      (remap "${binding.label} (Ctrl)" binding.key [ "control" ] binding.vertical [ "command" ] unlessStandard)
      (remap "${binding.label} (Shift)" binding.key [ "shift" ] binding.horizontal [ "command" "shift" ] unlessStandard)
      (remap "${binding.label} (Ctrl+Shift)" binding.key [ "control" "shift" ] binding.vertical [ "command" "shift" ] unlessStandard)
    ]) [
      { label = "Home"; key = "home"; horizontal = "left_arrow"; vertical = "up_arrow"; }
      { label = "End"; key = "end"; horizontal = "right_arrow"; vertical = "down_arrow"; }
    ]
    ++ lib.concatMap (direction: [
      (remap "${direction.label} Arrow (Ctrl)" direction.key [ "control" ] direction.key [ "option" ] unlessStandard)
      (remap "${direction.label} Arrow (Ctrl+Shift)" direction.key [ "control" "shift" ] direction.key [ "option" "shift" ] unlessStandard)
    ]) [
      { label = "Left"; key = "left_arrow"; }
      { label = "Right"; key = "right_arrow"; }
    ]
    ++ [
      (remap "Backspace (Ctrl)" "delete_or_backspace" [ "control" ] "delete_or_backspace" [ "option" ] unlessStandard)
      (remap "Enter (Ctrl)" "return_or_enter" [ "control" ] "return_or_enter" [ "command" ] unlessStandard)
      (remap "Enter (Ctrl+Shift)" "return_or_enter" [ "control" "shift" ] "return_or_enter" [ "command" "shift" ] unlessStandard)
    ]
    ++ map (key: remap "${lib.toUpper key} (Ctrl)" key [ "control" ] key [ "command" ] unlessStandard)
      [ "a" "c" "f" "n" "o" "p" "r" "s" "t" "u" "v" "w" "x" "y" "z" "spacebar" ];

  toAlt = key: remap
    "In Citrix, change ${key} to Alt via \"⌘⌥ Command (left)-Option\""
    key null "left_command" [ "left_option" ] ifCitrix;
  toWindows = key: remap
    "In Citrix, change ${key} to Windows logo key via \"Send Windows logo key using ⌘ Command (right)\""
    key null "right_command" null ifCitrix;
  keyboards = {
    glove80 = [ (toWindows "left_command") (toAlt "left_option") ];
    keychron_v5 = [ (toAlt "left_command") (toAlt "right_command") (toWindows "left_option") ];
  };
in
common ++ keyboards.${keyboard}
