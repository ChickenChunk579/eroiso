{
  description = "My NixOS-based distro installer ISO";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    mkIso = modules:
    let
      nixosSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = modules ++ [
          self.nixosModules.default
          "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
        ];
      };
      toplevel = nixosSystem.config.system.build.toplevel;
      volumeID = nixosSystem.config.isoImage.volumeID;
    in {
      inherit nixosSystem;
      iso = pkgs.callPackage ./iso.nix {
        inherit toplevel volumeID;
        inherit (pkgs) erofs-utils grub2 xorriso coreutils closureInfo;
      };
    };

    built = mkIso [ ./configuration.nix ];

  in {
    nixosModules.iso = {
      imports = [
        ./modules/iso-filesystems.nix
        ./modules/iso-label.nix
        ./modules/distro.nix
      ];
    };
    nixosModules.default = self.nixosModules.iso;

    nixosConfigurations.installer = built.nixosSystem;

    packages.${system} = rec {
      iso = built.iso;
      default = iso;
    };

    lib = {
      mkIso = mkIso;
    };
  };
}
