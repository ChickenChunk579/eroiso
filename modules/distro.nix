{ lib, config, ... }:
{
  options.distro = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "MyDistro";
    };
    version = lib.mkOption {
      type = lib.types.str;
      default = "1.0";
    };
  };

  config = {
    isoImage.volumeID = "${lib.toUpper config.distro.name}-${config.distro.version}";

    system.nixos.distroName = config.distro.name;
    system.nixos.distroId = lib.toLower config.distro.name;

    system.nixos.label = config.distro.version;
  };
}
