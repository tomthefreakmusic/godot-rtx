# Two-layer PBR blending example

Standalone Godot 4.x spatial shader, designed for the `rtx/4.8-beta4` fork without engine changes.

## Use in an existing project
Copy `shaders/two_layer_pbr.gdshader` into your project and create a ShaderMaterial using it.
Assign two sets of **albedo**, **tangent-space normal**, and **ORM** textures. Each ORM texture packs **roughness in green** and **metallic in blue** (red unused). Use linear/non-color import for ORM, height and mask textures; albedo uses sRGB decoding. Normal textures should use OpenGL/Y+ orientation, or have their green channel flipped at import.

A mesh needs UV coordinates and a valid tangent basis for normal maps.

`mask_mode`:
- **Vertex Red (0):** interpolated mesh `COLOR.r`; 0 selects A, 1 selects B.
- **Texture Red (1):** red channel from `mask_texture` at mesh UV.
- **Multiply (2):** vertex red × mask texture red.

`mask_scale`, `mask_bias` and `invert_mask` shape the control. `use_height_blend` optionally modulates the transition using both layer height maps; `height_strength` controls the influence and `blend_width` its softness. This is **height-based blending**, not displacement or parallax mapping.

Layer A and B have independent UV scales, color tint, roughness multipliers, metallic multipliers, and texture sets. All outputs use **one shared blend weight** and one standard PBR material lighting evaluation. Texture alpha is ignored. This shader does not replace collision geometry or solve mesh silhouette seams.

## Demo
The `demo` directory and `project.godot` form a minimal self-contained sample project. **Open `examples/two_layer_pbr/` as a separate Godot project**, rather than opening the engine root. Run `demo/demo.tscn`: the script builds three panels and all textures procedurally.

The panels demonstrate vertex painted blending, texture mask blending, and combined vertex + texture mask with height-based modulation.

The sample defaults to Compatibility rendering to allow a basic independent project import. For your RTX fork, select **Forward+** / Vulkan in Godot Project Settings before checking raster behavior. Direct3D 12 raster support is implementation-specific. The fork README documents Vulkan Forward+ path tracing and Direct3D 12 raster DLSS, but path-traced custom ShaderMaterial behavior has not been verified.

## Caveats
- Two complete layers require texture samples from both, even when the weight strongly selects one layer; consider material variants for high-volume production usage.
- Normals are linearly interpolated and normalized, not reoriented normal mapping (RNM). Fine for a general transition, but not an accurate layered microfacet model.
- Height masks are transition hints; they do **not** move vertices or create parallax.
- Geometry/UV continuity and intersection masking still need to be authored or generated separately.
- No actual Godot runtime shader compile or Vulkan/Direct3D 12 visual test has been performed as part of this commit.

## Validation
Run `python3 static_checks.py` in this directory. This verifies basic resource references, texture bindings and blend weight arithmetic. It is not a substitute for opening the sample in the Godot editor.
