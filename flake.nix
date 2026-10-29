{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-android"
        "armv7a-android"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
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
            buildToolsVersions = [ "36.0.0" "37.0.0" ];
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
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              flutter
              androidSdk
              jdk17
              gradle
              clang
              cmake
              ninja
              pkg-config
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
