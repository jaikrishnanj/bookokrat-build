# Bookokrat for Termux glibc-runner

Modified Bookokrat 0.3.14 with a temporary forward-SyncTeX target-line highlight.

- Native Ubuntu 22.04 ARM64 build, targeting `aarch64-unknown-linux-gnu`.
- SyncTeX regression passed; GNU ELF interpreter verified.
- Bundled Fontconfig and transitive GNU/Linux runtime dependencies.
- Uses Termux's matching glibc and loader; no Android/Bionic binary.

[Download the successful build artifact](https://github.com/jaikrishnanj/bookokrat-build/actions/runs/39364408519/artifacts/12239112776) (GitHub sign-in may be required). Unzip it to obtain the `.tar.gz` package and checksum.

See [installation instructions](INSTALL.md). Test/build logs, checksums, source and patch are included in the package. Android terminal rendering requires testing on the device.

[Successful build run](https://github.com/jaikrishnanj/bookokrat-build/actions/runs/39364408519).
