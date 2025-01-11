{
  description = "Bishops darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  # outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages =
        [ 
            pkgs.mkalias
            pkgs.neovim
            pkgs.obsidian # requires allowUnfree
            pkgs.tmux
            pkgs.fira-code
            pkgs.raycast
        ];

      homebrew = {
          enable = true;
          brews = [
            "mas"
            "stow"
          ];
          casks = [
            "ghostty"
        ];
          masApps = {
          # "FriendlyName" = "AppleAppStoreAppId"
        };
        # Will remove anything not declared here
        # onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
        };

      fonts.packages = [
          (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];

      system.activationScripts.applications.text = let 
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
        '';

      home-manager.backupFileExtension = "backup";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      system.defaults = {
          # mynixos.org
          dock.autohide = true;
        };

      # Auto upgrade nix package and the daemon service
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;}

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."work" = nix-darwin.lib.darwinSystem {
      modules = [ 
          configuration 
          # home-manager.darwinModules.home-manager {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.users.Dale.Bishop = {
          #     home.file = {
          #       ".zshrc".source =  ~/dotfiles/.zshrc;
          #       ".config/tmux.conf".source = ~/dotfiles/.config/tmux/tmux.conf;
          #       ".config/aerorospace/aerospace.toml".source = ~/dotfiles/.config/aerospace/aerospace.toml;
          #       ".config/ghostty/config".soruce = ~/dotfiles/.config/ghostty/config;
          #       ".config/borders/boardersrc".source = ~/dotfiles/.config/borders/bordersrc;
          #       ".config/nvim".source = ~/dotfiles/.config/nvim;
          #       ".config/sketchybar/sketchybarrc".source = ~/dotfiles/.config/sketchybar/sketchybarrc;
          #     };
          #   };
          # }
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true; # Apple Silicon
              user = "Dale.Bishop";
              autoMigrate = true; # If already install on system
            };
          }
        ];
    };
    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."work".pkgs;
  };
}
