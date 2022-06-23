{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    picom-dccsillag = {
      url = "github:dccsillag/picom/implement-window-animations";
      flake = false;
    };

    discord-overlay = {
      url = "github:InternetUnexplorer/discord-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    discocss.url = "github:mlvzk/discocss/flake";

    eww.url = "github:elkowar/eww";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    todo.url = "github:sioodmy/todo";
    fetch.url = "github:sioodmy/fetch";

  };
  outputs = inputs@{ self, nixpkgs, home-manager, nur, eww
    , discord-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;

      mkSystem = pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [
            { networking.hostName = hostname; }
            (./. + "/hosts/${hostname}/system.nix")
            (./. + "/hosts/${hostname}/hardware-configuration.nix")
            ./modules/system/configuration.nix
            ./modules/system/adblock.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.sioodmy = (./. + "/hosts/${hostname}/user.nix");
                sharedModules = [ inputs.discocss.hmModule ];
              };
              nixpkgs.overlays = [
                (final: prev: {
                  picom =
                    prev.picom.overrideAttrs (o: { src = inputs.picom-dccsillag; });
                })
                (final: prev: {
                  catppuccin-cursors =
                    prev.callPackage ./overlays/catppuccin-cursors.nix { };
                })
                nur.overlay
                discord-overlay.overlay
                inputs.neovim-nightly-overlay.overlay
              ];
            }

          ];
          specialArgs = { inherit inputs; };
        };
    in {
      nixosConfigurations = {
        graphene = mkSystem inputs.nixpkgs "x86_64-linux" "graphene";
        thinkpad = mkSystem inputs.nixpkgs "x86_64-linux" "thinkpad";
      };

      devShell.${system} = pkgs.mkShell {
        packages = [ pkgs.nixpkgs-fmt ];
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };

      checks.${system}.pre-commit-check =
        inputs.pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks.nixpkgs-fmt.enable = true;
          hooks.shellcheck.enable = true;
        };
    };
}
