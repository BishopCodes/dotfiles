# Flake-integrated standalone WeasyPrint package for aarch64-darwin
# Place this inside your flake and use `weasyprintBin` in systemPackages or expose via `apps`.

{ pkgs }:

let
  gtkLibs = with pkgs; [
    glib
    gobject-introspection
    cairo
    pango
    gdk-pixbuf
    harfbuzz
    freetype
  ];

  gtkLibPaths = pkgs.lib.makeLibraryPath gtkLibs;

in pkgs.stdenv.mkDerivation {
  pname = "weasyprint-standalone";
  version = "65.1";

  src = pkgs.emptyDirectory;

  buildInputs = gtkLibs ++ [
    (pkgs.python311.withPackages (ps: with ps; [
      ps.pip
      ps.setuptools
      ps.wheel
    ]))
  ];

  installPhase = ''
    export HOME=$(mktemp -d)
    ${pkgs.python311.interpreter} -m venv $out/venv
    source $out/venv/bin/activate

    # Runtime lib setup
    export DYLD_LIBRARY_PATH=${gtkLibPaths}:$DYLD_LIBRARY_PATH

    pip install weasyprint==65.1

    mkdir -p $out/bin
    ln -s $out/venv/bin/weasyprint $out/bin/_weasyprint

    # Runtime wrapper
    cat > $out/bin/weasyprint <<EOF
    #!/bin/sh
    export DYLD_LIBRARY_PATH=${gtkLibPaths}:\$DYLD_LIBRARY_PATH
    exec "$out/bin/_weasyprint" "\$@"
EOF
    chmod +x $out/bin/weasyprint
  '';

  meta = {
    description = "Standalone WeasyPrint 65.1 with GTK libs wrapped for macOS";
    platforms = [ "aarch64-darwin" ];
    license = pkgs.lib.licenses.bsd3;
  };
}

