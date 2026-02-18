{
  description = "Bishops darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  # outputs = inputs@{ self, nix-darwin, nixpkgs, flake-utils, nix-homebrew, homebrew-core,
  # homebrew-cask, ... }:
  outputs = inputs@{ self, nix-darwin, nixpkgs, flake-utils, ...}:
    let
      system = "aarch64-darwin";

      configuration = { pkgs, config, ... }:
        # List packages installed in syste profile. To search by name, run:
        # $ nix-env -qaP | grep wget

        # nixpkgs.config = {
        #   allowUnfree = true;
        #   allowBroken = true;
        # };
        let
          npmGlobalPackage = pkgName: pkgs.stdenv.mkDerivation {
            pname = builtins.replaceStrings [ "@" "/" ] [ "" "-" ] pkgName;
            version = "latest";
            src = pkgs.emptyDirectory;

            buildInputs = [ pkgs.nodejs pkgs.cacert ];

            installPhase = ''
            export HOME=$(mktemp -d)
            export NODE_EXTRA_CA_CERTS=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

            mkdir -p $out/lib/node_modules
            mkdir -p $out/bin

            npm install -g ${pkgName} --unsafe-perm --prefix $out

            pkg_dir="$out/lib/node_modules/${pkgName}"

            if [ -d "$pkg_dir" ]; then
            binField=$(node -p "let b=require('$pkg_dir/package.json').bin; typeof b === 'object' ? JSON.stringify(b) : b")
            if [ ! -z "$binField" ]; then
            echo "Discovered bin field: $binField"
            if echo "$binField" | grep -q '{'; then
            node <<EOF
            const bins = require('$pkg_dir/package.json').bin;
            const fs = require('fs');
            const path = require('path');
            for (const name in bins) {
            const target = path.resolve('$pkg_dir', bins[name]);
            const link = path.join('$out', 'bin', name);
            try {
            if (!fs.existsSync(link)) {
            fs.symlinkSync(target, link);
            console.log('Linked', link, '→', target);
            } else {
            console.log('Skipped existing link:', link);
            }
            } catch (e) {
            console.error('Failed to symlink:', link, '→', target);
            console.error(e);
            process.exit(1);
            }
            }
            EOF
            else
            binPath=$(node -p "require('$pkg_dir/package.json').bin")
            cleanedPath=$(echo "$binPath" | sed 's|^\./||')
            ln -s "$pkg_dir/$cleanedPath" "$out/bin/$(basename "$cleanedPath")"
            fi
            fi
            fi
            '';          
          };

          # gtkLibs = with pkgs; [
          #   glib
          #   gobject-introspection
          #   cairo
          #   pango
          #   gdk-pixbuf
          #   harfbuzz
          #   freetype
          #   fontconfig
          # ];

      #     weasyprintBin = pkgs.stdenv.mkDerivation {
      #       pname = "weasyprint-standalone";
      #       version = "65.1";
      #
      #       src = pkgs.emptyDirectory;
      #
      #       buildInputs = gtkLibs ++ [
      #         (pkgs.python311.withPackages (ps: with ps; [
      #           ps.pip
      #           ps.setuptools
      #           ps.wheel
      #         ]))
      #       ];
      #
      #       installPhase = ''
      # export HOME=$(mktemp -d)
      # ${pkgs.python311.interpreter} -m venv $out/venv
      # source $out/venv/bin/activate
      #
      # export DYLD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath gtkLibs}:$DYLD_LIBRARY_PATH"
      #
      # pip install weasyprint==65.1
      #
      # mkdir -p $out/bin
      # ln -s $out/venv/bin/weasyprint $out/bin/_weasyprint
      #
      # cat > $out/bin/weasyprint <<EOF
      # #!/bin/sh
      # export DYLD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath gtkLibs}:\$DYLD_LIBRARY_PATH"
      # exec "$out/bin/_weasyprint" "\$@"
      # EOF
      # chmod +x $out/bin/weasyprint
      # '';
      #
      #       meta = {
      #         description = "Standalone WeasyPrint 65.1 with GTK libs wrapped for macOS";
      #         platforms = [ "aarch64-darwin" ];
      #         license = pkgs.lib.licenses.bsd3;
      #       };
      #     };
          # workbrew broke things so managing it this way now
          myBrew = {
            brewPrefix = "/opt/workbrew";
            brews = [
              "mas"
              "instantclient-basic"
              "instantclient-sqlplus"
              "docker-slim"
              "handbrake"
              "helm"
              "watch"
              "gemini-cli"
              "node-build"
              "hammerspoon"
              "luarocks"
              "pnpm"
              "anomalyco/tap/opencode"
              "pandoc"
              "basictex"
              "spotify_player"
              "fjira"
              "huseyinbabal/tap/taws"
              "steveyegge/beads/bd"
              "krunkit"
              # "commitgenius"
            ];
            taps = [
              "InstantClientTap/instantclient"
              "bannawandoor27/Commitgenius"
              "slp/krunkit"
            ];
            casks = [
              # "ghostty"
              # "obs"
              # "keymapp"
            ];
            masApps = {
              "Windows App" = 1295203466;
            };
          };
        in { 
          environment.systemPackages = with pkgs;
            [
              (npmGlobalPackage "oc")
              # darwin.apple_sdk.frameworks.SystemConfiguration
              # darwin.apple_sdk.frameworks.CoreFoundation
              # darwin.apple_sdk.frameworks.Security
              aerospace
              asciinema
              ani-cli
              amazon-q-cli
              # Broken package currently
              # ghostty
              # https://www.elgato.com/us/en/s/downloads
              # https://www.insta360.com/download/insta360-link2
              # obs-studio
              # atuin
              gh
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
              cz-cli
              devcontainer
              devbox
              d2
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
              gnupg1
              go
              # handbrake
              hadolint
              iftop
              # iotop
              macpm
              btop
               # wavemon
              grex
              pass
              keepassxc
              # krunkit
              python313Packages.howdoi
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
              kew
              kubectl
              lazydocker
              lazygit
              lazyjj
              # libpq
              libsixel
              lldb
              llvmPackages.bintools
              # localstack
              lua5_1
              lua-language-server
              luajit
              luajitPackages.luarocks
              marp-cli
              mas
              maven
              mkalias
              neovim
              nodenv
              libiconv
              librespot
              navi
              nil
              nodejs_24
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
              memos     
              ocaml
              ocamlPackages.ocaml-lsp
              ollama
              omnisharp-roslyn
              opam
              openssl
              opentofu
              opencommit
              # opencode # AI-powered coding assistant for terminal
              # pingu 
              pkg-config
              podman
              podman-compose
              podman-desktop
              podman-tui
              postgresql_16
              # presenterm
    #           (presenterm.overrideAttrs (oldAttrs: {
    #             nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    #             buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.d2 ];
    #             cargoBuildFlags = (oldAttrs.cargoBuildFlags or []) ++ [ "--features" "d2" ];
    #             postInstall = (oldAttrs.postInstall or "") + ''
    # wrapProgram $out/bin/presenterm \
    #   --set DYLD_LIBRARY_PATH ${pkgs.libsixel}/lib
    #             '';
    #           }))
              pulumi-bin
              python3
              pqrs
              raycast
              redocly
              riff
              ripgrep
              rust-analyzer
              # rustc
              # rustfmt
              rustup
              ruby
              bundler
              slides
              spacectl
              spotify
              spotifyd
              # spotify-player
              sqlc
              stow
              stylua
              taskwarrior3
              tailwindcss
              tailwindcss-language-server
              terraform
              tflint
              tldr
              # tmux
              # gpgme
              yarn
              # weasyprintBin
              vue-language-server
              xh
              yq
              zig
              zinit
              zlib
              zls
              zoxide
              zsh-autosuggestions
            ];

          # programs.zsh.shellInit = ''
          #   # Workbrew setup
          #   export HOMEBREW_BREW_WRAPPER=/usr/local/bin/brew
          #   export HOMEBREW_FORCE_BREW_WRAPPER=/usr/local/bin/brew
          # '';

          security.sudo.extraConfig = ''
          Defaults env_keep += "WORKBREW_HOME HOMEBREW_BREW_WRAPPER HOMEBREW_FORCE_BREW_WRAPPER"
          Defaults secure_path="/opt/workbrew/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
          '';

          environment.variables = {
            WORKBREW_HOME = "/opt/workbrew";
            HOMEBREW_BREW_WRAPPER = "/opt/workbrew/bin/brew";
            HOMEBREW_FORCE_BREW_WRAPPER = "/opt/workbrew/bin/brew";
            FLAKE = "$HOME/dotfiles/nix";
          };

          environment.systemPath = [
            "/opt/workbrew/bin"
            "/opt/workbrew/sbin" 
          ];

          # homebrew = {
          #   brewPrefix = "/opt/workbrew";
          #   enable = false;
          #   brews = [
          #     # "mas"
          #     # "stow"
          #     # "sketchybar"
          #     # "odpi"
          #     "instantclient-basic"
          #     "instantclient-sqlplus"
          #     "docker-slim"
          #     "handbrake"
          #     "helm"
          #     "watch"
          #     # "spacelift-io/spacelift/spacectl"
          #   ];
          #   taps = [
          #     "InstantClientTap/instantclient"
          #   ];
          #   casks = [
          #     "ghostty"
          #     "obs"
          #     "keymapp"
          #     # "nikitabobko/tap/aerospace"
          #   ];
          #   masApps = {
          #     "Windows App" = 1295203466;
          #   };
          #   # Will remove anything not declared here
          #   onActivation = {
          #     cleanup = "zap";
          #     autoUpdate = true;
          #     upgrade = true; 
          #   };
          #   # global.brewfile = true;
          # };

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
            # Workbrew
            echo "WORKBREW ACTIVATION SCRIPT RAN at $(date)" >> /var/log/workbrew.log
            export WORKBREW_HOME=/opt/workbrew
            export HOMEBREW_BREW_WRAPPER=/opt/workbrew/bin/brew
            export HOMEBREW_FORCE_BREW_WRAPPER=/opt/workbrew/bin/brew
            export PATH=/opt/workbrew/bin:$PATH

            echo "[workbrew] Ensuring brew taps..." | tee -a /var/log/workbrew.log
                ${pkgs.lib.concatStringsSep "\n" (map (tap: "brew tap ${tap}") myBrew.taps)}

            echo "[workbrew] Installing brews..." | tee -a /var/log/workbrew.log
                ${pkgs.lib.concatStringsSep "\n" (map (pkg: "brew install ${pkg}") myBrew.brews)}

            echo "[workbrew] Installing casks..." | tee -a /var/log/workbrew.log
                ${pkgs.lib.concatStringsSep "\n" (map (cask: "brew install --cask ${cask}") myBrew.casks)}

            # echo "[workbrew] Installing Mac App Store apps..." | tee -a /var/log/workbrew.log
            # ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: id: "mas install ${toString id}  # ${name}") myBrew.masApps)}
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

          nix.enable = false;

          system.primaryUser = "Dale Bishop";

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
                  app = "/ApplicationsGhostty.app";
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
          programs.zsh.enableGlobalCompInit = false;
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
      darwinConfigurations."work" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                lazyjj = prev.lazyjj.overrideAttrs (old: {
                  doCheck = false;
                });
                spotify = prev.spotify.overrideAttrs (old: {
                  src = prev.fetchurl {
                    url = "https://download.scdn.co/SpotifyARM64.dmg";
                    sha256 = "sha256-0gwoptqLBJBM0qJQ+dGAZdCD6WXzDJEs0BfOxz7f2nQ="; 
                  };
                });
              })
            ];
            nixpkgs.config.allowBroken = true;
            nixpkgs.config.allowUnfree = true;
          }
          # nix-homebrew.darwinModules.nix-homebrew
          # {
          #   nix-homebrew = {
          #     # Install Homebrew under the default prefix
          #     enable = true;
          #
          #     enableRosetta = false;
          #
          #     # User owning the Homebrew prefix
          #     user = "Dale Bishop";
          #
          #     taps = {
          #       "homebrew/homebrew-core" = homebrew-core;
          #       "homebrew/homebrew-cask" = homebrew-cask;
          #     };
          #
          #     # Automatically migrate existing Homebrew installations
          #     autoMigrate = false;
          #   };
          # }
          configuration 
        ];
      };
      darwinPackages = self.darwinConfigurations."work".pkgs;
    };
}
