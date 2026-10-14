shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Historic Italian Porphyry Cobblestone Shader (Pavé di Porfido Trentino & Sanpietrini)
// Recreates authentic medieval / renaissance village roads:
// 1. Interlocking staggered stone setts (cubetti di porfido 10x10cm) with natural color variation
// 2. Recessed sand-and-lime mortar joints (fughe di posa in malta)
// 3. Worn tire track polish (levigatura da passaggio ruote)
// 4. White granite curb edging (cordolo in granito bianco di Montorfano)
// 5. Dynamic wetness gloss with mirror puddles in cobblestone depressions

global uniform float global_wetness;

uniform vec4 porphyry_red : source_color = vec4(0.44, 0.33, 0.30, 1.0);
uniform vec4 porphyry_grey : source_color = vec4(0.33, 0.34, 0.36, 1.0);
uniform vec4 porphyry_ochre : source_color = vec4(0.50, 0.44, 0.36, 1.0);
uniform vec4 mortar_color : source_color = vec4(0.25, 0.24, 0.22, 1.0);
uniform vec4 granite_curb_color : source_color = vec4(0.68, 0.69, 0.72, 1.0);
uniform float block_scale : hint_range(4.0, 32.0) = 14.0;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise2D(vec2 p) {
    vec2 id = floor(p);
    vec2 lv = fract(p);
    lv = lv * lv * (3.0 - 2.0 * lv);
    
    float bl = hash21(id);
    float br = hash21(id + vec2(1.0, 0.0));
    float tl = hash21(id + vec2(0.0, 1.0));
    float tr = hash21(id + vec2(1.0, 1.0));
    
    return mix(mix(bl, br, lv.x), mix(tl, tr, lv.x), lv.y);
}

void fragment() {
    float u = UV.x;
    float v = UV.y;
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Grid of porphyry cubic setts
    vec2 uv_blocks = vec2(u * 8.0, v * 12.0) * (block_scale / 10.0);
    // Stagger every second row (posa a corsi sfalsati)
    float row = floor(uv_blocks.y);
    uv_blocks.x += mod(row, 2.0) * 0.50;
    
    vec2 block_id = floor(uv_blocks);
    vec2 block_uv = fract(uv_blocks);
    
    float rnd = hash21(block_id);
    float rnd2 = hash21(block_id + vec2(7.3, 11.9));
    
    // Mortar joint edge distance
    vec2 edge_dist = abs(block_uv - 0.5);
    float edge_max = max(edge_dist.x, edge_dist.y);
    float joint_mask = smoothstep(0.40, 0.49, edge_max);
    
    // Slight crown dome on each individual stone sett
    float stone_crown = 1.0 - smoothstep(0.0, 0.5, length(block_uv - 0.5));
    
    // Stone color blending: Red porphyry, grey basalt, warm ochre
    vec3 stone_col;
    if (rnd < 0.45) {
        stone_col = mix(porphyry_red.rgb, porphyry_grey.rgb, rnd2 * 0.4);
    } else if (rnd < 0.80) {
        stone_col = mix(porphyry_grey.rgb, porphyry_ochre.rgb, rnd2 * 0.45);
    } else {
        stone_col = mix(porphyry_ochre.rgb, porphyry_red.rgb, rnd2 * 0.35);
    }
    
    // Micro-texture of crystalline rock
    float grain = noise2D(world_pos.xz * 36.0) * 0.16;
    stone_col += vec3((grain - 0.08) * 0.22);
    stone_col += stone_crown * 0.08;
    
    // Base composition: Stone blocks vs Mortar joints
    vec3 col = mix(stone_col, mortar_color.rgb, joint_mask);
    float rough = mix(0.72 - stone_crown * 0.10, 0.94, joint_mask);
    float spec = mix(0.22, 0.08, joint_mask);
    
    // Worn wheel paths (centuries of wheels have polished the center of the lanes)
    float rut1 = smoothstep(0.14, 0.0, abs(u - 0.32));
    float rut2 = smoothstep(0.14, 0.0, abs(u - 0.68));
    float wheel_wear = max(rut1, rut2);
    col = mix(col, col * 0.92, wheel_wear * 0.3);
    rough = mix(rough, 0.42, wheel_wear * 0.45);
    spec = mix(spec, 0.38, wheel_wear * 0.40);
    
    // Granite Curb Borders (Cordoli laterali continui in granito bianco scalpellato)
    float curb_left = smoothstep(0.09, 0.07, u);
    float curb_right = smoothstep(0.91, 0.93, u);
    float curb_mask = max(curb_left, curb_right);
    if (curb_mask > 0.01) {
        float curb_grain = noise2D(world_pos.xz * 28.0) * 0.15;
        // Granite joint every 1.5m
        float curb_joint = smoothstep(0.04, 0.01, abs(fract(v * 0.8) - 0.5));
        vec3 g_col = granite_curb_color.rgb + vec3(curb_grain - 0.07);
        g_col = mix(g_col, mortar_color.rgb, curb_joint * 0.6);
        col = mix(col, g_col, curb_mask);
        rough = mix(rough, 0.82, curb_mask);
        spec = mix(spec, 0.18, curb_mask);
    }
    
    // Dynamic rain gloss and puddle accumulation in mortar joints
    float wet = clamp(global_wetness, 0.0, 1.0);
    if (wet > 0.01) {
        float puddle = clamp(joint_mask * 1.5 + (1.0 - stone_crown) * 0.5, 0.0, 1.0) * wet;
        col = mix(col, col * 0.55, wet * 0.5);
        col = mix(col, vec3(0.07, 0.08, 0.10), puddle * 0.7);
        rough = mix(rough, 0.08, puddle * 0.90 + wet * 0.35);
        spec = mix(spec, 0.88, puddle * 0.88 + wet * 0.35);
    }
    
    ALBEDO = col;
    ROUGHNESS = rough;
    SPECULAR = spec;
}
