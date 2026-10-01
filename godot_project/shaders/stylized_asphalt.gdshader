shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Tiny Glade / Dorfromantik Organic Road & Terrain Blending Shader
// Features:
// 1. Organic edge blending (asphalt -> weathered gravel -> grass intrusion)
// 2. Dynamic wheel-rut wear paths & weathered road markings
// 3. Progressive water accumulation and mirror-reflective puddles
// 4. Procedural rain ripple normal perturbation

global uniform float global_wetness;
global uniform vec3 player_car_pos;

uniform vec4 asphalt_color : source_color = vec4(0.14, 0.15, 0.17, 1.0);
uniform vec4 wheel_rut_color : source_color = vec4(0.08, 0.09, 0.11, 1.0);
uniform vec4 gravel_color : source_color = vec4(0.28, 0.25, 0.21, 1.0);
uniform vec4 grass_blend_color : source_color = vec4(0.26, 0.40, 0.23, 1.0);
uniform vec4 stripe_white : source_color = vec4(0.94, 0.96, 0.98, 1.0);
uniform vec4 stripe_yellow : source_color = vec4(0.96, 0.70, 0.14, 1.0);

uniform float base_roughness : hint_range(0.0, 1.0) = 0.82;
uniform float fallback_wetness : hint_range(0.0, 1.0) = 0.25;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    v += noise2d(p) * 0.50;
    v += noise2d(p * 2.0) * 0.25;
    v += noise2d(p * 4.0) * 0.125;
    return v / 0.875;
}

void fragment() {
    vec2 uv = UV;
    float u = uv.x; // 0.0 left edge to 1.0 right edge
    float v = uv.y; // Along highway length Z
    
    float wet = max(global_wetness, fallback_wetness);
    
    // 1. Base Bituminous Tarmac
    vec3 col = asphalt_color.rgb;
    float rough = base_roughness;
    float metal = 0.04;
    
    // Mineral aggregate micro-noise
    float micro = (hash(floor(uv * vec2(500.0, 250.0))) - 0.5) * 0.06;
    col += micro;
    
    // 2. Wheel-Rut Wear Paths (Darker polished tracks in each lane)
    float rut1 = 1.0 - smoothstep(0.0, 0.05, abs(u - 0.25));
    float rut2 = 1.0 - smoothstep(0.0, 0.05, abs(u - 0.40));
    float rut3 = 1.0 - smoothstep(0.0, 0.05, abs(u - 0.60));
    float rut4 = 1.0 - smoothstep(0.0, 0.05, abs(u - 0.75));
    float ruts = max(max(rut1, rut2), max(rut3, rut4));
    col = mix(col, wheel_rut_color.rgb, ruts * 0.45);
    rough = mix(rough, 0.48, ruts * 0.35);
    
    // 3. Weathered Paint Lines with Micro-chipping
    float line_wear = smoothstep(0.20, 0.75, fbm(vec2(u * 25.0, v * 0.6)));
    
    // Outer white road lines
    float line_l = 1.0 - smoothstep(0.0, 0.007, abs(u - 0.122));
    float line_r = 1.0 - smoothstep(0.0, 0.007, abs(u - 0.878));
    float white_lines = max(line_l, line_r) * line_wear;
    col = mix(col, stripe_white.rgb, white_lines);
    rough = mix(rough, 0.38, white_lines);
    
    // Center yellow dashed line
    float center_line = 1.0 - smoothstep(0.0, 0.008, abs(u - 0.50));
    float dash = step(0.42, fract(v * 0.14));
    float yellow_line = center_line * dash * line_wear;
    col = mix(col, stripe_yellow.rgb, yellow_line);
    rough = mix(rough, 0.35, yellow_line);
    
    // 4. Dorfromantik / Tiny Glade Organic Edge Blending
    // Instead of sharp polygon cuts, asphalt frays into gravel, which blends into grass
    float edge_dist = abs(u - 0.5) * 2.0; // 0.0 at center, 1.0 at edge
    float edge_noise = (fbm(vec2(u * 8.0, v * 0.20)) - 0.5) * 0.22;
    
    // Gravel transition
    float gravel_mask = smoothstep(0.72 + edge_noise, 0.86 + edge_noise, edge_dist);
    col = mix(col, gravel_color.rgb + micro, gravel_mask);
    rough = mix(rough, 0.90, gravel_mask);
    
    // Grass & Moss organic invasion
    float grass_noise = (fbm(vec2(u * 14.0, v * 0.35)) - 0.5) * 0.25;
    float grass_mask = smoothstep(0.85 + grass_noise, 0.98, edge_dist);
    col = mix(col, grass_blend_color.rgb, grass_mask);
    rough = mix(rough, 0.94, grass_mask);
    
    // 5. Dynamic Water Accumulation & Mirror Puddles
    // Rain preferentially gathers in wheel grooves and road depressions
    float p_noise = fbm(vec2(u * 5.0, v * 0.10));
    float puddle_thresh = 1.08 - wet * 1.15;
    float is_puddle = smoothstep(puddle_thresh, puddle_thresh + 0.14, p_noise + ruts * 0.35);
    is_puddle *= (1.0 - grass_mask); // No puddles on grassy verge
    
    // Darken wet asphalt (water refraction in porous bitumen)
    col = mix(col, col * 0.55, wet * 0.75);
    
    // Mirror puddle surface: smooth glass-like roughness and high specularity
    col = mix(col, col * 0.45, is_puddle);
    rough = mix(rough, 0.018, is_puddle);
    metal = mix(metal, 0.05, is_puddle);
    
    // Raindrop ripple perturbation on puddles
    if (wet > 0.30 && is_puddle > 0.08) {
        vec2 rip_uv = uv * vec2(22.0, 11.0);
        float rip1 = sin(length(fract(rip_uv) - 0.5) * 26.0 - TIME * 8.0);
        float rip2 = sin(length(fract(rip_uv + 0.42) - 0.5) * 22.0 - TIME * 6.5);
        vec2 d_norm = vec2(rip1 + rip2) * 0.045 * wet * is_puddle;
        NORMAL = normalize(NORMAL + vec3(d_norm.x, 0.0, d_norm.y));
    }
    
    ALBEDO = col;
    ROUGHNESS = rough;
    METALLIC = metal;
    SPECULAR = mix(0.5, 1.0, is_puddle);
}
