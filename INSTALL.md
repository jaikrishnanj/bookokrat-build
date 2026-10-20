# Bookokrat ARM64 GNU/Linux for Termux grun

Target: aarch64-unknown-linux-gnu. Built natively on Ubuntu 22.04 ARM64.
Requires ARM64 Termux with working `glibc` and `glibc-runner` packages.

Extract in Termux private storage, not /sdcard:

```sh
mkdir -p "$HOME/opt"
tar --no-same-owner -xzf "$HOME/storage/downloads/bookokrat-aarch64-unknown-linux-gnu-grun.tar.gz" -C "$HOME/opt"
cd "$HOME/opt/bookokrat-aarch64-unknown-linux-gnu-grun"
sha256sum -c SHA256SUMS
chmod +x bookokrat launch.sh
bash launch.sh --version
bash launch.sh '/absolute/path/to/document.pdf'
```

Run `termux-setup-storage` first if Downloads is not accessible. Keep the
extracted directory together. In zsh, add this to ~/.zshrc for convenience:

```sh
bookokrat() { bash "$HOME/opt/bookokrat-aarch64-unknown-linux-gnu-grun/launch.sh" "$@"; }
```

The launch script invokes the GNU loader supplied by the glibc-runner runtime
directly, passing bundled libraries with --library-path. It does not export
LD_LIBRARY_PATH: that would expose GNU libraries to Termux's Bionic bash and
can cause a "libc.so has bad ELF magic" failure. It clears inherited preloads
and finds Android fonts. Do not copy these libraries into $PREFIX/lib. The
package uses Termux's own glibc and matching loader, not Ubuntu's libc. The
runtime must satisfy the GLIBC symbol versions in evidence/symbol-versions.txt.

If the old launcher fails, recover in your current Termux shell with
`unset LD_LIBRARY_PATH LD_PRELOAD`. The equivalent direct invocation, after
first running launch.sh to create fonts.conf, is:

```sh
env -u LD_PRELOAD -u LD_LIBRARY_PATH \
  FONTCONFIG_FILE="$PWD/fonts.conf" \
  "$PREFIX/glibc/bin/ld.so" \
  --library-path "$PWD/lib:$PREFIX/glibc/lib" \
  "$PWD/bookokrat" '/absolute/path/with spaces/document.pdf'
```

Forward SyncTeX search flashes the target line for three seconds. The included
regression test checks scrolling, preservation of the visible cursor, the
highlight rectangle, and expiry. Native Linux tests do not verify Android
terminal image rendering. Keep the .synctex.gz sidecar alongside the PDF.

The evidence directory records the native host, source commit, Rust version,
test result, build logs, ELF details, dependency list and --version/--help smoke
tests. Source and modification patch are under source/. Bookokrat uses
AGPL-3.0-or-later; dependency notices are under licenses/ and upstream sources.
Upstream: https://github.com/bugzmanov/bookokrat.
