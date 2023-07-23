let
  pkgs = import <nixpkgs> {};

  venvDir = ".venv";
  pythonPackages = pkgs.python39Packages;

  pyPkgs = [
    pythonPackages.python
    pythonPackages.pip
  ];

  apps = with pkgs; [
    git
  ];

  # Runtime libraries used by various pip packages
  # Add neccessary libraries to the list in case of linking errors
  libs = with pkgs; [
    stdenv.cc.cc.lib # libstdc++.so.6
    zlib
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
in
  pkgs.mkShell {
    buildInputs = pyPkgs ++ apps ++ libs;
    shellHook = ''
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
      if [[ ! -d ${venvDir} ]]; then
          ${pythonPackages.python.interpreter} -m venv ${venvDir}
      fi
      source "${venvDir}/bin/activate"
    '';
  }
