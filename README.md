# GleamingOS

GleamingOS is a personal, disposable-friendly Windows 11 setup based on [AtlasOS](https://atlasos.net).
A native wizard, `gleaming-os.exe`, embeds the playbook and applies it to a fresh installation of Windows 11 25H2 or 26H2: it removes bloat and telemetry, installs Brave and tweaks Windows for privacy and ease of use.

## Building

```powershell
cargo build --release
```

The executable is `target\release\gleaming-os.exe` and asks for administrator rights when it starts.

## Licence

GleamingOS is licensed under the [GNU General Public License v3.0](LICENSE), like AtlasOS, on which it's based.

[CREDITS.md](CREDITS.md) credits AtlasOS and every third-party component, and [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md) lists the licences of the Rust crates.
