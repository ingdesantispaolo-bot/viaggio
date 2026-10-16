shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Vintage Tire Rubber Shader (Pirelli Cinturato / Michelin XZX)
// Simulates vulcanized matte tire rubber with circumferential tread grooves,
// micro-roughness, and subtle sidewall curvature highlights.

uniform vec4 rubber_color : source_color = vec4(0.09, 0.09, 0.10, 1.0);
uniform float rubber_roughness : hint_range(0.0, 1.0) = 0.88;
uniform float tread_depth : hint_range(0.0, 1.0) = 0.65;
uniform float tread_frequency : hint_range(2.0, 20.0) = 8.0;

void fragment() {
    // Circumferential tread ribs along UV.y
    float tread_pattern = step(0.40, sin(UV.y * tread_frequency * 6.28318));
    
    // Normal depression in groove
    vec3 n = NORMAL;
    if (tread_pattern < 0.5) {
        n = normalize(n + vec3(0.0, 0.0, -tread_depth * 0.3));
    }
    
    vec3 view_dir = normalize(VIEW);
    float NdotV = clamp(dot(n, view_dir), 0.0, 1.0);
    float sheen = pow(1.0 - NdotV, 5.0) * 0.15;
    
    ALBEDO = rubber_color.rgb + vec3(sheen);
    METALLIC = 0.04;
    ROUGHNESS = mix(rubber_roughness, 0.98, 1.0 - tread_pattern);
    SPECULAR = 0.18;
}
