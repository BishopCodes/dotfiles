{
  packageOverrides = pkgs: {
    nix = pkgs.nix.override {
      enableFlakes = true;
      enableNixCommand = true;
    };
  };
}
