{ lib, ... }:
{
  options.isoImage.volumeID = lib.mkOption {
    type = lib.types.str;
    default = "NIXOS-CUSTOM";
    description = "ISO volume label used for the installer disc";
  };
}
