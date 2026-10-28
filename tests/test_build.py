import importlib.util
import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

REPO = Path(__file__).resolve().parents[1]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    loaded = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loaded)
    return loaded


builder = module("builder", REPO / "tools/build.py")
activation = module("activation", REPO / "tools/activate-release.py")


class BuildTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="mymaterials-test-")
        self.root = Path(self.temporary.name)
        for name in ("content", "templates", "themes", ".tools/bin", "static"):
            (self.root / name).mkdir(parents=True)
        (self.root / "themes/apollo").symlink_to(REPO / "themes/apollo")
        for name in ("zola", "typst"):
            (self.root / ".tools/bin" / name).symlink_to(builder.tool(name))
        (self.root / "zola.toml").write_text('base_url = "https://example.test/subsite"\n')
        (self.root / "templates/index.html").write_text("Home")
        (self.root / "templates/page.html").write_text(
            '{{ page.content | safe }}{% if page.extra?.build?.pdf %}'
            '<a download href="{{ get_url(path=page.extra.build.pdf) }}">Скачать PDF</a>{% endif %}'
        )
        (self.root / "content/_index.md").write_text('+++\ntitle = "Home"\n+++\n')
        self.page = self.root / "content/lesson.md"
        self.source = self.root / "content/print/document.typ"
        self.source.parent.mkdir()
        self.source.write_text("= Printable document\nHello PDF!")
        (self.source.parent / "private.txt").write_text("private print-only resource")
        self.pdf_page()
        self.root_patch = patch.object(builder, "ROOT", self.root)
        self.output_patch = patch.object(builder, "OUTPUT", self.root / ".build/public")
        self.root_patch.start()
        self.output_patch.start()

    def tearDown(self):
        self.output_patch.stop()
        self.root_patch.stop()
        self.temporary.cleanup()

    def pdf_page(self, source="print/document.typ", extra=""):
        self.page.write_text('+++\ntitle = "Lesson"\nslug = "custom-url"\n' + extra +
                            '[extra.pdf]\nsource = ' + json.dumps(source) + '\n+++\nWeb version')

    def test_pdf_link_and_private_sources(self):
        builder.build()
        output = builder.OUTPUT
        html = (output / "custom-url/index.html").read_text()
        self.assertIn('https://example.test/subsite/downloads/lesson/document.pdf', html)
        self.assertTrue((output / "downloads/lesson/document.pdf").read_bytes().startswith(b"%PDF-"))
        self.assertEqual(list(output.rglob("*.typ")), [])
        self.assertEqual(list(output.rglob("private.txt")), [])
        self.assertNotIn("extra.build", self.page.read_text())

    def test_no_pdf_no_link_and_removal(self):
        builder.build()
        self.page.write_text('+++\ntitle = "Lesson"\n+++\nWeb only')
        builder.build()
        self.assertNotIn("download", (builder.OUTPUT / "lesson/index.html").read_text())
        self.assertFalse((builder.OUTPUT / "downloads/lesson/document.pdf").exists())

    def test_broken_pdf_keeps_previous_release(self):
        builder.build()
        old = (builder.OUTPUT / "downloads/lesson/document.pdf").read_bytes()
        self.source.write_text("#unknown-function()")
        with self.assertRaises(subprocess.CalledProcessError):
            builder.build()
        self.assertEqual((builder.OUTPUT / "downloads/lesson/document.pdf").read_bytes(), old)

    def test_missing_pdf_and_path_escape_fail(self):
        for source in ("print/missing.typ", "../../outside.typ"):
            with self.subTest(source=source):
                self.pdf_page(source)
                with self.assertRaises(ValueError):
                    builder.build()

    def test_draft_not_published(self):
        self.pdf_page(extra="draft = true\n")
        builder.build()
        self.assertEqual(json.loads((builder.OUTPUT / "pdf-manifest.json").read_text()), [])
        self.assertFalse((builder.OUTPUT / "custom-url/index.html").exists())
        builder.build(drafts=True)
        self.assertTrue((builder.OUTPUT / "downloads/lesson/document.pdf").exists())

    def test_reserved_metadata_rejected(self):
        self.page.write_text('+++\ntitle = "Lesson"\n[extra.build]\npdf = "fake.pdf"\n+++\n')
        with self.assertRaises(ValueError):
            builder.build()


class ActivationTests(unittest.TestCase):
    def test_validated_activation_and_rollback(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for name in ("first", "second", "broken"):
                release = root / name
                release.mkdir()
                (release / "index.html").write_text(name)
                (release / "pdf-manifest.json").write_text("[]")
            activation.activate(root, "first")
            activation.activate(root, "second")
            self.assertEqual((root / "current").resolve(), root / "second")
            self.assertEqual((root / "previous").resolve(), root / "first")
            (root / "broken/pdf-manifest.json").write_text('[{"pdf":"missing.pdf"}]')
            with self.assertRaises(ValueError):
                activation.activate(root, "broken")
            self.assertEqual((root / "current").resolve(), root / "second")
            activation.activate(root, "first")
            self.assertEqual((root / "current").resolve(), root / "first")
            with self.assertRaises(ValueError):
                activation.activate(root, "../escape")


if __name__ == "__main__":
    unittest.main()
