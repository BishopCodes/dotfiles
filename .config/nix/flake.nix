{
  description = "Bishops darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, ...}:
    let
      configuration = { pkgs, config, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget

        nixpkgs.config.allowUnfree = true;

        environment.systemPackages = with pkgs;
          [
            #keymapp
            # obs-studio
            #soapui
            air
            awscli
            bat
            bun
            cargo
            clang-tools
            cmake
            dbeaver-bin
            dotnet-sdk_8
            eza
            fira-code
            fzf
            git
            gnupg
            go
            jdk
            jq
            keepassxc
            keycastr
            keystore-explorer
            kotlin
            kubectl
            lldb
            localstack
            lua-language-server
            maven
            mkalias
            neovim
            nil
            nodejs
            obsidian # requires allowUnfree
            ocaml
            ollama
            omnisharp-roslyn
            opam
            openssl
            opentofu
            pkg-config
            dive
            podman-tui
            podman
            podman-compose
            podman-desktop
            pulumi-bin
            python3
            raycast
            ripgrep
            rust-analyzer
            rustc
            rustfmt
            rustup
            spotify
            sqlc
            stylua
            tailwindcss
            tailwindcss-language-server
            tflint
            tmux
            zig
            zinit
            zlib
            zls
            zoxide
            zsh-autosuggestions
            lazygit
            lazydocker
            mas
            stow
            sketchybar
            spacectl
            # ghostty # Broken package currently
            aerospace
            fnm # Replacement for node version manager
            # https://www.insta360.com/download/insta360-link2
            # https://www.elgato.com/us/en/s/downloads
          ];


        environment.variables = {
          FLAKE = "$HOME/dotfiles/nix";
        };

        homebrew = {
          enable = true;
          brews = [
            # "mas"
            # "stow"
            # "sketchybar"
            "odpi"
            "instantclient-basic"
            "instantclient-sqlplus"
            # "spacelift-io/spacelift/spacectl"
          ];
          taps = [
            # "InstantClientTap/instantclient"
          ];
          casks = [
            "ghostty"
            # "nikitabobko/tap/aerospace"
          ];
          masApps = {
            # "FriendlyName" = "AppleAppStoreAppId"
          };
          # Will remove anything not declared here
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
          brewPrefix = "/opt/workbrew/bin";
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
            # Podman desktop config
            USER_HOME=$(eval echo "~dale.bishop")
            CONFIG_DIR="$USER_HOME/.local/share/containers/podman-desktop/configuration"
            CONFIG_FILE="$CONFIG_DIR/settings.json"
            # ${pkgs.lib.getBin pkgs.podman}/bin/podman
            TMP_CONFIG_FILE=$(mktemp)
            mkdir -p "$CONFIG_DIR"
            jq '.["podman.binary.path"] = "/run/current-system/sw/bin/podman"' "$CONFIG_FILE" > "$TMP_CONFIG_FILE"
            mv "$TMP_CONFIG_FILE" "$CONFIG_FILE"
            chown dale.bishop "$CONFIG_FILE"
        '';

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
        nix.settings = {
          experimental-features = "nix-command flakes";
        };

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
        ];
      };
      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."work".pkgs;
    };
}
