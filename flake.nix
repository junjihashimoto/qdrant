{
  nixConfig = {
    bash-prompt = "\[sui(__git_ps1 \" (%s)\")\]$ ";
  };
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:junjihashimoto/nixpkgs?rev=484897f5b7e6070d4e5a94e3b25f28b206db0641";
    #nixpkgs.url = "git+file:///home/junji-hashimoto/git/nixpkgs?rev=484897f5b7e6070d4e5a94e3b25f28b206db0641";
    utils.url = "github:numtide/flake-utils";
  };
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, utils, flake-compat  }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {inherit system;};
        qdrant = with pkgs; rustPlatform.buildRustPackage rec {
          pname = "qdrant";
          version = "1.8.4";
          buildInputs = [
            cargo openssl curl zlib protobuf protoc-gen-rust
            rustPlatform.bindgenHook
          ];
          src = ./.;
          GIT_REVISION="1beab3d8aeea53886816ba82615fa3ef5222af3d";
          LIBCLANG_PATH="${llvmPackages.libclang.lib}/lib";
          BINDGEN_EXTRA_CLANG_ARGS="-isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion clang}/include";
          PROTOC = "${protobuf}/bin/protoc";

          env = lib.optionalAttrs stdenv.cc.isClang {
            NIX_LDFLAGS = "-l${stdenv.cc.libcxx.cxxabi.libName}";
          };
          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "quantization-0.1.0" = "sha256-ggVqJiftu0nvyEM0dzsH0JqIc/Z1XILyUSKiJHeuuZs=";
              "tonic-0.9.2" = "sha256-ZlcDUZy/FhxcgZE7DtYhAubOq8DMSO17T+TCmXar1jE=";
              "wal-0.1.2-acaf1b2ebd5de3a871f4d2c48e13fc8788ffa43b" = "sha256-CeHQWHUVsHZvIy/7ftDWzbJ7BTARjsKvWHinEjhgL10=";
              "wal-0.1.2-fad0e7c48be58d8e7db4cc739acd9b1cf6735de0" = "sha256-nBGwpphtj+WBwL9TmWk7qXiEqlIWkgh/2V9uProqhMk=";
            };
          };
          doCheck = false;
        };
      in
      {
        defaultPackage = qdrant;
        devShell = with pkgs; mkShell {
          buildInputs = [
            git
          ];
          shellHook = ''
            source ${git}/share/bash-completion/completions/git-prompt.sh
          '';
        };
      });
}
