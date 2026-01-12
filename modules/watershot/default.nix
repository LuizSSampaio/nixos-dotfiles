{ pkgs, lib, config, inputs, ... }:

with lib;
let
  cfg = config.modules.watershot;

  # Access Stylix colors (base16 scheme)
  colors = config.lib.stylix.colors;

  # Convert hex string to integer (0-255)
  hexToInt = hex:
    let
      hexChars = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };
      h1 = hexChars.${builtins.substring 0 1 hex};
      h2 = hexChars.${builtins.substring 1 1 hex};
    in h1 * 16 + h2;

  # Convert integer (0-255) to float string with proper formatting
  intToFloatStr = i:
    let
      # Multiply by 1000000, divide by 255, then format as decimal
      scaled = i * 1000000 / 255;
      intPart = scaled / 1000000;
      decPart = scaled - (intPart * 1000000);
      # Pad decimal part with leading zeros if needed
      decStr = toString decPart;
      paddedDec = substring 0 2 (decStr + "00");
    in "${toString intPart}.${paddedDec}";

  # Extract RGB components from 6-char hex as float strings
  hexToRgbStr = hex: {
    r = intToFloatStr (hexToInt (builtins.substring 0 2 hex));
    g = intToFloatStr (hexToInt (builtins.substring 2 2 hex));
    b = intToFloatStr (hexToInt (builtins.substring 4 2 hex));
  };

  # Color mappings from Stylix base16
  # base0D = blue (accent for selection)
  # base00 = background (shade)
  # base05 = foreground (text)
  selectionColor = hexToRgbStr colors.base0D;
  shadeColor = hexToRgbStr colors.base00;
  textColor = hexToRgbStr colors.base05;

  watershotConfig = ''
    Config(
        handle_radius: 10,
        line_width: 2,
        display_highlight_width: 5,
        selection_color: Color(
            r: ${selectionColor.r},
            g: ${selectionColor.g},
            b: ${selectionColor.b},
            a: 1.0,
        ),
        shade_color: Color(
            r: ${shadeColor.r},
            g: ${shadeColor.g},
            b: ${shadeColor.b},
            a: 0.6,
        ),
        text_color: Color(
            r: ${textColor.r},
            g: ${textColor.g},
            b: ${textColor.b},
            a: 1.0,
        ),
        mode_text_size: 50,
        font_family: "${config.stylix.fonts.monospace.name}",
    )
  '';
in {
  options.modules.watershot = {
    enable = mkEnableOption "watershot screenshot tool";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.watershot.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.grim
    ];

    # Ensure Screenshots directory exists
    home.file."Pictures/Screenshots/.keep".text = "";

    # Watershot configuration with Stylix colors
    xdg.configFile."watershot.ron".text = watershotConfig;
  };
}
