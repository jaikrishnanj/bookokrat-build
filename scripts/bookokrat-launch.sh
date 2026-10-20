#!/usr/bin/env bash
set -euo pipefail
: "${PREFIX:?Run inside Termux}"
here=$(cd -- "$(dirname -- "$0")" && pwd)
unset LD_PRELOAD LD_LIBRARY_PATH
if [ ! -f "$here/fonts.conf" ]; then
  printf '%s\n' '<?xml version="1.0"?>' \
    '<fontconfig><dir>/system/fonts</dir><dir>/product/fonts</dir><cachedir prefix="xdg">fontconfig</cachedir></fontconfig>' \
    > "$here/fonts.conf"
fi
export FONTCONFIG_FILE="$here/fonts.conf"
export LD_LIBRARY_PATH="$here/lib:$PREFIX/glibc/lib"
exec grun "$here/bookokrat" "$@"
