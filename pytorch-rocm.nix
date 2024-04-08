# PyTorch 2.0.1 with ROCm (AMD u suck)
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python311
    pkgs.python311Packages.torchWithRocm

    pkgs.rocmPackages.rocm-smi
    pkgs.rocmPackages.rocminfo
  ];

  shellHook = ''
    export HSA_OVERRIDE_GFX_VERSION=10.3.0
    echo "pytorch with ROCm ready..."
  '';
}
