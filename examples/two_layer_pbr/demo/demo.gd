extends Node3D
# This self-contained scene generates textures and mesh data at runtime.
const PBR_SHADER := preload("res://shaders/two_layer_pbr.gdshader")

func _ready() -> void:
    var environment := WorldEnvironment.new()
    var settings := Environment.new()
    settings.background_mode = Environment.BG_COLOR
    settings.background_color = Color(0.12, 0.14, 0.17)
    settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    settings.ambient_light_color = Color.WHITE
    settings.ambient_light_energy = 0.4
    environment.environment = settings
    add_child(environment)
    var camera := Camera3D.new()
    camera.position = Vector3(0.0, 5.2, 9.5)
    add_child(camera)
    camera.look_at(Vector3.ZERO)
    camera.current = true
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-60, -30, 0)
    sun.light_energy = 1.8
    add_child(sun)

    var maps := []
    for i in range(9):
        maps.append(_make_map(i))
    for i in range(3):
        var mat := ShaderMaterial.new()
        mat.shader = PBR_SHADER
        var names := ["a_albedo", "b_albedo", "a_normal", "b_normal", "a_orm", "b_orm", "a_height", "b_height", "mask_texture"]
        for j in range(names.size()):
            mat.set_shader_parameter(names[j], maps[j])
        mat.set_shader_parameter("mask_mode", i)
        mat.set_shader_parameter("use_height_blend", i == 2)
        mat.set_shader_parameter("a_uv_scale", Vector2(3, 3))
        mat.set_shader_parameter("b_uv_scale", Vector2(3, 3))
        var instance := MeshInstance3D.new()
        instance.mesh = _make_plane(i)
        instance.material_override = mat
        instance.position.x = float(i - 1) * 3.5
        add_child(instance)

func _make_plane(tile: int) -> ArrayMesh:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    const STEPS := 24
    for z in range(STEPS):
        for x in range(STEPS):
            var p00 := Vector2(float(x) / STEPS, float(z) / STEPS)
            var p10 := Vector2(float(x + 1) / STEPS, float(z) / STEPS)
            var p01 := Vector2(float(x) / STEPS, float(z + 1) / STEPS)
            var p11 := Vector2(float(x + 1) / STEPS, float(z + 1) / STEPS)
            for uv in [p00, p01, p10, p10, p01, p11]:
                var weight := smoothstep(0.2, 0.8, uv.x) if tile != 1 else 1.0
                st.set_color(Color(weight, 0.0, 0.0, 1.0))
                st.set_uv(uv)
                st.set_normal(Vector3.UP)
                st.set_tangent(Plane(1.0, 0.0, 0.0, 1.0))
                st.add_vertex(Vector3((uv.x - 0.5) * 3.0, 0.0, (uv.y - 0.5) * 3.0))
    return st.commit()

func _make_map(kind: int) -> ImageTexture:
    const SIZE := 128
    var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
    for y in range(SIZE):
        for x in range(SIZE):
            var u := float(x) / float(SIZE)
            var v := float(y) / float(SIZE)
            var wave := 0.5 + 0.5 * sin(u * TAU * 8.0) * cos(v * TAU * 8.0)
            var checker := 1.0 if (int(floor(u * 8.0)) + int(floor(v * 8.0))) % 2 == 0 else 0.45
            var c := Color.WHITE
            match kind:
                0: c = Color(0.4 * checker, 0.39 * checker, 0.36 * checker)
                1: c = Color(0.48 + 0.16 * wave, 0.19 + 0.07 * wave, 0.08)
                2, 3: c = Color(0.5 + 0.08 * sin(u * TAU * 8.0), 0.5 + 0.08 * cos(v * TAU * 8.0), 1.0)
                4: c = Color(1.0, 0.88, 0.02)
                5: c = Color(1.0, 0.30, 0.90)
                6: c = Color(wave, wave, wave)
                7: c = Color(1.0 - wave, 1.0 - wave, 1.0 - wave)
                8:
                    var mask := smoothstep(0.15, 0.85, v)
                    c = Color(mask, mask, mask)
            img.set_pixel(x, y, c)
    img.generate_mipmaps()
    return ImageTexture.create_from_image(img)
