#!/usr/bin/env bash
set -euo pipefail

source /home/ubuntu/yn-build/env.sh
export DEVKITPRO=/opt/devkitpro
export PATH=/opt/devkitpro/tools/bin:/opt/devkitpro/devkitA64/bin:$PATH

BUILD_DIR="/home/ubuntu/y2k-build"
GAME_SRC="/mnt/d/Download/ゆめ2っきver0.129g/ゆめ2っき"
TRANS_SRC="/mnt/d/Download/ynotranslations/2kki"
WORK_DIR="/mnt/d/YumeNikki-Nx"

echo "============================================================"
echo " Starting Yume 2kki (ゆめ2っき) Nintendo Switch NSP Build Pipeline"
echo "============================================================"

echo "[0/6] Setting up build staging environment at $BUILD_DIR..."
mkdir -p "$BUILD_DIR/package/romfs" \
         "$BUILD_DIR/package/exefs" \
         "$BUILD_DIR/package/control" \
         "$BUILD_DIR/tools" \
         "$BUILD_DIR/out" \
         "$BUILD_DIR/nca" \
         "$WORK_DIR/dist"

echo "[1/6] Staging game assets and multi-language translations..."
if [ ! -f "$GAME_SRC/RPG_RT.ldb" ]; then
  echo "Error: Game root not found at $GAME_SRC"
  exit 1
fi
if [ ! -d "$TRANS_SRC" ]; then
  echo "Error: Translations not found at $TRANS_SRC"
  exit 1
fi

# Sync game assets into romfs
rsync -a --delete "$GAME_SRC/" "$BUILD_DIR/package/romfs/"

# Sync 2kki multi-language directory into romfs/Language
mkdir -p "$BUILD_DIR/package/romfs/Language"
rsync -a --delete "$TRANS_SRC/" "$BUILD_DIR/package/romfs/Language/"

# Generate 256x256 Switch Home Menu icon from logo.png if needed
if [ -f /mnt/d/Download/logo.png ]; then
  convert /mnt/d/Download/logo.png -background black -gravity center -resize 236x236 -extent 256x256 -quality 98 "$WORK_DIR/work/icon_2kki_256.jpg"
fi

LANG_ICONS=(
  "AmericanEnglish"
  "BritishEnglish"
  "Japanese"
  "French"
  "German"
  "LatinAmericanSpanish"
  "Spanish"
  "Italian"
  "Dutch"
  "CanadianFrench"
  "Portuguese"
  "Russian"
  "Korean"
  "TraditionalChinese"
  "SimplifiedChinese"
  "BrazilianPortuguese"
)
for lang in "${LANG_ICONS[@]}"; do
  cp "$WORK_DIR/work/icon_2kki_256.jpg" "$BUILD_DIR/package/control/icon_${lang}.dat"
done

# Prepare control.nacp
cp /home/ubuntu/yn-build/package_v2/control/control.nacp "$BUILD_DIR/package/control/control.nacp"
python3 "$WORK_DIR/tools/patch_nacp_2kki.py" "$BUILD_DIR/package/control/control.nacp"

echo "[2/6] Running host unit test for SwitchInput::ApplyPad..."
g++ -std=c++17 -DUSE_SDL=1 \
  -I/home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src \
  -I/home/ubuntu/yn-build/vendor/liblcf-0.8.1/src \
  -I/opt/devkitpro/portlibs/switch/include \
  "$WORK_DIR/tools/tests/test_input_mapping.cpp" \
  -o /tmp/test_input_mapping
/tmp/test_input_mapping

echo "[3/6] Syncing modified engine source and compiling for Switch..."
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/platform/switch/main.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/platform/switch/main.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/platform/switch/input_mapping.h" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/platform/switch/input_mapping.h
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/platform/switch/input_buttons.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/platform/switch/input_buttons.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/game_config.h" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/game_config.h
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/game_config.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/game_config.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/filesystem_stream.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/filesystem_stream.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/scene.h" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/scene.h
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/scene.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/scene.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/scene_save.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/scene_save.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/scene_settings.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/scene_settings.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/scene_language.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/scene_language.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/scene_title.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/scene_title.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/scene_keyguide.h" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/scene_keyguide.h
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/src/scene_keyguide.cpp" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/src/scene_keyguide.cpp
cp "$WORK_DIR/work/src/easyrpg-player-0.8.1.1/CMakeLists.txt" /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1/CMakeLists.txt

cmake -S /home/ubuntu/yn-build/vendor/easyrpg-player-0.8.1.1 -B /home/ubuntu/yn-build/build/switch-player -DPLAYER_WITH_FREETYPE=ON -DPLAYER_WITH_HARFBUZZ=ON
cmake --build /home/ubuntu/yn-build/build/switch-player -j"$(nproc)"

echo "[4/6] Generating ExeFS (main NSO & main.npdm)..."
/opt/devkitpro/tools/bin/elf2nso \
  /home/ubuntu/yn-build/build/switch-player/easyrpg-player.elf \
  "$BUILD_DIR/package/exefs/main"

python3 "$WORK_DIR/tools/build_npdm_2kki.py" \
  "$BUILD_DIR/tools/modern_app.json" \
  "$BUILD_DIR/package/exefs/main.npdm"

echo "[5/6] Packaging NSP with hacBrewPack v3.05..."
cd "$BUILD_DIR/package"
rm -rf hacbrewpack_temp hacbrewpack_nca hacbrewpack_nsp hacbrewpack_backup out nca
mkdir -p out nca

KEYS_FILE="$WORK_DIR/keys/prod.keys"
if [ ! -f "$KEYS_FILE" ]; then
  KEYS_FILE="/mnt/d/Download/SwitchKeys/prod.keys"
fi
if [ ! -f "$KEYS_FILE" ]; then
  echo "Error: Switch prod.keys not found!"
  exit 1
fi

/home/ubuntu/yn-build/tools/hacbrewpack_src/hacBrewPack-master/hacbrewpack \
  --nologo --keepncadir \
  --titleid 0100b2b2c3d40000 \
  -k "$KEYS_FILE" \
  --nspdir ./out --ncadir ./nca > ./hacbrewpack_y2k.log 2>&1

tail -n 25 ./hacbrewpack_y2k.log
cp ./out/0100b2b2c3d40000.nsp "$WORK_DIR/dist/ゆめ2っき_v0.129g.nsp"

echo "[6/6] Verifying output NSP artifact..."
ls -lh "$WORK_DIR/dist/ゆめ2っき_v0.129g.nsp"
sha256sum "$WORK_DIR/dist/ゆめ2っき_v0.129g.nsp"

echo "============================================================"
echo " Build completed successfully! Output: dist/ゆめ2っき_v0.129g.nsp"
echo "============================================================"
