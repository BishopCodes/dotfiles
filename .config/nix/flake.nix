{
  description = "Bishops darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, flake-utils, ... }:
    let
      configuration = { pkgs, config, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget

        nixpkgs.config.allowUnfree = true;

        environment.systemPackages = with pkgs;
          [
            aerospace
            # Broken package currently
            # ghostty
            # https://www.elgato.com/us/en/s/downloads
            # https://www.insta360.com/download/insta360-link2
            # obs-studio
            sketchybar
            sketchybar-app-font
            #keymapp
            #soapui
            air
            asdf
            awscli2
            bat
            bun
            # cargo
            clang
            clang-tools
            cmake
            dbeaver-bin
            dive
            dotnet-sdk_8
            dotenvx
            duf
            dust
            eza
            fastfetch
            fd
            fira-code
            fnm # Replacement for node version manager
            fzf
            gcc
            git
            gitflow
            gnupg
            go
            # handbrake
            hadolint
            # helm
            istioctl
            jankyborders
            jdk
            jujutsu
            jq
            keepassxc
            keycastr
            keystore-explorer
            kotlin
            kubectl
            lazydocker
            lazygit
            lazyjj
            # libpq
            lldb
            # localstack
            lua-language-server
            mas
            maven
            mkalias
            neovim
            libiconv
            nil
            nodejs
            # New package broken leaving to fix later
            # (obsidian.overrideAttrs (_: { 
            #   version = "1.8.7";
            #   src = fetchFromGitHub {
            #     owner = "obsidianmd";
            #     repo = "obsidian-releases";
            #     rev = "8a4cc30ac573e30910d294d602f6fc8fe29d37d2";
            #     sha256 = "sha256-jrvzwmdqtl/dMLOu9Q2sTLPwIIpbJNKKWKt0AtagRkE=";
            #   };
            # }))
            # obsidian # requires allowUnfree
            ocaml
            ollama
            omnisharp-roslyn
            opam
            openssl
            opentofu
            pkg-config
            podman
            podman-compose
            podman-desktop
            podman-tui
            postgresql_16
            pulumi-bin
            python3
            pqrs
            raycast
            redocly
            ripgrep
            # rust-analyzer
            # rustc
            # rustfmt
            rustup
            spacectl
            spotify
            spotifyd
            sqlc
            stow
            stylua
            tailwindcss
            tailwindcss-language-server
            terraform
            tflint
            tldr
            # tmux
            yarn
            xh
            zig
            zinit
            zlib
            zls
            zoxide
            zsh-autosuggestions
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
            # "odpi"
            "instantclient-basic"
            "instantclient-sqlplus"
            "docker-slim"
            "handbrake"
            "helm"
            "watch"
            # "spacelift-io/spacelift/spacectl"
          ];
          taps = [
            "InstantClientTap/instantclient"
          ];
          casks = [
            "ghostty"
              "obs"
            # "nikitabobko/tap/aerospace"
          ];
          masApps = {
            "Windows App" = 1295203466;
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

        # Limit with nix and sudo 
        # Run manually launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.nixos.sketchybar.plist

        # nix.configureBuildUsers = true;
        # nix.useDaemon = true;
        nix.enable = false;

        # https://mynixos.com/nix-darwin/options/system.defaults
        # https://nix-darwin.github.io/nix-darwin/manual/index.html
        system.defaults = {
          dock = {
            autohide = false;
            persistent-apps = [
              {
                app = "/System/Applications/Calendar.app";
              }
              {
                spacer = {
                  small = false;
                };             
              }
              {
                app = "/Applications/Ghostty.app";
              }
              {
                app = "/Applications/Nix Apps/dbeaver.app";
              }
              {
                app = "/Applications/Nix Apps/Spotify.app";
              }
            ];
          };

          finder = {
            FXPreferredViewStyle = "clmv";
            AppleShowAllExtensions = true;
          };

          NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            "com.apple.swipescrolldirection" = false;
            NSWindowShouldDragOnGesture = true;
          };

          CustomUserPreferences = {
            "com.apple.screencapture" = {
              location = "clipboard";
              type = "png";
            };
          };

          CustomSystemPreferences = {
            "com.apple.Safari" = {
              "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" =
                true;
            };
            "com.microsoft.rdc.macos".ClientSettings__EnforceCredSSPSupport = 0;
            "com.apple.SoftwareUpdate" = {
              AutomaticCheckEnabled = true;
              ScheduleFrequency = 1;
              AutomaticDownload = 1;
              CriticalUpdateInstall = 1;
            };
            "com.apple.dock".ExposeGroupApps = false;
            "com.apple.spaces".SpansDisplays = true;
          };
        };

        # Auto upgrade nix package and the daemon service
        # services.nix-daemon.enable = true;
        # Built in services
        # services.aerospace.enable = true;
        # services.sketchybar.enable = true;
        # nix.package = pkgs.nix;}

        # Necessary for using flakes on this system.
        nix.settings = {
          experimental-features = "nix-command flakes";
        };

        # Enable alternative shell support in nix-darwin.
        programs.zsh.enable = true;
        programs.tmux.enable = true;
        programs.tmux.enableFzf = true;
        programs.tmux.enableVim = true;
        programs.zsh.enableFzfGit = true;
        programs.zsh.enableFzfHistory = true;
        programs.zsh.enableFzfCompletion = true;
        programs.zsh.enableGlobalCompInit = true;
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # security.pam.enableSudoTouchIdAuth = true;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
       
        launchd.daemons.nixsudo.serviceConfig.GroupName = "wheel";
      };

    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        overrides = (builtins.fromTOML (builtins.readFile (self + "/rust-toolchain.toml")));
      in {
        # Add your devShell for Rust:
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = with pkgs; [
            clang
            llvmPackages.bintools
            rustup
          ];

          RUSTC_VERSION = overrides.toolchain.channel;
          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
          shellHook = ''
            export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
            export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
          '';

          RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [ ]);
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (buildInputs ++ nativeBuildInputs);
          BINDGEN_EXTRA_CLANG_ARGS =
            (builtins.map (a: ''-I"${a}/include"'') [ pkgs.glibc.dev ])
            ++ [
              ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
              ''-I"${pkgs.glib.dev}/include/glib-2.0"''
              ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
            ];
        };
      }
    ) // {
      # Add darwin system config at the top level
      darwinConfigurations."work" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
      darwinPackages = self.darwinConfigurations."work".pkgs;
    };
}
