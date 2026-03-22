{ config, lib, pkgs, ... }:
{
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=3G" "mode=755" ];
  };

  fileSystems."/iso" = {
    device = "/dev/disk/by-label/${config.isoImage.volumeID}";
    fsType = "iso9660";
    neededForBoot = true;
    options = [ "ro" "nofail" "x-systemd.device-timeout=40s" ];
  };

  fileSystems."/nix/.ro-store" = {
    device = "/sysroot/iso/nix-store.erofs";
    fsType = "erofs";
    neededForBoot = true;
    depends = [ "/iso" ];
    options = [ "ro" ];
  };

  fileSystems."/nix/.rw-store" = {
    fsType = "tmpfs";
    neededForBoot = true;
    options = [ "mode=0755" ];
  };

  boot.initrd.systemd.tmpfiles.settings."10-overlay-dirs" = {
    "/sysroot/nix/.rw-store/store".d = { mode = "0755"; user = "root"; group = "root"; };
    "/sysroot/nix/.rw-store/work".d  = { mode = "0755"; user = "root"; group = "root"; };
  };

  fileSystems."/nix/store" = {
    fsType = "overlay";
    device = "overlay";
    neededForBoot = true;
    depends = [ "/nix/.ro-store" "/nix/.rw-store" ];
    options = [
      "lowerdir=/sysroot/nix/.ro-store/nix/store"
      "upperdir=/sysroot/nix/.rw-store/store"
      "workdir=/sysroot/nix/.rw-store/work"
    ];
  };
}
