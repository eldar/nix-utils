with import <nixpkgs> {};

mkShell {
  buildInputs = [
    zlib
    stdenv.cc.cc.lib
    python39
    python39Packages.pip
    git
  ];
  shellHook = ''
    # Add the library paths for libstdc++.so.6 and libz.so.1
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${zlib}/lib:${stdenv.cc.cc.lib}/lib"
    
    # Create a symlink to /lib64/libcuda.so.1 and add to LD_LIBRARY_PATH
    CUDA_LIB_DIR=$TMPDIR/cuda_nix_dir
    mkdir -p $CUDA_LIB_DIR
    CUDA_RUNTIME_LIB=libcuda.so.1
    if [[ ! -f "$CUDA_LIB_DIR/$CUDA_RUNTIME_LIB" ]]; then
        ln -s /lib64/$CUDA_RUNTIME_LIB $CUDA_LIB_DIR/$CUDA_RUNTIME_LIB
    fi
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CUDA_LIB_DIR"

    # Activate the virtual environment if exists
    if [[ -f .venv/bin/activate ]]; then
        source .venv/bin/activate
    fi
  '';
}
