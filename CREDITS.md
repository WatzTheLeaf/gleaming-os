# Credits

GleamingOS is licensed under the [GNU General Public License v3.0](LICENSE).
This file credits everything it reuses from other projects: the project it's based on, the binaries it ships, the code it borrows, what it downloads while it installs and the trademarks it shows.

The Rust crates compiled into `gleaming-os.exe` are listed with their licence texts in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).

## AtlasOS

GleamingOS is based on the playbook of [AtlasOS](https://atlasos.net) ([Atlas-OS/Atlas](https://github.com/Atlas-OS/Atlas)), by the AtlasOS contributors.

- Licence: [GNU General Public License v3.0](https://github.com/Atlas-OS/Atlas/blob/main/LICENSE)
- Reused: the scripts of `playbook` (the tweaks, the removals and the scripts they call), the order of the steps and the component packages listed below.
- Modified by GleamingOS since November 2026:
  - The YAML files of the playbook and its scripts became the scripts of `playbook/Steps` and `playbook/Scripts`, run by a native Rust wizard (`src`) instead of an external playbook runner. Consecutive tweaks share a script.
  - The files installed in `C:\Windows\AtlasModules` go to `C:\Windows\GleamingOS`.
  - Brave is installed as the browser.
  - The theme, wallpaper, account picture, terminal colour scheme and icon are GleamingOS's own.
  - The set of tweaks and options differs from AtlasOS.

GleamingOS isn't affiliated with or endorsed by AtlasOS.

## Shipped binaries

Paths start at `playbook`.
Hashes are upper-case SHA-256, as `Get-FileHash` prints them; on Linux, upper-case the output of `sha256sum`.

### ViVeTool

| Path | SHA-256 |
| --- | --- |
| `Files/ViVeTool-v0.3.3.zip` | `59D1E792EDCC001A319C16435A03D203975BF50EB38BD55CA34370900606F9F0` |
| `Files/ViVeTool-v0.3.3-ARM64CLR.zip` | `37708C95C5053539CD068460E28E565D6B25A33C87F09B6B91A4F82A18E30132` |

- Version: v0.3.3
- Source: the [x64 archive](https://github.com/thebookisclosed/ViVe/releases/download/v0.3.3/ViVeTool-v0.3.3.zip) and the [Arm64 archive](https://github.com/thebookisclosed/ViVe/releases/download/v0.3.3/ViVeTool-v0.3.3-ARM64CLR.zip) of the v0.3.3 release of [thebookisclosed/ViVe](https://github.com/thebookisclosed/ViVe), unmodified
- Licence: [GNU General Public License v3.0](https://github.com/thebookisclosed/ViVe/blob/master/LICENSE)
- Used by: `Scripts/client-cbs.ps1`, which turns off Windows feature IDs

### Windows component packages

| Path | SHA-256 |
| --- | --- |
| `Files/GleamingOS/Packages/Z-Atlas-NoDefender-Package31bf3856ad364e35amd645.0.0.0.cab` | `6A8D1F8788277B425766FAD069A8192EDC33EEA2D6F7F9B061A42C941A21D2EC` |
| `Files/GleamingOS/Packages/Z-Atlas-NoDefender-Package31bf3856ad364e35arm645.0.0.0.cab` | `39500FA6DF403F162C02A9C36D37D2C787BF459C05376872B9962FA649F4E081` |
| `Files/GleamingOS/Packages/Z-Atlas-NoTelemetry-Package31bf3856ad364e35amd645.0.0.0.cab` | `11C5E3502DCB962F2FAE456712C7982DC1864D686B76194628CBFF8D1CD77ECA` |
| `Files/GleamingOS/Packages/Z-Atlas-NoTelemetry-Package31bf3856ad364e35arm645.0.0.0.cab` | `C6526330F660E654B249B63A974793BAE0E39F6714A0B79E03942145195E29A3` |

- Version: 5.0.0.0, the package version in each file name
- Source: AtlasOS, unmodified: the same files as [`package/Executables/AtlasModules/Packages`](https://github.com/Atlas-OS/Atlas/tree/main/package/Executables/AtlasModules/Packages) of Atlas-OS/Atlas, built from its configs by [sxsc](#sxsc)
- Licence: [GNU General Public License v3.0](https://github.com/Atlas-OS/Atlas/blob/main/LICENSE), the AtlasOS licence
- Used by: `Scripts/install-packages.ps1`, which `Steps/remove-components.ps1` runs to remove telemetry and, as an option, Microsoft Defender

### Hurmit Nerd Font

| Path | SHA-256 |
| --- | --- |
| `Files/Fonts/HurmitNerdFont/HurmitNerdFont-Bold.otf` | `2F6AE397D378B086CF48B69ACE17BE6B55014555DC63E2BFF17A2BBD0740E1DE` |
| `Files/Fonts/HurmitNerdFont/HurmitNerdFont-BoldItalic.otf` | `4908BD4224F1F96B9391178EF6DE123A04D86C8DB9EF3C90F3378669C5A81705` |
| `Files/Fonts/HurmitNerdFont/HurmitNerdFont-Italic.otf` | `9224D5CE920183641F1172CC3FD9D6AC4A52C4DA31F89EC830CD8FB6DC5372BE` |
| `Files/Fonts/HurmitNerdFont/HurmitNerdFont-Light.otf` | `881A3E5AC6214C4DAB89629EFDEFA6FA36BA3EB09DAC5FB20D69E517ECC33A4E` |
| `Files/Fonts/HurmitNerdFont/HurmitNerdFont-LightItalic.otf` | `14C0C075410D3FFC494DCB4248EEC67FB8A2EAE038AB35A78E21E930BE55484D` |
| `Files/Fonts/HurmitNerdFont/HurmitNerdFont-Regular.otf` | `3B2EB1C49FDFF6E99C21CF19EC50E8B566A06AEDB56A2DAA7311DF2E866005B9` |

- Version: [Hermit](https://pcaro.es/hermit/) 2.0 by Pablo Caro, patched by [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) 3.4.0
- Licence: SIL Open Font License 1.1, with the Reserved Font Name Hermit; its text is `Files/Fonts/HurmitNerdFont/LICENSE`
- Used by: `Steps/config-terminal.ps1`, which installs it for Windows Terminal

## Borrowed code

### RunAsTI

- Path: `playbook/Files/GleamingOS/RunAsTI.cmd`, installed in `C:\Windows\GleamingOS`
- Source: the `RunAsTI` function of [AveYo/LeanAndMean](https://github.com/AveYo/LeanAndMean), by AveYo
- Licence: [MIT](https://github.com/AveYo/LeanAndMean/blob/main/LICENSE); the notice is at the top of the file
- Used by: the "Merge as TrustedInstaller" context menu of `.reg` files

### online-sxs

- Path: `playbook/Scripts/install-packages.ps1`, which installs the component packages on the running Windows the way online-sxs does
- Source: online-sxs by [he3als](https://github.com/he3als), reached GleamingOS through AtlasOS; its original repository is no longer online
- Licence: GNU General Public License v3.0, through AtlasOS

### sxsc

- Not shipped: [Atlas-OS/sxsc](https://github.com/Atlas-OS/sxsc), first written by echnobas, builds the [component packages](#windows-component-packages)
- Licence: [GNU General Public License v3.0](https://github.com/Atlas-OS/sxsc/blob/master/LICENSE)

## Downloaded while installing

GleamingOS doesn't ship these: the playbook downloads them on the PC it modifies.

| Software | Source | Licence | Used by |
| --- | --- | --- | --- |
| Remove-MS-Edge, by ShadowWhisperer | `Remove-Edge.exe` of the latest release of [ShadowWhisperer/Remove-MS-Edge](https://github.com/ShadowWhisperer/Remove-MS-Edge) | [CC0 1.0](https://github.com/ShadowWhisperer/Remove-MS-Edge/blob/main/LICENSE) | `playbook/Steps/remove-edge.ps1` |
| Brave | The standalone installer of the latest release of [brave/brave-browser](https://github.com/brave/brave-browser) | [Mozilla Public License 2.0](https://github.com/brave/brave-browser/blob/master/LICENSE) | `playbook/Steps/install-brave.ps1` |
| Microsoft Visual C++ Redistributable | Microsoft's permanent links, `https://aka.ms/vs/17/release/vc_redist.<arch>.exe` | Microsoft Software License Terms | `playbook/Steps/install-vcredist.ps1` |

Before running a file downloaded from a GitHub release, the playbook checks it against the SHA-256 hash GitHub publishes for it.

## The wizard

- Rust crates: [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md), generated by [cargo-about](https://github.com/EmbarkStudios/cargo-about).
- Fonts: egui embeds its default fonts in the executable, used when a Windows font lacks a glyph: Ubuntu Light (Ubuntu Font Licence 1.0), Hack (MIT, with the Bitstream Vera licence), Noto Emoji (SIL Open Font License 1.1) and a subset of emoji-icon-font (MIT). Their licence texts are in [`epaint_default_fonts`](https://github.com/emilk/egui/tree/main/crates/epaint_default_fonts/fonts).
- Running as TrustedInstaller: `src/system/privileges.rs` follows James Forshaw's [The Art of Becoming TrustedInstaller](https://www.tiraniddo.dev/2017/08/the-art-of-becoming-trustedinstaller.html).

## Trademarks

Windows and Microsoft Edge are trademarks of Microsoft Corporation.
Brave is a trademark of Brave Software, Inc.
AtlasOS is the name of the AtlasOS project.
GleamingOS isn't affiliated with or endorsed by any of them.

## Keeping this file current

- Adding, replacing or removing a binary in `playbook/Files`: update its entry and its hash.
- Changing `Cargo.lock`: regenerate the crate licences with `cargo about generate --offline about.hbs -o THIRD-PARTY-LICENSES.md`, after installing cargo-about with `cargo install cargo-about --locked --features cli`.
- Downloading or borrowing something new: add it to the matching section.
