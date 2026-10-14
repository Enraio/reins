#!/bin/sh
# reins installer — downloads the latest release binary for this host.
#
#   curl -fsSL https://raw.githubusercontent.com/enraio/reins/main/install.sh | sh
#
# This file is DISTRIBUTED FROM THE PUBLIC REPO (enraio/reins). It ships
# no source; it only fetches a signed-by-checksum binary from Releases. macOS
# and Linux (incl. WSL). For native Windows, grab the .zip from the Releases
# page instead. Installs are CLI-only, so macOS Gatekeeper never quarantines it.
set -eu

REPO="enraio/reins"

# The daemon was renamed reins-hook -> reins. Releases cut before the rename
# ship `reins-hook_*` assets; releases after it ship `reins_*`. Resolve which
# one this tag actually published rather than guessing, so the installer keeps
# working across the boundary in both directions.
BIN=""

INSTALL_DIR="${REINS_INSTALL_DIR:-$HOME/.local/bin}"

fail() {
	echo "install: $*" >&2
	exit 1
}

os=$(uname -s)
arch=$(uname -m)
case "$os" in
Darwin) os=darwin ;;
Linux) os=linux ;;
*) fail "unsupported OS '$os' — for native Windows use the .zip on the Releases page, or install under WSL" ;;
esac
case "$arch" in
x86_64 | amd64) arch=amd64 ;;
arm64 | aarch64) arch=arm64 ;;
*) fail "unsupported architecture '$arch'" ;;
esac

command -v curl >/dev/null 2>&1 || fail "curl is required"
command -v tar >/dev/null 2>&1 || fail "tar is required"

# Resolve the latest release tag (e.g. v0.1.0) from the GitHub API.
ver=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" |
	grep -m1 '"tag_name"' | cut -d'"' -f4)
[ -n "$ver" ] || fail "could not resolve the latest release of $REPO"
num=${ver#v}

sums="https://github.com/$REPO/releases/download/$ver/checksums.txt"

for candidate in reins reins-hook; do
	probe="https://github.com/$REPO/releases/download/$ver/${candidate}_${num}_${os}_${arch}.tar.gz"
	if curl -fsIL -o /dev/null "$probe" 2>/dev/null; then
		BIN="$candidate"
		url="$probe"
		break
	fi
done
[ -n "$BIN" ] || fail "no binary for $os/$arch in $ver" 

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $BIN $ver ($os/$arch)…"
curl -fsSL "$url" -o "$tmp/pkg.tar.gz" || fail "download failed: $url"

# Verify the checksum when a hashing tool is available (best-effort).
if curl -fsSL "$sums" -o "$tmp/checksums.txt" 2>/dev/null; then
	asset="${BIN}_${num}_${os}_${arch}.tar.gz"
	want=$(grep " $asset\$" "$tmp/checksums.txt" | cut -d' ' -f1 || true)
	if [ -n "$want" ]; then
		if command -v sha256sum >/dev/null 2>&1; then
			got=$(sha256sum "$tmp/pkg.tar.gz" | cut -d' ' -f1)
		elif command -v shasum >/dev/null 2>&1; then
			got=$(shasum -a 256 "$tmp/pkg.tar.gz" | cut -d' ' -f1)
		fi
		[ -z "${got:-}" ] || [ "$got" = "$want" ] || fail "checksum mismatch for $asset"
	fi
fi

tar -xzf "$tmp/pkg.tar.gz" -C "$tmp"
mkdir -p "$INSTALL_DIR"
install -m 0755 "$tmp/$BIN" "$INSTALL_DIR/$BIN"

echo "Installed $BIN $ver → $INSTALL_DIR/$BIN"
case ":$PATH:" in
*":$INSTALL_DIR:"*) ;;
*) echo "Add it to your PATH:  export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac
echo "Next: run 'reins setup' to connect your agents and pair your phone — see https://reins.enraio.com/docs"
