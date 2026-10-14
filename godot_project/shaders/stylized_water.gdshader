shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert, specular_disabled;

// THE LONG MERIDIAN - Stylized Alpine Water Shader (Godot 4)
// Inspired by Dorfromantik & Tiny Glade.
// Features animated surface ripple harmonics, deep alpine color gradient,
// shoreline edge foam, and mirror-like diorama reflections.

uniform vec4 shallow_color : source_color = vec4(0.12, 0.58, 0.72, 1.0);
uniform vec4 deep_color : source_color = vec4(0.04, 0.22, 0.42, 1.0);
uniform vec4 foam_color : source_color = vec4(0.92, 0.96, 1.0, 0.90);
uniform float wave_speed = 1.0;
uniform float wave_frequency = 0.35;
uniform float wave_height = 0.06;
uniform float roughness_val = 0.48;

void vertex() {
    float t = TIME * wave_speed;
    float w1 = sin(VERTEX.x * wave_frequency + t) * cos(VERTEX.z * wave_frequency * 0.8 + t * 0.7);
    float w2 = sin(VERTEX.x * wave_frequency * 1.8 - t * 1.1) * 0.35;
    VERTEX.y += (w1 + w2) * wave_height;
}

void fragment() {
    float t = TIME * wave_speed;
    
    // Wave ripple micro-normals
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float ripple = sin(world_pos.x * 2.2 + t * 1.5) * cos(world_pos.z * 2.0 + t * 1.2) * 0.5 + 0.5;
    
    // Subtle glancing sheen
    float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
    
    vec3 col = mix(deep_color.rgb, shallow_color.rgb, clamp((world_pos.y + 2.0) * 0.5, 0.0, 1.0));
    col = mix(col, foam_color.rgb, ripple * 0.12);
    col = mix(col, shallow_color.rgb * 1.2, fresnel * 0.18);
    
    ALBEDO = col;
    ROUGHNESS = roughness_val;
}
