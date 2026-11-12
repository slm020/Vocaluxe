Vocaluxe for Linux (x64)
========================

Start the game with:

    ./vocaluxe.sh

This package brings its own .NET runtime and FFmpeg libraries, you only need a few
common system libraries:

    Debian / Ubuntu / Mint:  sudo apt install libportaudio2 libhidapi-libusb0
    Fedora:                  sudo dnf install portaudio hidapi
    Arch / Manjaro:          sudo pacman -S portaudio hidapi
    openSUSE:                sudo zypper install libportaudio2 libhidapi-libusb0

Optional: openal (OpenAL playback), gstreamer 1.0 (GStreamer playback).

Good to know
------------
* Your settings, profiles, highscores and logs are stored in ~/.config/Vocaluxe
* Add your song folders in the game (Options -> Game) or in ~/.config/Vocaluxe/Config.xml
* USB microphones (e.g. SingStar mics) are detected at start, plug them in before starting
  the game. Each channel of a stereo receiver can be assigned to its own player
  (Options -> Record).
* To add Vocaluxe to your application menu run ./install-desktop-entry.sh
* If something does not work have a look at ~/.config/Vocaluxe/Logs/Vocaluxe.log

FFmpeg (https://ffmpeg.org) is included under the terms of the LGPL, see
libs/unmanaged/ffmpeg64/LICENSE.txt
