# Bookokrat for Termux glibc-runner

Modified Bookokrat 0.3.14 with temporary forward-SyncTeX target-line highlighting.

Native Ubuntu 22.04 ARM64 build, targeting `aarch64-unknown-linux-gnu`. SyncTeX regression and executable startup checks passed.

## Launcher correction

The first build artifact's launcher exported GNU `LD_LIBRARY_PATH` before starting `grun`. This can make Termux's Bionic bash fail with `libc.so has bad ELF magic`.

The current [launcher](scripts/bookokrat-launch.sh) uses the installed GNU loader with `--library-path` directly and preserves filenames containing spaces. Replace the first artifact's `launch.sh` with this version. The compiled ARM64 executable is unchanged. A mock-loader regression verified the environment and argument handling; Android execution still requires device testing.

See [installation instructions](INSTALL.md).

[Original successful build artifact](https://github.com/jaikrishnanj/bookokrat-build/actions/runs/39364408519/artifacts/12239112776) (replace its launch.sh as described above).

[Native build run](https://github.com/jaikrishnanj/bookokrat-build/actions/runs/39364408519).
