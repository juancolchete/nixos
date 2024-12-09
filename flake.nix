{
  description = "https://mlabs.slab.com/posts/solana-exercise-g4y1drpb";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };
      solana-cli = {stdenv, fetchurl, fetchzip, lib, autoPatchelfHook, pkgs }: stdenv.mkDerivation rec {
        name = "solana-${version}";
        version = "1.10.3";
        filename = "solana-release-x86_64-unknown-linux-gnu.tar.bz2";
        src = fetchzip {
          url = "https://github.com/solana-labs/solana/releases/download/v${version}/${filename}";
          sha256 = "sha256-jOUCyK7spTeEZz+h2hxfGpDkZ+2pYbyUFzlQ20c1zv4=";
        };
        nativeBuildInputs = [ autoPatchelfHook pkgs.makeWrapper ];
        buildInputs = with pkgs; [
          sgx-sdk
          ocl-icd
          eudev
          rustup
          stdenv.cc.cc
        ];

        installPhase = ''
          mkdir -p $out;
          cp -r bin $out;
          mkdir -p $out/bin/sdk/;
          ln -s "${solana-bpf-tools-pkg}" $out/bin/sdk/bpf;
          chmod 0755 -R $out;
        '';

        meta = with lib; {
          homepage = "https://docs.solana.com/cli/install-solana-cli-tools#download-prebuilt-binaries";
          platforms = platforms.linux;
        };
      };

      solana-bpf-tools = {stdenv, fetchurl, fetchzip, lib, autoPatchelfHook, pkgs }: stdenv.mkDerivation rec {
        name = "solana-bpf-tools-${version}";
        version = "1.23";
        src = fetchzip {
          url = "https://github.com/solana-labs/bpf-tools/releases/download/v${version}/solana-bpf-tools-linux.tar.bz2";
          sha256 = "sha256-4aWBOAOcGviwJ7znGaHbB1ngNzdXqlfDX8gbZtdV1aA=";
          stripRoot = false;
        };

        nativeBuildInputs = [ autoPatchelfHook ];
        buildInputs = with pkgs; [
          zlib
          stdenv.cc.cc
          openssl
        ];

        installPhase = ''
          mkdir -p $out;
          cp -r $src/llvm $out;
          cp -r $src/rust $out;
          chmod 0755 -R $out;
        '';

        meta = with lib; {
          homepage = "https://github.com/solana-labs/bpf-tools/releases";
          platforms = platforms.linux;
        };
      };
      solana-cli-pkg = (pkgs.callPackage solana-cli {});
      solana-bpf-tools-pkg = (pkgs.callPackage solana-bpf-tools {});
    in with pkgs; {
      devShell = mkShell {
        buildInputs = [
          rust-analyzer
          solana-cli-pkg 
          solana-bpf-tools-pkg
          cargo-edit
          rustup
        ];
      };
      nixosConfigurations = {
        my-system = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix  # Your NixOS configuration file
          ];
        };
      };
    }
  );
}

