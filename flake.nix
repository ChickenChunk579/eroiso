{
  description = "My NixOS-based distro installer ISO";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    nixosSystem = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        ./modules/iso-filesystems.nix
        ./modules/iso-label.nix
        ./modules/distro.nix
        "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
      ];
    };

    toplevel = nixosSystem.config.system.build.toplevel;
    volumeID = nixosSystem.config.isoImage.volumeID;

  in {
    nixosConfigurations.installer = nixosSystem;

    packages.${system} = rec {
      iso = pkgs.callPackage ./iso.nix {
        inherit toplevel volumeID;
        inherit (pkgs) erofs-utils grub2 xorriso coreutils closureInfo;
      };
      default = iso;
    };
  };
}
