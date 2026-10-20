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
# Keep GNU libraries out of the environment of Termux's Bionic shell and
# child programs. Pass them only to the glibc-runner runtime's ELF loader.
loader="$PREFIX/glibc/bin/ld.so"
if [ ! -x "$loader" ]; then
  loader="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
fi
if [ ! -x "$loader" ]; then
  printf 'GNU loader not found. Check the Termux glibc installation.\n' >&2
  exit 1
fi
exec "$loader" --library-path "$here/lib:$PREFIX/glibc/lib" "$here/bookokrat" "$@"
