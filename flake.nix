{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = { ... }: { overlay = import ./overlay.nix; };
}
