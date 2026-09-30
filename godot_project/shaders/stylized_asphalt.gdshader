shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Stylized European Highway Asphalt PBR Shader
// Generates crowned tarmac texture, wheel-rut polish, painted road markings,
// gravel shoulders, and wet puddle reflectivity at runtime without image artifacts.

uniform vec4 asphalt_color : source_color = vec4(0.14, 0.15, 0.17, 1.0);
uniform vec4 wheel_rut_color : source_color = vec4(0.09, 0.10, 0.12, 1.0);
uniform vec4 stripe_white : source_color = vec4(0.96, 0.98, 1.0, 1.0);
uniform vec4 stripe_yellow : source_color = vec4(0.98, 0.68, 0.12, 1.0);
uniform vec4 shoulder_gravel_color : source_color = vec4(0.28, 0.24, 0.20, 1.0);

uniform float wetness : hint_range(0.0, 1.0) = 0.25;
uniform float roughness_base : hint_range(0.0, 1.0) = 0.78;

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

void fragment() {
    vec2 uv = UV;
    float u = uv.x; // Across road width (0.0 left shoulder to 1.0 right shoulder)
    float v = uv.y; // Along highway length Z
    
    // 1. Base Bituminous Tarmac
    vec3 col = asphalt_color.rgb;
    float rough = roughness_base;
    float metal = 0.08;
    
    // Mineral aggregate micro-noise
    float noise = (hash21(floor(uv * vec2(600.0, 300.0))) - 0.5) * 0.08;
    col += noise;
    
    // 2. Compacted Gravel Shoulders (outer 11% left and right)
    float left_shoulder = smoothstep(0.12, 0.02, u);
    float right_shoulder = smoothstep(0.88, 0.98, u);
    float shoulder_mask = max(left_shoulder, right_shoulder);
    col = mix(col, shoulder_gravel_color.rgb + noise * 0.5, shoulder_mask);
    rough = mix(rough, 0.92, shoulder_mask);
    
    // 3. Heavy Vehicle Wheel-Rut Wear Paths (Darker polished tracks in each lane)
    // Left lane ruts: u ~ 0.24 and 0.40. Right lane ruts: u ~ 0.60 and 0.76
    float rut1 = 1.0 - smoothstep(0.0, 0.045, abs(u - 0.24));
    float rut2 = 1.0 - smoothstep(0.0, 0.045, abs(u - 0.40));
    float rut3 = 1.0 - smoothstep(0.0, 0.045, abs(u - 0.60));
    float rut4 = 1.0 - smoothstep(0.0, 0.045, abs(u - 0.76));
    float ruts = max(max(rut1, rut2), max(rut3, rut4));
    col = mix(col, wheel_rut_color.rgb, ruts * 0.45);
    rough = mix(rough, 0.42, ruts * 0.4);
    
    // 4. Solid White Outer Highway Fog Lines (Continuous border at u = 0.122 and u = 0.878)
    float line_left = 1.0 - smoothstep(0.0, 0.007, abs(u - 0.122));
    float line_right = 1.0 - smoothstep(0.0, 0.007, abs(u - 0.878));
    float white_lines = max(line_left, line_right);
    col = mix(col, stripe_white.rgb, white_lines);
    rough = mix(rough, 0.35, white_lines);
    
    // 5. Yellow Dashed Centerline (Centered at u = 0.50, 4m dash, 3m gap)
    float center_line = 1.0 - smoothstep(0.0, 0.008, abs(u - 0.50));
    float dash = step(0.42, fract(v * 0.14)); // Dashed pattern along Z
    float yellow_stripe = center_line * dash;
    col = mix(col, stripe_yellow.rgb, yellow_stripe);
    rough = mix(rough, 0.32, yellow_stripe);
    
    // 6. Wet Reflectivity and Specular Glint
    float puddle_noise = hash21(floor(uv * vec2(24.0, 12.0)));
    float is_puddle = step(0.72, puddle_noise) * (1.0 - shoulder_mask);
    col = mix(col, col * 0.65, is_puddle * wetness);
    rough = mix(rough, 0.04, is_puddle * wetness);
    metal = mix(metal, 0.85, is_puddle * wetness);
    
    ALBEDO = col;
    ROUGHNESS = rough;
    METALLIC = metal;
    SPECULAR = 0.5;
}
