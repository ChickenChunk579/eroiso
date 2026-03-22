{ stdenv, lib, toplevel, volumeID, closureInfo, erofs-utils, grub2, grub2_efi, xorriso, coreutils, mtools }:
let
  closure = closureInfo { rootPaths = [ toplevel ]; };
  isoName = "${lib.toLower volumeID}.iso";
in
stdenv.mkDerivation {
  name = isoName;
  buildInputs = [ erofs-utils grub2 grub2_efi xorriso coreutils mtools ];
  inherit toplevel volumeID;
  buildCommand = ''
    echo "--- Preparing ISO structure ---"
    mkdir -p iso-root/boot/grub
    cp $toplevel/kernel iso-root/boot/bzImage
    cp $toplevel/initrd iso-root/boot/initrd

    echo "--- Building EROFS store image ---"
    STAGING=$(mktemp -d)
    mkdir -p "$STAGING/nix/store"
    while IFS= read -r storepath; do
        cp -r "$storepath" "$STAGING/nix/store/"
    done < ${closure}/store-paths
    mkfs.erofs --all-root -L "NIX_STORE" \
        -z lz4hc,6 \
        iso-root/nix-store.erofs "$STAGING"

    echo "--- Writing grub.cfg ---"
    cat > iso-root/boot/grub/grub.cfg <<EOF
    set timeout=5
    set default=0
    menuentry "GlacierOS Installer" {
        linux /boot/bzImage init=$toplevel/init boot.shell_on_fail
        initrd /boot/initrd
    }
    EOF

    echo "--- Building hybrid ISO ---"
    mkdir -p $out
    grub-mkrescue -o installer.iso iso-root/ \
        --directory="${grub2}/lib/grub/i386-pc" \
        --directory="${grub2_efi}/lib/grub/x86_64-efi" \
        -volid "$volumeID"

    cp installer.iso $out/${isoName}
  '';
}
