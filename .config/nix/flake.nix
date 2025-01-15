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

        environment.systemPackages = with pkgs;
          [
            mkalias
            neovim
            vimPlugins.blink-cmp
            obsidian # requires allowUnfree
            tmux
            fira-code
            raycast
            clang-tools
            cmake
            go
            lua-language-server
            rustup
            rustc
            cargo
            rustfmt
            rust-analyzer
            sqlc
            stylua
            tailwindcss
            tailwindcss-language-server
            zoxide
            git
            nil
            air
            awscli
            opentofu
            tflint
            ripgrep
            stow
            zig
            zls
            lldb
            dotnet-sdk_8
            omnisharp-roslyn
            maven
            jdk
            kotlin
            zlib
            pulumi-bin
            nodejs
            jq
            kubectl
            python3
            openssl
            bun
            eza
            bat
            podman
            podman-desktop
            podman-compose
            #soapui
            dbeaver-bin
            #obs-studio
            keycastr
            #keymapp
            ollama
            ocaml
            opam
            localstack
            keepassxc
            keystore-explorer
            zsh-autosuggestions
            fzf
            pkg-config
            zinit
            spotify
            # https://www.insta360.com/download/insta360-link2
            # https://www.elgato.com/us/en/s/downloads
          ];


        environment.variables = {
          # RUSTUP_HOME = "$HOME/.rustup";
          # CARGO_HOME = "$HOME/.cargo";
          FLAKE = "$HOME/dotfiles/nix";
        };

        homebrew = {
          enable = true;
          brews = [
            "mas"
            "stow"
            "sketchybar"
          ];
          taps = [
            "FelixKratz/formulae"
          ];
          casks = [
            "ghostty"
            "nikitabobko/tap/aerospace"
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
          pkgs.nerd-fonts.jetbrains-mono
        ];

        system.activationScripts.applications.text =
          let
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
            while read -r src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
            '';
        #
        #       home-manager.backupFileExtension = "backup";
        #         home-manager.useGlobalPkgs = true;
        # home-manager.useUserPackages = true;


        # nix.configureBuildUsers = true;
        nix.useDaemon = true;

        system.defaults = {
          # mynixos.org
          dock.autohide = false;
          finder.FXPreferredViewStyle = "clmv";
          finder.AppleShowAllExtensions = true;
          dock.persistent-apps = [
            "/System/Applications/Calendar.app"
          ];
        };

        system.defaults.CustomUserPreferences = {
          NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            WebKitDeveloperExtras = true;
            "com.apple.swipescrolldirection" = false;
          };
          "com.apple.screencapture" = {
            location = "clipboard";
            type = "png";
          };
          "com.apple.SoftwareUpdate" = {
            AutomaticCheckEnabled = true;
            # Check for software updates daily, not just once per week
            ScheduleFrequency = 1;
            # Download newly available updates in background
            AutomaticDownload = 1;
            # Install System data files & security updates
            CriticalUpdateInstall = 1;
          };
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

        # security.pam.enableSudoTouchIdAuth = true;

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
          # home-manager.users."Dale.Bishop" = import ./home.nix;
          #   # home-manager.users.Dale.Bishop = {
          #   #   home.file = {
          #   #     ".zshrc".source =  ~/dotfiles/.zshrc;
          #   #     ".config/tmux.conf".source = ~/dotfiles/.config/tmux/tmux.conf;
          #   #     ".config/aerorospace/aerospace.toml".source = ~/dotfiles/.config/aerospace/aerospace.toml;
          #   #     ".config/ghostty/config".soruce = ~/dotfiles/.config/ghostty/config;
          #   #     ".config/borders/boardersrc".source = ~/dotfiles/.config/borders/bordersrc;
          #   #     ".config/nvim".source = ~/dotfiles/.config/nvim;
          #   #     ".config/sketchybar/sketchybarrc".source = ~/dotfiles/.config/sketchybar/sketchybarrc;
          #   #   };
          #   # };
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
