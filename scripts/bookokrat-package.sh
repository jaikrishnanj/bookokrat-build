#!/usr/bin/env bash
set -euo pipefail
name=bookokrat-aarch64-unknown-linux-gnu-grun
root="$PWD/$name"
mkdir -p "$root/lib" "$root/licenses" "$root/source" "$root/evidence"
cp bookokrat-src/target/aarch64-unknown-linux-gnu/release/bookokrat "$root/bookokrat"
file "$root/bookokrat" | tee evidence/file.txt
readelf -h "$root/bookokrat" | tee evidence/elf-header.txt
grep -q 'Machine:.*AArch64' evidence/elf-header.txt
readelf -l "$root/bookokrat" | tee evidence/program-headers.txt
grep -q '/lib/ld-linux-aarch64.so.1' evidence/program-headers.txt
! grep -q '/system/bin/linker' evidence/program-headers.txt
ldd "$root/bookokrat" | tee evidence/ldd-original.txt
! grep -q 'not found' evidence/ldd-original.txt
# Include dlopen-loaded Fontconfig as well as ordinary linked dependencies.
fontconfig=$(ldconfig -p | awk '$1 == "libfontconfig.so.1" {result=$NF} END {print result}')
test -n "$fontconfig"
python3 - "$root" "$fontconfig" <<'PY'
import pathlib, re, shutil, subprocess, sys
root = pathlib.Path(sys.argv[1])
binary = (root / 'bookokrat').resolve()
queue = [binary, pathlib.Path(sys.argv[2])]
seen, manifest = set(), []
# The device supplies its own matched glibc and loader. Do not bundle Ubuntu libc.
glibc = re.compile(r'^(?:ld-linux-.*|lib(?:c|m|dl|pthread|rt|resolv|util|anl|nss_[\w]+)\.so(?:\..*)?)$')
for path in queue:
    path = path.resolve()
    if path in seen:
        continue
    seen.add(path)
    output = subprocess.check_output(['ldd', str(path)], text=True)
    if 'not found' in output:
        raise SystemExit(output)
    for line in output.splitlines():
        match = re.search(r'=> (/\S+)', line)
        if match:
            queue.append(pathlib.Path(match[1]))
    if path == binary or glibc.match(path.name):
        continue
    dynamic = subprocess.check_output(['readelf', '-d', str(path)], text=True)
    soname = re.search(r'\(SONAME\).*\[([^\]]+)\]', dynamic)
    name = soname.group(1) if soname else path.name
    shutil.copy2(path, root / 'lib' / name)
    manifest.append(f'{name}\t{path}')
    query = subprocess.run(['dpkg-query', '-S', '*/' + path.name], capture_output=True, text=True)
    if query.returncode == 0:
        package = query.stdout.split(': ')[0].split(':')[0]
        copyright = pathlib.Path('/usr/share/doc') / package / 'copyright'
        if copyright.is_file():
            shutil.copy2(copyright, root / 'licenses' / (package + '-copyright'))
(root / 'evidence' / 'bundled-libraries.tsv').write_text('\n'.join(manifest) + '\n')
PY
patchelf --force-rpath --set-rpath '$ORIGIN/lib' "$root/bookokrat"
for library in "$root"/lib/*; do
  patchelf --force-rpath --set-rpath '$ORIGIN' "$library"
done
ldd "$root/bookokrat" | tee evidence/ldd-bundled.txt
! grep -q 'not found' evidence/ldd-bundled.txt
readelf --version-info "$root/bookokrat" > evidence/symbol-versions.txt
env -u LD_PRELOAD -u LD_LIBRARY_PATH "$root/bookokrat" --version | tee evidence/version-smoke.txt
env -u LD_PRELOAD -u LD_LIBRARY_PATH "$root/bookokrat" --help > evidence/help-smoke.txt
cp scripts/bookokrat-launch.sh "$root/launch.sh"
cp INSTALL.md "$root/README.md"
cp bookokrat-synctex-highlight.patch "$root/source/"
cp bookokrat-src/LICENSE* "$root/licenses/"
git -C bookokrat-src archive --format=tar.gz HEAD > "$root/source/bookokrat-upstream.tar.gz"
cp bookokrat-src/Cargo.lock "$root/source/"
cp -a evidence/. "$root/evidence/"
chmod +x "$root/bookokrat" "$root/launch.sh"
(cd "$root" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS)
tar -czf "$name.tar.gz" "$name"
sha256sum "$name.tar.gz" > "$name.tar.gz.sha256"
