let
  pkgs = import <nixpkgs> {};

  libs = with pkgs; [
    zlib
    stdenv.cc.cc.lib
    glib
    glib.out
    libglvnd
    xorg.libX11
    xorg.libXext
    xorg.libXau
    xorg.libSM
    xorg.libICE
    xorg.libxcb
  ];

  apps = with pkgs; [
    python39
    python39Packages.pip
    git
  ];

  shell = pkgs.mkShell {
    buildInputs = libs ++ apps;
    shellHook = ''
      # Add the library paths for libstdc++.so.6 and libz.so.1
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath libs}"
      
      # Create a symlink to /lib64/libcuda.so.1 and add to LD_LIBRARY_PATH
      NIX_LIB_DIR=$TMPDIR/libs_nix_links
      mkdir -p $NIX_LIB_DIR
      CUDA_RUNTIME_LIB=libcuda.so.1
      if [[ ! -f "$NIX_LIB_DIR/$CUDA_RUNTIME_LIB" ]]; then
          ln -s /lib64/$CUDA_RUNTIME_LIB $NIX_LIB_DIR/$CUDA_RUNTIME_LIB
      fi
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NIX_LIB_DIR"

      # Activate the virtual environment if exists
      if [[ -f .venv/bin/activate ]]; then
          source .venv/bin/activate
      fi
    '';
  };
in
  shell