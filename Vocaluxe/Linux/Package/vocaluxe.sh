#!/bin/sh
# Starts Vocaluxe from its own folder.
# Uses the bundled .NET runtime (./dotnet) if the package contains one, otherwise the system-wide installation.
HERE="$(dirname "$(readlink -f "$0")")"
if [ -x "$HERE/dotnet/dotnet" ]; then
    export DOTNET_ROOT="$HERE/dotnet"
fi
cd "$HERE" || exit 1
exec ./Vocaluxe "$@"
