# Build Vocaluxe - HowTo (Linux)

Vocaluxe runs on Linux (x64), but it is not as well tested as the Windows version yet.
If you just want to play, use the ready-made `Vocaluxe_..._Linux_x64.tar.gz` package: it already
contains the .NET runtime and FFmpeg, see [Run the package](#run-the-package).

## Build

* Install the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) and [Node.js](https://nodejs.org) (LTS, builds the WebApp)
* Make sure gcc, g++, make and git are installed
* Install the runtime dependencies:
  - FFmpeg 8 (libavformat 62, libavcodec 62, libavutil 60, libswscale 9, libswresample 6).
    Other major versions of FFmpeg do **not** work. If your distribution ships another version,
    put the FFmpeg 8 libraries into `Output/libs/unmanaged/ffmpeg64` (the package script below does that for you)
  - portaudio
  - hidapi (libhidapi-libusb)
  - openal (optional, only needed for the OpenAL playback)
  - gstreamer 1.0 (optional, only needed for the GStreamer playback)

  | Distribution    | Command                                                |
  |-----------------|--------------------------------------------------------|
  | Debian / Ubuntu | `sudo apt install libportaudio2 libhidapi-libusb0`     |
  | Fedora          | `sudo dnf install portaudio hidapi`                    |
  | Arch            | `sudo pacman -S portaudio hidapi`                      |

* Clone the repository and execute in its folder:
```bash
make
```
* Start Vocaluxe:
```bash
cd Output
./Vocaluxe
```
* If GStreamer is not installed, set `PlayBackLib` to `PortAudio` in the `Config.xml`

## Create a portable package

```bash
.build/linuxPackage.sh
```
builds Vocaluxe and creates `dist/Vocaluxe_<version>_Linux_x64.tar.gz`. The package contains the .NET runtime,
the FFmpeg 8 libraries (LGPL build from [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds)) and the
videos of the default theme, so it runs on distributions that ship other versions of them.
The same package is built by the GitHub Actions workflow (job "Linux x64").

## Run the package

```bash
tar -xzf Vocaluxe_*_Linux_x64.tar.gz
cd Vocaluxe_*_Linux_x64
./vocaluxe.sh
```
Only portaudio and hidapi have to be installed (see the table above).
`./install-desktop-entry.sh` adds Vocaluxe to the application menu.

## Good to know

* Settings, profiles, highscores and logs are stored in `~/.config/Vocaluxe`
* File names are case-sensitive on Linux. Vocaluxe falls back to a case-insensitive search for the files
  referenced by songs and themes, so songs created on Windows work without renaming.
* USB microphones have to be plugged in before Vocaluxe is started. Each channel of a stereo device
  (e.g. SingStar microphones) can be assigned to its own player in Options -> Record.
* Vocaluxe uses Wayland or X11 through SDL3. To force one of them: `SDL_VIDEODRIVER=wayland ./vocaluxe.sh` (or `x11`)
* If you make some progress we would be happy if you share it with us in a pull request/issue.
