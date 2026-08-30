<!-- This README is for the PUBLIC distribution repo (enraio/reins-hook). It
     ships no source — only release binaries, this readme, install.sh, LICENSE. -->

# reins-hook

The host-side daemon for **Reins** — watch your AI coding agents (Claude Code,
Codex) and approve or deny their actions from your phone. `reins-hook` runs on
the machine where your agent works; the Reins app connects to it over your own
network (local-first, no cloud relay).

## Install

**macOS (recommended)**

```sh
brew install enraio/tap/reins-hook
brew services start reins-hook
```

**macOS / Linux / WSL (script)**

```sh
curl -fsSL https://raw.githubusercontent.com/enraio/reins-hook/main/install.sh | sh
```

**Windows (native, best-effort):** download the `windows` `.zip` from
[Releases](https://github.com/enraio/reins-hook/releases/latest) and put
`reins-hook.exe` on your `PATH`. The tested Windows path is **WSL2** with the
Linux build above.

## Setup

1. Connect it to your agent (adds the Reins hooks to Claude Code) and pair your
   phone. _(A one-command `reins-hook setup` is on the way; until then follow the
   quickstart below.)_
2. Get the Reins app and scan the pairing code.

<!-- TODO: link the app + expand the manual quickstart until `reins-hook setup` lands. -->

## Verify a download

Each release includes `checksums.txt`. To check a manual download:

```sh
shasum -a 256 -c checksums.txt   # or: sha256sum -c checksums.txt
```

## License

See [LICENSE](LICENSE). Source is not distributed.
