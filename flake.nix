{
  description = "My NixOS configuration";
  # https://dotfiles.sioodmy.dev

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    ragenix.url = "github:yaxitech/ragenix";
    webcord.url = "github:fufexan/webcord-flake";
    hyprland.url = "github:hyprwm/Hyprland/";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    helix.url = "github:SoraTenshi/helix/experimental-22.12";
    sioodmy-dev.url = "git+https://git.sioodmy.dev/sioodmy/sioodmy.dev";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {self, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = import ./hosts inputs;

    # sd card image for raspberry pi (Iapetus host)
    # build with `nix build .#images.iapetus`
    images = {
      iapetus =
        (self.nixosConfigurations.iapetus.extendModules {
          modules = ["${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"];
        })
        .config
        .system
        .build
        .sdImage;
    };
    packages.${system} = {
      catppuccin-folders = pkgs.callPackage ./pkgs/catppuccin-folders.nix {};
      catppuccin-gtk = pkgs.callPackage ./pkgs/catppuccin-gtk.nix {};
      catppuccin-cursors = pkgs.callPackage ./pkgs/catppuccin-cursors.nix {};
    };
  };
}
