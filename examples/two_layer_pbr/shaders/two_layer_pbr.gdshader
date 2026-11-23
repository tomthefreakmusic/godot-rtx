shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// A is the underlying material; B is the overlaid material.
// All PBR channels are independently sampled and blended by the SAME weight.
group_uniforms Layer_A;
uniform sampler2D a_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D a_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D a_orm : filter_linear_mipmap, repeat_enable; // G=roughness, B=metallic
uniform sampler2D a_height : filter_linear_mipmap, repeat_enable;
uniform vec4 a_tint : source_color = vec4(1.0);
uniform vec2 a_uv_scale = vec2(1.0);
uniform float a_roughness_multiplier : hint_range(0.0, 2.0) = 1.0;
uniform float a_metallic_multiplier : hint_range(0.0, 2.0) = 1.0;

group_uniforms Layer_B;
uniform sampler2D b_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D b_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D b_orm : filter_linear_mipmap, repeat_enable;
uniform sampler2D b_height : filter_linear_mipmap, repeat_enable;
uniform vec4 b_tint : source_color = vec4(1.0);
uniform vec2 b_uv_scale = vec2(1.0);
uniform float b_roughness_multiplier : hint_range(0.0, 2.0) = 1.0;
uniform float b_metallic_multiplier : hint_range(0.0, 2.0) = 1.0;

group_uniforms Blending;
// 0: COLOR.r; 1: mask_texture.r; 2: COLOR.r * mask_texture.r
uniform int mask_mode : hint_enum("Vertex Red", "Texture Red", "Multiply") = 0;
uniform sampler2D mask_texture : filter_linear_mipmap, repeat_disable;
uniform float mask_scale : hint_range(0.0, 2.0) = 1.0;
uniform float mask_bias : hint_range(-1.0, 1.0) = 0.0;
uniform bool invert_mask = false;
uniform bool use_height_blend = false;
uniform float height_strength : hint_range(0.0, 2.0) = 0.7;
uniform float blend_width : hint_range(0.01, 1.0) = 0.25;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;

// See README: vertex colors are linear control values, not albedo tints.
void fragment() {
    vec2 uv_a = UV * a_uv_scale;
    vec2 uv_b = UV * b_uv_scale;
    float vertex_mask = COLOR.r;
    float tex_mask = texture(mask_texture, UV).r;
    float m = vertex_mask;
    if (mask_mode == 1) {
        m = tex_mask;
    } else if (mask_mode == 2) {
        m *= tex_mask;
    }
    m = clamp(m * mask_scale + mask_bias, 0.0, 1.0);
    if (invert_mask) {
        m = 1.0 - m;
    }

    float w = m;
    if (use_height_blend) {
        float ha = texture(a_height, uv_a).r;
        float hb = texture(b_height, uv_b).r;
        float signal = 2.0 * m - 1.0 + (hb - ha) * height_strength;
        w = smoothstep(-blend_width, blend_width, signal);
        // A pure 0 or 1 mask remains absolute, even with large height differences.
        w = mix(w, 0.0, 1.0 - step(0.00001, m));
        w = mix(w, 1.0, step(0.99999, m));
    }

    vec3 color_a = texture(a_albedo, uv_a).rgb * a_tint.rgb;
    vec3 color_b = texture(b_albedo, uv_b).rgb * b_tint.rgb;
    vec3 orm_a = texture(a_orm, uv_a).rgb;
    vec3 orm_b = texture(b_orm, uv_b).rgb;

    // Normal textures use OpenGL/Y+ tangent-space convention; use importer flip Y for DirectX maps.
    vec3 na = texture(a_normal, uv_a).xyz * 2.0 - 1.0;
    vec3 nb = texture(b_normal, uv_b).xyz * 2.0 - 1.0;
    vec3 n = normalize(mix(na, nb, w));
    // The engine reconstructs tangent-space Z from XY for NORMAL_MAP.
    ALBEDO = mix(color_a, color_b, w);
    ROUGHNESS = clamp(mix(orm_a.g * a_roughness_multiplier, orm_b.g * b_roughness_multiplier, w), 0.0, 1.0);
    METALLIC = clamp(mix(orm_a.b * a_metallic_multiplier, orm_b.b * b_metallic_multiplier, w), 0.0, 1.0);
    NORMAL_MAP = n * 0.5 + 0.5;
    NORMAL_MAP_DEPTH = normal_strength;
}
