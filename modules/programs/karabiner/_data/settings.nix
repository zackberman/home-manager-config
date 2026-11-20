{ lib, remapFunctionRow }:
let
  device = { description, vendor_id, product_id, settings }: {
    identifiers = { inherit vendor_id product_id; is_keyboard = true; };
  } // settings;

  swap = from: to: {
    from.key_code = from;
    to = [ { key_code = to; } ];
  };
in
{
  profiles = [ {
    name = "Default profile";
    selected = true;

    complex_modifications.rules = import ./rules.nix { inherit lib remapFunctionRow; };

    # IDs identify models, not individual units
    devices = map device [
      {
        description = "Dell KB216 wired keyboard (USB 413c:2113)";
        vendor_id = 16700;
        product_id = 8467;
        settings.simple_modifications = [
          (swap "left_command" "left_option")
          (swap "left_option" "left_command")
          (swap "right_option" "right_command")
        ];
      }
      {
        description = "Logitech G102/G103/G203 family (USB 046d:c084)";
        vendor_id = 1133;
        product_id = 49284;
        settings.ignore = true;
      }
      {
        description = "Logitech G102/G103/G203 family (USB 046d:c092)";
        vendor_id = 1133;
        product_id = 49298;
        settings = { ignore = true; manipulate_caps_lock_led = false; };
      }
      {
        description = "Yubico YubiKey OTP+FIDO+CCID (USB 1050:0407)";
        vendor_id = 4176;
        product_id = 1031;
        settings.manipulate_caps_lock_led = false;
      }
      {
        description = "Logitech G502 HERO Gaming Mouse (USB 046d:c08b)";
        vendor_id = 1133;
        product_id = 49291;
        settings.ignore = true;
      }
    ];

    virtual_hid_keyboard = { country_code = 0; keyboard_type_v2 = "ansi"; };
  } ];
}
