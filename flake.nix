{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    rust-overlay,
    ...
  }: let
    overlays = [
      (import rust-overlay)
    ];

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs systems
      (system: f {pkgs = import nixpkgs {inherit system overlays;};});
  in {
    devShells = forAllSystems ({pkgs}:
      with pkgs; {
        default = mkShell rec {
          buildInputs = [
            (rust-bin.stable."1.88.0".default.override {
              extensions = ["rust-src" "rust-analyzer"];
              targets = ["aarch64-linux-android" "armv7-linux-androideabi"];
            })

            pkg-config
            xorg.libxcb
            alsa-lib
            wayland
            libxkbcommon
            libGL
          ];
          LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
        };
      });
  };
}
