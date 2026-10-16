shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Vintage 1970s Carello Fluted Prism Headlight Lens Shader
// Procedurally simulates the vertical optical fresnel prisms and fluted glass pattern
// found on classic sealed-beam headlights (Siem, Carello, Cibié).

uniform vec4 glass_tint : source_color = vec4(0.95, 0.97, 1.0, 0.28);
uniform vec4 bulb_emission : source_color = vec4(1.0, 0.94, 0.82, 1.0); // Warm incandescent 3200K
uniform float emission_energy : hint_range(0.0, 5.0) = 2.2;
uniform float flute_frequency : hint_range(10.0, 100.0) = 48.0;
uniform float prism_depth : hint_range(0.0, 1.0) = 0.45;
uniform float glass_roughness : hint_range(0.0, 1.0) = 0.06;

void fragment() {
    // Optical fluting along local X/U axis
    float flute_wave = sin(UV.x * flute_frequency * 6.28318);
    float flute_normal_perturb = flute_wave * prism_depth;
    
    // Normal distortion simulating cylindrical lens prisms
    vec3 perturbed_normal = normalize(NORMAL + vec3(flute_normal_perturb * 0.4, 0.0, 0.0));
    
    vec3 view_dir = normalize(VIEW);
    float NdotV = clamp(dot(perturbed_normal, view_dir), 0.0, 1.0);
    float fresnel = pow(1.0 - NdotV, 3.5);
    
    // Core bulb glow centered in lens
    float center_dist = length(UV - vec2(0.5, 0.5)) * 2.0;
    float bulb_glow = clamp(1.0 - pow(center_dist, 1.8), 0.0, 1.0);
    
    // Micro prism facet reflections
    float prism_sheen = abs(flute_wave) * 0.35;
    
    ALBEDO = glass_tint.rgb + vec3(prism_sheen * 0.2);
    ALPHA = clamp(glass_tint.a + fresnel * 0.4 + bulb_glow * 0.3, 0.0, 0.95);
    METALLIC = 0.25;
    ROUGHNESS = glass_roughness;
    SPECULAR = 0.90;
    CLEARCOAT = 1.0;
    CLEARCOAT_ROUGHNESS = 0.02;
    
    // Filament emission passing through fluted lens
    EMISSION = bulb_emission.rgb * (emission_energy * (0.35 + bulb_glow * 0.65 + prism_sheen * 0.2));
}
