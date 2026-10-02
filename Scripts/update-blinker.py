#!/usr/bin/env python3
"""Verify a published stable Blinker DMG before updating its Homebrew cask."""

import argparse
import difflib
import hashlib
import json
import os
from pathlib import Path
import re
import tempfile
import urllib.request


REPOSITORY = "ygnstudio/Blinker"
STABLE = re.compile(r"v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\Z")


def version(tag):
    match = STABLE.fullmatch(tag) if isinstance(tag, str) else None
    if not match:
        raise ValueError("Use a stable tag such as v0.4.0; prereleases are not accepted.")
    return tuple(int(part) for part in match.groups())


def response(url):
    request = urllib.request.Request(url, headers={"User-Agent": "homebrew-ygn-blinker-updater"})
    return urllib.request.urlopen(request, timeout=30)


def read_url(url, limit):
    with response(url) as source:
        data = source.read(limit + 1)
    if len(data) > limit:
        raise ValueError("Release metadata exceeds the allowed size.")
    return data


def download_digest(url):
    digest = hashlib.sha256()
    total = 0
    with response(url) as source:
        while chunk := source.read(1024 * 1024):
            total += len(chunk)
            if total > 512 * 1024 * 1024:
                raise ValueError("DMG exceeds the 512 MiB download limit.")
            digest.update(chunk)
    if not total:
        raise ValueError("The downloaded DMG is empty.")
    return digest.hexdigest()


def stable_release_tag(release):
    if not isinstance(release, dict):
        raise ValueError("Expected a GitHub release object.")
    tag = release.get("tag_name")
    version(tag)
    if (release.get("draft") is not False
            or release.get("prerelease") is not False):
        raise ValueError("The requested tag is not a published stable release.")
    return tag


def asset_url(release, tag, filename):
    if stable_release_tag(release) != tag:
        raise ValueError("The release does not match the requested tag.")
    assets = [asset for asset in release.get("assets", []) if asset.get("name") == filename]
    expected = f"https://github.com/{REPOSITORY}/releases/download/{tag}/{filename}"
    if len(assets) != 1 or assets[0].get("browser_download_url") != expected:
        raise ValueError(f"Missing, duplicated, or unexpected release asset: {filename}")
    return expected


def manifest_digest(data, filename):
    matches = []
    for line in data.decode("ascii").splitlines():
        match = re.fullmatch(r"([0-9a-fA-F]{64})[ \t]+\*?" + re.escape(filename), line)
        if match:
            matches.append(match.group(1).lower())
    if len(matches) != 1:
        raise ValueError("SHA256SUMS.txt must contain one checksum for the exact DMG filename.")
    return matches[0]


def cask_values(source):
    if not source.startswith('cask "blinker" do\n'):
        raise ValueError("Expected the Blinker cask.")
    versions = re.findall(r'^  version "([^"]+)"$', source, re.MULTILINE)
    checksums = re.findall(r'^  sha256 "([0-9a-f]{64})"$', source, re.MULTILINE)
    if len(versions) != 1 or len(checksums) != 1:
        raise ValueError("Expected one version and one pinned SHA-256 in the cask.")
    version("v" + versions[0])
    return versions[0], checksums[0]


def replacement(source, tag, checksum):
    proposed = version(tag)
    current_version, current_checksum = cask_values(source)
    current = version("v" + current_version)
    if proposed < current:
        raise ValueError("Refusing to downgrade the stable cask.")
    if proposed == current and checksum != current_checksum:
        raise ValueError("An existing version has a different checksum; investigate instead of replacing it.")
    result = source.replace(f'  version "{current_version}"', f'  version "{tag[1:]}"', 1)
    return result.replace(f'  sha256 "{current_checksum}"', f'  sha256 "{checksum}"', 1)


def update(tag, cask, write=False):
    # A missing tag is the polling mode. An explicit tag always revalidates its assets.
    if tag is not None:
        version(tag)
    if cask.is_symlink() or not cask.is_file():
        raise ValueError("The cask must be an existing regular file, not a symlink.")
    original = cask.read_text()
    current, _ = cask_values(original)
    endpoint = "latest" if tag is None else f"tags/{tag}"
    release = json.loads(read_url(f"https://api.github.com/repos/{REPOSITORY}/releases/{endpoint}", 1024 * 1024))
    if tag is None:
        tag = stable_release_tag(release)
        if version(tag) <= version("v" + current):
            print(f"Latest stable {tag} is not newer than {current}; no asset download or cask change.")
            return False
    filename = f"Blinker-{tag}.dmg"
    dmg = asset_url(release, tag, filename)
    sums = asset_url(release, tag, "SHA256SUMS.txt")
    expected = manifest_digest(read_url(sums, 128 * 1024), filename)
    if download_digest(dmg) != expected:
        raise ValueError("The downloaded DMG does not match SHA256SUMS.txt; cask left unchanged.")
    revised = replacement(original, tag, expected)
    if original == revised:
        print(f"{tag} is already current; verified the published DMG.")
        return False
    print("".join(difflib.unified_diff(original.splitlines(True), revised.splitlines(True),
                                      fromfile="Casks/blinker.rb", tofile="Casks/blinker.rb")), end="")
    if write:
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(mode="w", dir=cask.parent, prefix=".blinker-", delete=False) as output:
                temporary = Path(output.name)
                output.write(revised)
            temporary.chmod(cask.stat().st_mode & 0o777)
            if cask.is_symlink() or cask.read_text() != original:
                raise ValueError("The cask changed during verification; refusing to overwrite it.")
            os.replace(temporary, cask)
        finally:
            if temporary is not None:
                temporary.unlink(missing_ok=True)
    return True


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tag", nargs="?", help="Published stable tag, e.g. v0.4.0")
    parser.add_argument("--latest", action="store_true", help="Check for a newer stable release; skip unchanged assets")
    parser.add_argument("--write", action="store_true", help="Apply the verified update; otherwise show a diff only")
    args = parser.parse_args(argv)
    if bool(args.tag) == args.latest:
        parser.error("Choose a stable tag or --latest, but not both.")
    try:
        update(args.tag, Path(__file__).resolve().parents[1] / "Casks/blinker.rb", args.write)
    except (ValueError, OSError) as error:
        parser.exit(1, f"error: {error}\n")


if __name__ == "__main__":
    main()
