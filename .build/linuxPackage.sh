#!/bin/bash
# Builds Vocaluxe and creates a portable Linux package: dist/<name>.tar.gz
#
# The package contains everything that is hard to get in the right version on the different distributions:
#   - the .NET runtime (so no system-wide .NET installation is needed)
#   - the FFmpeg 8 libraries (LGPL build)
#   - the videos of the default theme
# Only portaudio and hidapi have to be installed on the target system.
#
# Usage: .build/linuxPackage.sh [package name]
#   SKIP_BUILD=1          package the existing Output folder without building
#   SKIP_DOTNET_RUNTIME=1 do not bundle the .NET runtime
#   FFMPEG_URL=...        other FFmpeg 8 "shared" build (tar.xz with a lib folder)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ARCH=x64
VERSION="$(git describe --tags --always --exclude Nightly 2>/dev/null || echo notversioned)"
NAME="${1:-Vocaluxe_${VERSION}_Linux_${ARCH}}"
DOTNET_CHANNEL="${DOTNET_CHANNEL:-10.0}"
FFMPEG_URL="${FFMPEG_URL:-https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n8.1-latest-linux64-lgpl-shared-8.1.tar.xz}"
FFMPEG_LIBS="libavutil.so.60 libswresample.so.6 libswscale.so.9 libavcodec.so.62 libavformat.so.62"
THEME_VIDEOS_URL="https://github.com/Vocaluxe/VocaluxeDependencies/raw/master/zips/themes/vocaluxe.themes.vocaluxe-2024.video-part1.zip"

DIST="$ROOT/dist"
STAGE="$DIST/$NAME"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Theme videos"
if [ ! -f "Output/Themes/Vocaluxe 2024/IntroIn.mp4" ]; then
    if curl -fsSL -o "$TMP/theme-videos.zip" "$THEME_VIDEOS_URL"; then
        unzip -q -o "$TMP/theme-videos.zip" -d Output/
    else
        echo "WARNING: could not download the theme videos, the package will not contain them"
    fi
fi

if [ "${SKIP_BUILD:-0}" != "1" ]; then
    echo "==> Build"
    make ARCH=$ARCH
fi

echo "==> Copy files to $STAGE"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -a Output/. "$STAGE/"
# user data of a local test run and debug symbols of third-party libraries
rm -f "$STAGE/Config.xml" "$STAGE/CoverDB.sqlite" "$STAGE/HighscoreDB.sqlite"
find "$STAGE" -name '*.pdb' ! -name 'Vocaluxe*' -delete
# outdated theme (theme system version 5, current is 9) that older Output folders still contain: it would
# show an error message on every first start
rm -rf "$STAGE/Themes/Ambient" "$STAGE/Themes/Ambient.xml"
mkdir -p "$STAGE/Linux/Package"
cp Vocaluxe/Linux/Package/Vocaluxe.desktop "$STAGE/Linux/Package/"
cp Vocaluxe/Linux/Package/vocaluxe.sh Vocaluxe/Linux/Package/install-desktop-entry.sh Vocaluxe/Linux/Package/README-Linux.txt "$STAGE/"
chmod +x "$STAGE/Vocaluxe" "$STAGE/vocaluxe.sh" "$STAGE/install-desktop-entry.sh"

echo "==> FFmpeg"
FFMPEG_TARGET="$STAGE/libs/unmanaged/ffmpeg64"
mkdir -p "$FFMPEG_TARGET" "$TMP/ffmpeg"
curl -fsSL -o "$TMP/ffmpeg.tar.xz" "$FFMPEG_URL"
tar -xf "$TMP/ffmpeg.tar.xz" -C "$TMP/ffmpeg" --strip-components=1
for lib in $FFMPEG_LIBS; do
    cp -L "$TMP/ffmpeg/lib/$lib" "$FFMPEG_TARGET/"
done
cp "$TMP/ffmpeg/LICENSE.txt" "$FFMPEG_TARGET/" 2>/dev/null || true

if [ "${SKIP_DOTNET_RUNTIME:-0}" != "1" ]; then
    echo "==> .NET runtime"
    curl -fsSL -o "$TMP/dotnet-install.sh" https://dot.net/v1/dotnet-install.sh
    bash "$TMP/dotnet-install.sh" --channel "$DOTNET_CHANNEL" --runtime aspnetcore --architecture $ARCH --install-dir "$STAGE/dotnet" --no-path
fi

echo "==> Create archive"
tar -C "$DIST" -czf "$DIST/$NAME.tar.gz" "$NAME"
rm -rf "$STAGE"
ls -lh "$DIST/$NAME.tar.gz"
