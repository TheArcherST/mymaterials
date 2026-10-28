import importlib.util
import json
import re
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("build_tools", ROOT / "tools/build.py")
build_tools = importlib.util.module_from_spec(spec)
spec.loader.exec_module(build_tools)


class TypstStateTests(unittest.TestCase):
    def compile(self, source, files=None, success=True):
        (ROOT / ".build").mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=ROOT / ".build") as directory:
            folder = Path(directory)
            for name, data in (files or {}).items():
                (folder / name).write_text(data)
            document = folder / "test.typ"
            document.write_text('#import "/typst/python-state.typ": python-state, composition-points\n'
                                '#set text(font: "Noto Serif", lang: "ru")\n' + source)
            result = subprocess.run([build_tools.tool("typst"), "compile", "--root", str(ROOT),
                                     str(document), str(folder / "test.pdf")], capture_output=True, text=True)
            if success:
                self.assertEqual(result.returncode, 0, result.stderr)
            else:
                self.assertNotEqual(result.returncode, 0)
            return result.stderr

    def test_existing_web_states_and_compositions_compile(self):
        files = {}
        for page in (ROOT / "content").rglob("*.md"):
            for body in re.findall(r"{% <python_state[^%]*%}\s*([\s\S]*?){% </python_state> %}", page.read_text()):
                files[f"state-{len(files)}.yaml"] = body
        self.assertTrue(files, "No Python state examples found")
        self.compile("\n".join(f'#python-state(yaml("{name}"))\n#pagebreak()' for name in files), files)

    def test_composition_variants_preserve_coordinates(self):
        variants = [
            {"v": 1, "p": {"object:a": [-12, 24]}},
            {"composition": {"v": 1, "p": {"object:a": {"left": -12, "top": 24}}}},
            {"schema_version": 1, "placements": [{"key": "object:a", "position": {"x": -12, "y": 24}}]},
        ]
        files = {f"composition-{i}.json": json.dumps(item) for i, item in enumerate(variants)}
        self.compile("\n".join(
            f'#assert(composition-points(json("{name}")).at("object:a") == (-12, 24))\n'
            f'#assert(composition-points(read("{name}")).at("object:a") == (-12, 24))'
            for name in files), files)

    def test_stale_composition_is_rejected(self):
        error = self.compile('#python-state((objects: (a: (type: "int", value: 1),)), '
                             'composition: (v: 1, p: ("object:removed": (0, 0),)))', success=False)
        self.assertIn("exactly the current", error)

    def test_arrays_cycles_and_scalar_types(self):
        state = {"frames": [{"id": "global", "bindings": [{"name": "a", "object": "loop"}]}],
                 "objects": [{"id": "loop", "type": "list", "value": [{"object": "loop"}]},
                             {"id": "f", "type": "float", "value": 1.5},
                             {"id": "b", "type": "bool", "value": True},
                             {"id": "n", "type": "NoneType", "value": None},
                             {"id": "fn", "type": "function", "value": "f(x)"},
                             {"id": "o", "type": "object", "value": "thing", "details": {"x": "1"}}]}
        self.compile('#python-state(json("state.json"))', {"state.json": json.dumps(state)})
