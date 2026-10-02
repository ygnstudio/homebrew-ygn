import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("updater", Path(__file__).with_name("update-blinker.py"))
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


class UpdateTests(unittest.TestCase):
    tag = "v0.4.0"
    checksum = hashlib.sha256(b"test DMG").hexdigest()
    source = 'cask "blinker" do\n  version "0.3.0"\n  sha256 "' + "1" * 64 + '"\n\n  app "Blinker.app"\nend\n'

    def release(self):
        return {"tag_name": self.tag, "draft": False, "prerelease": False, "assets": [
            {"name": name, "browser_download_url":
             f"https://github.com/ygnstudio/Blinker/releases/download/{self.tag}/{name}"}
            for name in [f"Blinker-{self.tag}.dmg", "SHA256SUMS.txt"]
        ]}

    def test_stable_versions_only(self):
        self.assertEqual(updater.version("v0.4.0"), (0, 4, 0))
        for tag in ["v0.4.0-beta.1", "v0.4.0-rc.1", "v01.2.3", "0.4.0", "v1.2.3\n", "../main"]:
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                updater.version(tag)

    def test_release_and_asset_identity(self):
        release = self.release()
        self.assertTrue(updater.asset_url(release, self.tag, "SHA256SUMS.txt").endswith("/SHA256SUMS.txt"))
        for key, value in [("draft", True), ("prerelease", True), ("tag_name", "v9.0.0")]:
            with self.subTest(key=key), self.assertRaises(ValueError):
                updater.asset_url(dict(release, **{key: value}), self.tag, "SHA256SUMS.txt")
        for assets in [[], release["assets"] * 2,
                       [{"name": "SHA256SUMS.txt", "browser_download_url": "https://example.com/checksum"}]]:
            with self.assertRaises(ValueError):
                updater.asset_url(dict(release, assets=assets), self.tag, "SHA256SUMS.txt")

    def test_exact_manifest_entry(self):
        filename = "Blinker-v0.4.0.dmg"
        entry = f"{self.checksum}  {filename}\n".encode()
        self.assertEqual(updater.manifest_digest(entry, filename), self.checksum)
        for data in [b"", entry * 2, entry.replace(filename.encode(), b"../wrong.dmg")]:
            with self.assertRaises(ValueError):
                updater.manifest_digest(data, filename)

    def test_downgrade_or_mutated_existing_release_is_rejected(self):
        for tag in ["v0.2.0", "v0.3.0"]:
            with self.assertRaises(ValueError):
                updater.replacement(self.source, tag, self.checksum)
        self.assertEqual(updater.replacement(self.source, "v0.3.0", "1" * 64), self.source)

    def run_update(self, cask, write=False, digest=None):
        metadata = json.dumps(self.release()).encode()
        manifest = f"{self.checksum}  Blinker-{self.tag}.dmg\n".encode()
        with patch.object(updater, "read_url", side_effect=[metadata, manifest]), \
                patch.object(updater, "download_digest", return_value=digest or self.checksum):
            return updater.update(self.tag, cask, write)

    def test_dry_run_then_atomic_update(self):
        with tempfile.TemporaryDirectory() as directory:
            cask = Path(directory) / "blinker.rb"
            cask.write_text(self.source)
            self.assertTrue(self.run_update(cask))
            self.assertEqual(cask.read_text(), self.source)
            self.assertTrue(self.run_update(cask, write=True))
            self.assertEqual(cask.read_text(), updater.replacement(self.source, self.tag, self.checksum))
            self.assertEqual(list(Path(directory).iterdir()), [cask])

    def test_bad_download_does_not_replace_cask(self):
        with tempfile.TemporaryDirectory() as directory:
            cask = Path(directory) / "blinker.rb"
            cask.write_text(self.source)
            with self.assertRaises(ValueError):
                self.run_update(cask, write=True, digest="0" * 64)
            self.assertEqual(cask.read_text(), self.source)

    def test_symlink_is_rejected_before_network_access(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "target.rb"
            target.write_text(self.source)
            cask = Path(directory) / "blinker.rb"
            cask.symlink_to(target)
            with patch.object(updater, "read_url") as fetch, self.assertRaises(ValueError):
                updater.update(self.tag, cask, write=True)
            fetch.assert_not_called()
            self.assertEqual(target.read_text(), self.source)

    def test_latest_same_or_older_version_does_not_download_assets(self):
        for tag in ("v0.3.0", "v0.2.0"):
            with self.subTest(tag=tag), tempfile.TemporaryDirectory() as directory:
                cask = Path(directory) / "blinker.rb"
                cask.write_text(self.source)
                metadata = dict(self.release(), tag_name=tag, assets=[])
                with patch.object(updater, "read_url", return_value=json.dumps(metadata).encode()) as fetch, \
                        patch.object(updater, "download_digest") as download:
                    self.assertFalse(updater.update(None, cask, write=True))
                    fetch.assert_called_once_with(
                        "https://api.github.com/repos/ygnstudio/Blinker/releases/latest", 1024 * 1024)
                    download.assert_not_called()
                self.assertEqual(cask.read_text(), self.source)

    def test_latest_new_stable_release_verifies_then_updates_atomically(self):
        with tempfile.TemporaryDirectory() as directory:
            cask = Path(directory) / "blinker.rb"
            cask.write_text(self.source)
            manifest = f"{self.checksum}  Blinker-{self.tag}.dmg\n".encode()
            with patch.object(updater, "read_url", side_effect=[json.dumps(self.release()).encode(), manifest]) as fetch, \
                    patch.object(updater, "download_digest", return_value=self.checksum) as download:
                self.assertTrue(updater.update(None, cask, write=True))
                self.assertEqual(fetch.call_count, 2)
                self.assertTrue(fetch.call_args_list[0].args[0].endswith("/releases/latest"))
                download.assert_called_once_with(
                    "https://github.com/ygnstudio/Blinker/releases/download/v0.4.0/Blinker-v0.4.0.dmg")
            self.assertEqual(cask.read_text(), updater.replacement(self.source, self.tag, self.checksum))
            self.assertEqual(list(Path(directory).iterdir()), [cask])

    def test_latest_invalid_metadata_or_missing_asset_leaves_cask_unchanged(self):
        cases = [None, [], dict(self.release(), prerelease=True), dict(self.release(), draft=True),
                 dict(self.release(), tag_name="v0.4.0-beta.1"), dict(self.release(), assets=[])]
        for metadata in cases:
            with self.subTest(metadata=metadata), tempfile.TemporaryDirectory() as directory:
                cask = Path(directory) / "blinker.rb"
                cask.write_text(self.source)
                with patch.object(updater, "read_url", return_value=json.dumps(metadata).encode()), \
                        patch.object(updater, "download_digest") as download, self.assertRaises(ValueError):
                    updater.update(None, cask, write=True)
                download.assert_not_called()
                self.assertEqual(cask.read_text(), self.source)

    def test_latest_hash_mismatch_or_download_error_does_not_replace_cask(self):
        for digest, failure in (("0" * 64, None), (None, OSError("download interrupted"))):
            with self.subTest(failure=failure), tempfile.TemporaryDirectory() as directory:
                cask = Path(directory) / "blinker.rb"
                cask.write_text(self.source)
                manifest = f"{self.checksum}  Blinker-{self.tag}.dmg\n".encode()
                with patch.object(updater, "read_url", side_effect=[json.dumps(self.release()).encode(), manifest]), \
                        patch.object(updater, "download_digest", return_value=digest, side_effect=failure), \
                        self.assertRaises((ValueError, OSError)):
                    updater.update(None, cask, write=True)
                self.assertEqual(cask.read_text(), self.source)

    def test_manual_same_version_still_checks_for_changed_release_contents(self):
        with tempfile.TemporaryDirectory() as directory:
            cask = Path(directory) / "blinker.rb"
            source = updater.replacement(self.source, self.tag, self.checksum)
            cask.write_text(source)
            manifest = f"{'0' * 64}  Blinker-{self.tag}.dmg\n".encode()
            with patch.object(updater, "read_url", side_effect=[json.dumps(self.release()).encode(), manifest]), \
                    patch.object(updater, "download_digest", return_value="0" * 64) as download, \
                    self.assertRaises(ValueError):
                updater.update(self.tag, cask, write=True)
            download.assert_called_once()
            self.assertEqual(cask.read_text(), source)

    def test_latest_does_not_overwrite_edits_made_during_download(self):
        with tempfile.TemporaryDirectory() as directory:
            cask = Path(directory) / "blinker.rb"
            cask.write_text(self.source)
            edited = self.source + "# independent edit\n"
            manifest = f"{self.checksum}  Blinker-{self.tag}.dmg\n".encode()

            def concurrent_edit(_):
                cask.write_text(edited)
                return self.checksum

            with patch.object(updater, "read_url", side_effect=[json.dumps(self.release()).encode(), manifest]), \
                    patch.object(updater, "download_digest", side_effect=concurrent_edit), \
                    self.assertRaises(ValueError):
                updater.update(None, cask, write=True)
            self.assertEqual(cask.read_text(), edited)
            self.assertEqual(list(Path(directory).iterdir()), [cask])

    def test_cli_keeps_dry_run_default_and_manual_tag_mode(self):
        with patch.object(updater, "update") as update:
            updater.main(["--latest"])
            self.assertIsNone(update.call_args.args[0])
            self.assertFalse(update.call_args.args[2])
            updater.main(["--latest", "--write"])
            self.assertIsNone(update.call_args.args[0])
            self.assertTrue(update.call_args.args[2])
            updater.main([self.tag, "--write"])
            self.assertEqual(update.call_args.args[0], self.tag)
            self.assertTrue(update.call_args.args[2])


if __name__ == "__main__":
    unittest.main()
