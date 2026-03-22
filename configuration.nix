{ config, pkgs, ... }:
{
  imports = [ ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;
  boot.initrd.availableKernelModules = [ "iso9660" "erofs" "overlay" "loop" "sr_mod" ];

  users.users.root.initialPassword = "root";
  services.getty.autologinUser = "root";
  programs.bash.enable = true;

  distro.name = "GlacierOS";
  distro.version = "26.05";

  environment.systemPackages = with pkgs; [ bash coreutils pciutils usbutils ];

  system.stateVersion = "26.05";
}
