from pathlib import Path
from math import isclose

root = Path(__file__).resolve().parent
shader = (root / "shaders/two_layer_pbr.gdshader").read_text()
demo = (root / "demo/demo.gd").read_text()
scene = (root / "demo/demo.tscn").read_text()
project = (root / "project.godot").read_text()
assert "shader_type spatial;" in shader
assert shader.count("{") == shader.count("}")
assert all(token in shader for token in ["ALBEDO =", "ROUGHNESS =", "METALLIC =", "NORMAL_MAP ="])
assert 'res://shaders/two_layer_pbr.gdshader' in demo
assert 'res://demo/demo.gd' in scene
assert 'res://demo/demo.tscn' in project
assert (root / "demo/demo.gd").is_file()
assert (root / "shaders/two_layer_pbr.gdshader").is_file()
def smoothstep(a, b, x):
    t = max(0., min(1., (x-a)/(b-a)))
    return t*t*(3.-2.*t)
def weight(m, ha, hb, strength=.7, width=.25):
    w = smoothstep(-width, width, 2*m - 1 + (hb-ha)*strength)
    return 0. if m < .00001 else (1. if m >= .99999 else w)
for a in [0., .3, 1.]:
    for b in [0., .7, 1.]:
        assert weight(0., a, b) == 0.
        assert weight(1., a, b) == 1.
assert isclose(weight(.5, .5, .5), .5)
assert weight(.5, 0., 1.) > weight(.5, 1., 0.)
print("PASS: static resource references and basic numerical blend checks")
print("NOT TESTED: Godot shader compilation, runtime or renderer fidelity")
