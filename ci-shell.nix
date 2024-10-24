{ pkgs ? import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; } }:

pkgs.mkShell {
  packages = with pkgs; [
    firefox-bin
  ];
}
