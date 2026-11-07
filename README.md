# Stalker – Shadow Fight 2 Save Viewer & Modifier

**Stalker** is a FOSS android utility application designed to **view and optionally modify save files** for the mobile game **Shadow Fight 2**.

> **Disclaimer:** Shadow Fight 2 is a trademark of **Nekki Limited**. This application is not affiliated with, endorsed by, or associated with Nekki in any way. Use of this application is at your own risk. You are solely responsible for ensuring your use complies with Nekki’s terms of service and any applicable laws.

## What It Does

Stalker allows users to inspect and optionally tweak various aspects of their Shadow Fight 2 game progress by interacting with local save files.

### Features

- **View and modify**:
  - Coins
  - Gems
  - Forge materials
- **Enable**:
  - Unlimited energy
  - Dojo disciple
- **Inventory Management**:
  - Add or remove weapons, armor, helmets, and ranged gear
  - Apply enchantments to equipment (Simple, Medium, Mythical)
- **Save records (slots)**:
  - A feature that allows you to manage your progress with separate records - load and save them at any time and access them later whenever you want

> Modifying save files can impact gameplay and may violate the game’s terms of use. Use modification features at your own risk.

## How to install
- Download and install the APK file from [releases](https://github.com/onerdna/stalker/releases) page
- Install either official [Shizuku](https://shizuku.rikka.app/) or [this unofficial fork by thedjchi](https://github.com/thedjchi/Shizuku)
- Start Shizuku service if it's not already running. There is a lot of useful information on the internet on how to do it correctly.
- Launch the app, grant Shizuku permissions.
- Proceed to the additional setup step. Before that, ensure that the game is fully closed. Minimize the app (do not fully close it!), open the game and wait until it fully loads. Then, close the game, go back to the app and tap "Reinitialize" button.


## Official builds
Builds created and signed by the repository's author can be downloaded from [releases](https://github.com/onerdna/stalker/releases). They are considered to be the only official builds; they are signed with onerdna's signing key (SHA256 `2fecba51d988722e707e4dff2d6315491f8a61197a55860a7377f945c44df295`)

## Building yourself
1. Ensure that you have Nix package manager installed with flakes support enabled. In project's root directory, run:
```bash
nix develop .
```
2. In `setup_service/`, build the setup service crate and copy the binaries to the assets folder:
```bash
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 build --release
cp target/aarch64-linux-android/release/setup_service ../assets/binaries/setup_service64
cp target/armv7-linux-androideabi/release/setup_service ../assets/binaries/setup_service32
cp target/x86_64-linux-android/release/setup_service ../assets/binaries/setup_service_x86_64
```
3. In project's root directory, build the flutter application:
```bash
flutter build --release --split-per-abi
```
The output APK files are going to be generated at `build/app/outputs/flutter-apk/`.


### Before using...
- Completely close the game before opening the app.
- If you make any changes, you must tap the 'Save' button for them to take effect.

## FaQ
- **Will there ever be an IOS version?**
  - No.
- **Why does the app use Shizuku?**
  - Shizuku is required to access save files, which aren't normally accessible to regular apps. It's also used to launch the setup service binary.
- **Can you add verified gems, raid consumables or enable damage hacks?**
  - No.

## Troubleshooting
- Tapping 'Reinitialize' after the 'Additional setup' step does nothing.
  1. Make sure that you are following the given instructions.
  2. **Try using** [this Shizuku fork by thedjchi](https://github.com/thedjchi/Shizuku)
  2. For some devices, changing the 'Logger buffer size' in Developer Options from 256K to 8M might help.
  3. For Huawei and Honor devices, you need to enable logcat in the device settings. Search online for: 'enable logcat honor/huawei'
  4. If this does not help, report a bug [here](https://github.com/onerdna/stalker/issues/new?template=additional-setup-bug-report.md)


### Special thanks to:
- [**Shizuku**](https://shizuku.rikka.app/)
- **ShadowFight2dojo community**
  - [Reddit](https://www.reddit.com/r/ShadowFight2dojo/)
---
## By downloading or using this software, you agree to the terms outlined in the [LICENSE](./LICENSE)
