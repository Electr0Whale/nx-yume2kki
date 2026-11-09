# nx-yume2kki: Yume 2kki (ゆめ2っき) for Nintendo Switch

[![Platform](https://img.shields.io/badge/Platform-Nintendo%20Switch-E60012.svg?style=flat-square&logo=nintendoswitch)](https://github.com/Electr0Whale/nx-yume2kki)
[![Engine](https://img.shields.io/badge/Engine-EasyRPG%20Player%200.8.1.1%20(Customized)-3B5998.svg?style=flat-square)](https://easyrpg.org/)
[![Base Game](https://img.shields.io/badge/Base%20Game-Yume%202kki%20ver0.129g+-blueviolet.svg?style=flat-square)](https://wikiwiki.jp/yumenikki-g3/)
[![Translations](https://img.shields.io/badge/Translations-ynoproject%20(13%20Languages)-2ea44f.svg?style=flat-square)](https://github.com/ynoproject/ynotranslations)
[![Title ID](https://img.shields.io/badge/Title%20ID-0100B2B2C3D40000-orange.svg?style=flat-square)](#)

A native, self-contained, commercial-grade port of the monumental RPG Maker 2000 fangame **《ゆめ2っき》(Yume 2kki)** for the **Nintendo Switch** (Horizon OS 18/19/20+ / Atmosphère).

This port is built on top of a deeply customized fork of **EasyRPG Player 0.8.1.1**, engineered to deliver an authentic handheld and docked console experience with native multi-language support, official encrypted NAND saves, modern gamepad controls, and pixel-perfect integer scaling.

---

## 🌟 Key Features

### 1. Full Multi-Language System (13 Languages)
Integrated with the community localization repository **[ynoproject/ynotranslations](https://github.com/ynoproject/ynotranslations)**:
- **13 Languages Supported**:
  - `Japanese` (日本語, original base game)
  - `Simplified Chinese` (简体中文 - 《梦２记》 by 梦二记汉化组)
  - `English` (Localization by FlashfyreDev)
  - `Korean` (한국어 - 《유메2키》 by YNO Korean community)
  - `Spanish` (Español by FukoSan)
  - `French` (Français by French community)
  - `Brazilian Portuguese` (Português by ★ Kong ★)
  - `Russian` (Русский)
  - `Polish` (Polski by krossower1)
  - `Romanian` (Română by nekhnona & CDMilky)
  - `Ukrainian` (Українська by Artyomak & delta416)
  - `Vietnamese` (Tiếng Việt by VioletNeiv)
  - `toki pona` (musi ni li kepeken sitelen pona)
- **Automatic Console Language Detection**: At startup, `libnx` reads the Switch system language. If no custom language has been chosen, the game automatically selects the matching native language without prompt dialogs.
- **Dynamic 16-Region Home Menu Title (NACP)**:
  - On Japanese consoles: **《ゆめ2っき》** (Author: ゆめ2っき制作者有志)
  - On Simplified Chinese consoles: **《梦２记》** (Author: 梦2记制作组)
  - On Traditional Chinese consoles: **《夢２記》** (Author: 夢2記製作組)
  - On Korean consoles: **《유메2키》** (Author: 유메2키 제작진)
  - On English and other European consoles: **《Yume 2kki》** (Author: Yume 2kki Developers)
- **On-the-Fly Title Screen Language Selection**: Switch languages directly from the in-game title menu anytime. Text, system fonts, and localized pictures (e.g. Chinese title screen graphic) update immediately and persist to NAND storage.

### 2. Official Encrypted NAND Save Storage (Zero SD Pollution)
- **Multi-User Isolation**: Configured with `StartupUserAccount = 1` in NACP; launches the official Switch user avatar picker on startup.
- **Journaled NAND File System**: Saves and configuration are mounted to `save:/` via `fsMount_SaveData`.
- **Transactional Hard Commits**: Calls `fsdevCommitDevice("save")` immediately upon every save and config change, guaranteeing zero save data loss even upon unexpected exit or pressing the HOME button.
- Fully visible in Switch **System Settings -> Data Management -> Manage Save Data** with support for system-managed deletion and cloud backup.

### 3. Native Gamepad Mapping & Anti-Ghosting Latch Architecture
Custom layout tailored for Joy-Cons, Nintendo Switch Lite, and Switch Pro Controllers:

| Switch Button | RPG Maker Key | Mapped Action | Context & Behavior |
|:---|:---|:---|:---|
| **D-Pad / Left Stick** | Arrow Keys | Movement / Menu Cursor | 4-directional navigation |
| **A** | Z / Enter | **Decision / Investigate / Special Action** | Interact with objects, start dreams, long-press action |
| **B** | X / ESC | **Cancel / Back** | Close windows, cancel choices |
| **Plus (+)** | ESC | **In-Game Menu** | Open menu screen (Effects, Wake up, Inventory) |
| **R** | Shift | **Dash / Auxiliary** | Bicycle/motorcycle acceleration, page toggling |
| **X** | Numpad 9 | **Pinch Cheek / Wake Up** | Pinch cheek to wake from dream |
| **Y** | Numpad 5 | **Drop Effect** | Drop current effect in the Nexus room |
| **L + A** | Numpad 1 | **Effect Special Action 1** | Primary effect action |
| **L + B** | Numpad 3 | **Effect Special Action 2** | Secondary effect action |
| **ZR** | - | **Fast Forward** | Hold to explore large maps at accelerated speed |
| **Minus (-)** | - | **EasyRPG Settings** | Audio volume, renderer settings |

Includes the custom `ModifierState` double-latching algorithm to prevent unintended button chord ghosting.

### 4. Pixel-Perfect Integer Scaling
- **Handheld Mode (720p)**: Strict **3x integer scaling** (960x720), centered.
- **Docked Mode (1080p)**: Strict **4x integer scaling** (1280x960), centered.
- Pure black pillarboxing/letterboxing (`#000000`). Zero bilinear blur or distortion.
- Touchscreen virtual overlays permanently disabled for pure retro pixel aesthetic.

### 5. Advanced Typography & Vector Font Fallback
- Compiled with **FreeType 2** and **HarfBuzz** complex text shaping support.
- Bundled with localized TrueType vector fonts and built-in CJK bitmap glyphs, providing clean, crisp rendering across all 13 supported languages.

---

## 📁 Repository Structure

```text
nx-yume2kki/
├── README.md                                   # This comprehensive guide
├── .gitignore                                  # Production git ignore rules
├── assets/
│   ├── icon_2kki_256.jpg                       # 256x256 HD pixel art Home Menu icon
│   └── logo.png                                # Official Yume 2kki title logo
├── patches/
│   └── easyrpg-player-yume2kki-nx.patch        # Unified 45KB patch for EasyRPG Player 0.8.1.1
└── tools/
    ├── build_yume2kki_nsp.sh                   # Automated end-to-end build & packaging pipeline
    ├── patch_nacp_2kki.py                      # 16-language NACP metadata and NAND save patcher
    ├── build_npdm_2kki.py                      # HOS 20+ compliant NPDM generator (Title ID 0100B2B2C3D40000)
    └── tests/
        └── test_input_mapping.cpp              # Host unit tests for button latching & ghost prevention
```

---

## 🛠️ Build & Packaging Pipeline

### Prerequisites

1. **Host Environment**: Linux / WSL2 (Ubuntu 24.04 LTS recommended).
2. **devkitPro Toolchain**:
   - `devkitA64` (GCC 14+ / 16+)
   - `libnx` (v4.12.0+)
   - `switch-tools` (`elf2nso`, `elf2nro`, `npdmtool`)
   - `switch-mesa`, `switch-glad`, `switch-libdrm_nouveau`
3. **EasyRPG Switch Libraries**:
   - Precompiled static libraries (`liblcf`, `libicu`, `libfmt`, `libmpg123`, `dr_wav`, `libfreetype`, `libharfbuzz`, `libsamplerate`).
4. **Packaging Tool**:
   - `hacBrewPack v3.05+`
   - Nintendo Switch extraction keys (`prod.keys`).
5. **Assets**:
   - Original *Yume 2kki* game folder (e.g. `ver0.129g+`).
   - *ynotranslations* `2kki` directory.

### Building the NSP

1. Place your `prod.keys` in `keys/prod.keys` (or set the path in `build_yume2kki_nsp.sh`).
2. Point `GAME_SRC` to your Yume 2kki game directory and `TRANS_SRC` to the `ynotranslations/2kki` folder.
3. Run the automated build script:

```bash
bash tools/build_yume2kki_nsp.sh
```

The script will automatically:
1. Stage all game assets (4,500+ maps, 1,800+ music files) and 13 language translation trees into the RomFS staging area.
2. Generate all 16 localized Home Menu icon slots from `assets/icon_2kki_256.jpg`.
3. Patch `control.nacp` with official user account requirements and localized titles.
4. Run host unit tests to verify input mapping stability.
5. Cross-compile EasyRPG Player with FreeType and HarfBuzz enabled for AArch64.
6. Generate ExeFS `main` NSO and compliant `main.npdm`.
7. Execute `hacBrewPack` to create standard NCA3 containers and package `ゆめ2っき_v0.129g.nsp`.
8. Output SHA-256 verification checksums.

---

## 🎮 Installation Guide

Due to the massive amount of content in *Yume 2kki* (over 4,500 maps and 1,800 music tracks, resulting in a ~6.8 GB NSP), the file exceeds the 4 GB single-file limit of FAT32 SD cards. Therefore, direct USB installation is recommended:

### Recommended: DBI Installer (via USB MTP)
1. Connect your Nintendo Switch to your PC via a USB-C data cable.
2. Launch **DBI** on your Switch and select **Run MTP Responder**.
3. On your PC, open "This PC" and navigate to the `Switch` portable device.
4. Open drive **`5: MicroSD install`** (or `4: NAND install`).
5. Drag and drop `dist/ゆめ2っき_v0.129g.nsp` into the window. DBI will stream and install the package over USB.
6. Once completed, the game icon will appear directly on your Switch Home Menu!

---

## 📜 Disclaimer & Credits

- **Yume 2kki (ゆめ2っき)**: Created by the Yume 2kki development community and individual asset authors.
- **Yume Nikki (ゆめにっき)**: Original concept by **ききやま (KIKIYAMA)**.
- **EasyRPG Player**: Developed by the EasyRPG team ([easyrpg.org](https://easyrpg.org/)). Licensed under GPLv3.
- **Localization**: Provided by **[ynoproject/ynotranslations](https://github.com/ynoproject/ynotranslations)** and respective language translation teams.
- **Nintendo Switch Homebrew Toolchain**: Built with **devkitPro** and **libnx**.
- This project is a non-commercial homebrew port created for preservation and fan accessibility.

---

## 📄 License

- Custom switch port code, build scripts, and tools are licensed under the **GNU General Public License v3.0 (GPLv3)**.
- Game content and assets belong to their respective creators.
