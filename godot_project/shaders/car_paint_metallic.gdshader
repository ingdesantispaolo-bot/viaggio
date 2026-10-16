shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Automotive Dual-Layer Metallic Flake Paint Shader
// Simulates authentic Italian 1970s coachwork: pigmented basecoat with metallic flake sparkle,
// topped with a rich, glossy dielectric clearcoat with angle-dependent Fresnel reflectance.

uniform vec4 base_color : source_color = vec4(0.86, 0.68, 0.18, 1.0); // Giallo Positano 1974
uniform vec4 highlight_color : source_color = vec4(1.0, 0.88, 0.45, 1.0); // Sunlit grazing highlight
uniform float metallic_weight : hint_range(0.0, 1.0) = 0.25;
uniform float base_roughness : hint_range(0.0, 1.0) = 0.18;
uniform float clearcoat_strength : hint_range(0.0, 1.0) = 1.0;
uniform float clearcoat_roughness : hint_range(0.0, 1.0) = 0.04;
uniform float flake_scale : hint_range(10.0, 500.0) = 180.0;
uniform float flake_intensity : hint_range(0.0, 1.0) = 0.16;

// Procedural metallic flake pseudorandom hash
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void fragment() {
    // 1. Dual-tone grazing angle falloff (Flop Effect)
    vec3 view_dir = normalize(VIEW);
    vec3 norm = normalize(NORMAL);
    float NdotV = clamp(dot(norm, view_dir), 0.0, 1.0);
    float fresnel = pow(1.0 - NdotV, 4.0);
    
    // 2. Micro-flake glitter sparkle calculation
    vec2 flake_uv = UV * flake_scale;
    float flake_val = hash(floor(flake_uv));
    float flake_sparkle = step(0.82, flake_val) * (flake_val - 0.82) * 5.5;
    
    // 3. Composite Basecoat
    vec3 blended_albedo = mix(base_color.rgb, highlight_color.rgb, fresnel * 0.45);
    blended_albedo += vec3(flake_sparkle * flake_intensity);
    
    ALBEDO = blended_albedo;
    METALLIC = metallic_weight;
    ROUGHNESS = mix(base_roughness, 0.08, fresnel);
    
    // 4. Clearcoat (Forward+ high-specular glass layer)
    CLEARCOAT = clearcoat_strength;
    CLEARCOAT_ROUGHNESS = clearcoat_roughness;
    SPECULAR = 0.65;
}
