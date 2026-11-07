{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [ rust-overlay.overlays.default ];
              config = {
                android_sdk.accept_license = true;
                allowUnfree = true;
              };
            }
          )
        );
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
      devShells = forAllSystems (
        pkgs:
        let
          ndkVersion = "29.0.14206865";
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            ndkVersions = [
              ndkVersion
              "28.2.13676358" # required by one of dependencies (possibly jni)
            ];
            platformVersions = [ "37" ];
            buildToolsVersions = [
              "36.0.0"
              "37.0.0"
            ];
            abiVersions = [
              "arm64-v8a"
              "armeabi-v7a"
              "x86_64"
            ];
            cmakeVersions = [
              "3.22.1"
            ];
            includeNDK = true;
          };

          androidSdk = androidComposition.androidsdk;

          rustToolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "rust-analyzer"
              "clippy"
              "rustfmt"
            ];
            targets = [
              "aarch64-linux-android"
              "armv7-linux-androideabi"
              "x86_64-linux-android"
            ];
          };

        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              flutter
              androidSdk
              jdk17
              gradle
              clang
              cmake
              ninja
              pkg-config
              rustToolchain
              cargo-ndk
            ];

            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            ANDROID_NDK = "${androidSdk}/libexec/android-sdk/ndk/${ndkVersion}";
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";

            shellHook = ''
              export FLUTTER_ROOT="${pkgs.flutter}"
            '';
          };
        }
      );
    };
}
