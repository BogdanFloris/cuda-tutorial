{
  description = "cuda tutorial";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        # Override the shell to use the CUDA-compatible GCC
        devShells.default = pkgs.mkShell.override {
          stdenv = pkgs.cudaPackages.backendStdenv;
        } {
          buildInputs = with pkgs; [
            cudaPackages.cudatoolkit
            cudaPackages.nsight_compute
            clang-tools
            cmake
            gtest
            ninja
          ];
        };
      });
}
