{
  description = "ri7's nix darwin system";

  inputs = {
    # Package sets
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-22.05";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.inputs.flake-compat.follows = "flake-compat";
    home-manager.inputs.utils.follows = "flake-utils";

    # Other sources
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, darwin, home-manager, flake-utils, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays;
      };

      # Personal configuration shared between `nix-darwin` and plain `home-manager` configs.
      homeManagerStateVersion = "22.05";

      primaryUserInfo = {
        username = "muhghazaliakbar";
        fullName = "Muh Ghazali Akbar";
        email = "muhghazalakbar@icloud.com";
        nixConfigDirectory = "/Users/muhghazaliakbar/.config/nixpkgs";
      };

      # Modules shared by most `nix-darwin` personal configurations.
      nixDarwinCommonModules = attrValues self.commonModules ++ attrValues self.darwinModules ++ [
        # `home-manager` module
        home-manager.darwinModules.home-manager
        (
          { config, lib, pkgs, ... }:
          let
            inherit (config.users) primaryUser;
          in
          {
            nixpkgs = nixpkgsConfig;
            # Hack to support legacy worklows that use `<nixpkgs>` etc.
            nix.nixPath = { nixpkgs = "${primaryUser.nixConfigDirectory}/nixpkgs.nix"; };
            # `home-manager` config
            users.users.${primaryUser.username} = {
              home = "/Users/${primaryUser.username}";
              shell = pkgs.fish;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.users.${primaryUser.username} = {
              imports = attrValues self.homeManagerModules;
              home.stateVersion = homeManagerStateVersion;
              home.user-info = config.users.primaryUser;
            };
            # Add a registry entry for this flake
            nix.registry.my.flake = self;
          }
        )
      ];
    in
    {
      # Current Macbook Pro M1
      darwinConfigurations = rec {
        # TODO refactor darwin.nix to make common or bootstrap configuration
        bootstrap-x86 = makeOverridable darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./system/bootstrap.nix { nixpkgs = nixpkgsConfig; } ];
        };

        bootstrap-arm = bootstrap-x86.override { system = "aarch64-darwin"; };

        muhghazaliakbar = makeOverridable darwinSystem {
          system = "aarch64-darwin";
          modules = nixDarwinCommonModules ++ [
            {
              users.primaryUser = primaryUserInfo;
              networking.computerName = "muhghazaliakbar";
              networking.hostName = "muhghazaliakbar";
              networking.knownNetworkServices = [
                "Wi-Fi"
                "USB 10/100/1000 LAN"
              ];
            }
          ];
        };

      };

      # Overlays --------------------------------------------------------------- {{{

      overlays = import ./modules/overlays inputs nixpkgsConfig;

      # `home-manager` modules
      homeManagerModules = {
        r17-activation = import ./home/activation.nix;
        r17-packages = import ./home/packages.nix;
        r17-shell = import ./home/shells.nix;
        r17-git = import ./home/git.nix;
        r17-devshell = import ./home/devShell.nix;

        home-user-info = { lib, ... }: {
          options.home.user-info =
            (self.commonModules.users-primaryUser { inherit lib; }).options.users.primaryUser;
        };
      };

      commonModules = {
        system = import ./system/system.nix;
        system-shells = import ./system/shells.nix;
        users-primaryUser = import ./modules/user.nix;
        programs-nix-index = import ./system/nix-index.nix;
      };

      # `nix-darwin` modules that are pending upstream, or patched versions waiting on upstream
      # fixes.
      darwinModules = {
        system-darwin = import ./system/darwin/system.nix;
        system-darwin-packages = import ./system/darwin/packages.nix;
        system-darwin-security-pam = import ./system/darwin/security.nix;
        system-darwin-homebrew = import ./system/darwin/homebrew.nix;
        # system-darwin-gpg = import ./system/darwin/gpg.nix;
        # system-darwin-window-manager = import ./system/darwin/wm.nix;
      };
    } // flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = import inputs.nixpkgs-unstable {
        inherit system;
        inherit (nixpkgsConfig) config;
        overlays = with self.overlays; [
          pkgs-master
          pkgs-stable
          apple-silicon
        ];
      };
    });
}
