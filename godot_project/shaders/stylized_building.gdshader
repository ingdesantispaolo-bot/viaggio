shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Tiny Glade / Dorfromantik Stylized Building Shader
// Provides procedural stone masonry, irregular mortar joints, rustic plaster,
// and overlapping shingle/tile textures for roofs and walls.

uniform int material_type : hint_range(0, 3) = 0; // 0: Stone/Masonry Wall, 1: Slate Roof, 2: Terracotta Roof, 3: Timber Beam
uniform vec4 base_color : source_color = vec4(0.72, 0.69, 0.64, 1.0);
uniform vec4 alt_color : source_color = vec4(0.58, 0.54, 0.48, 1.0);
uniform vec4 mortar_color : source_color = vec4(0.38, 0.35, 0.32, 1.0);
uniform float texture_scale = 1.8;
uniform float roughness_val = 0.90;

// Simple 2D hash for procedural brick/shingle variation
float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

void fragment() {
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    
    vec3 col = base_color.rgb;
    float rough = roughness_val;
    
    if (material_type == 0) {
        // --- 0. PROCEDURAL STONE MASONRY WALL (Tiny Glade style) ---
        // Project onto dominant vertical plane (X-Y or Z-Y)
        vec2 p = (abs(world_normal.x) > abs(world_normal.z)) ? world_pos.zy : world_pos.xy;
        p *= texture_scale;
        
        // Offset alternate rows for staggered brick/stone bond
        float row = floor(p.y);
        if (mod(row, 2.0) > 0.5) {
            p.x += 0.5;
        }
        
        vec2 id = floor(p);
        vec2 gv = fract(p) - 0.5;
        
        // Random variation per stone
        float rand_stone = hash21(id);
        float rand_stone2 = hash21(id + vec2(17.3, 31.7));
        
        // Mortar joint groove mask
        vec2 edge_dist = abs(gv);
        float edge = max(edge_dist.x, edge_dist.y);
        float joint_mask = smoothstep(0.40, 0.48, edge);
        
        // Stone color variation
        vec3 stone_col = mix(base_color.rgb, alt_color.rgb, rand_stone * 0.7 + rand_stone2 * 0.3);
        
        // Subtle height/corner shadow on each stone
        float bevel = (1.0 - smoothstep(0.30, 0.48, edge)) * 0.15;
        stone_col += vec3(bevel);
        
        col = mix(stone_col, mortar_color.rgb, joint_mask * 0.85);
        rough = mix(roughness_val, 0.96, joint_mask);
        
    } else if (material_type == 1) {
        // --- 1. SLATE ROOF SHINGLES (Alpine Borgo) ---
        vec2 p = vec2(world_pos.x + world_pos.z, world_pos.y * 1.8) * texture_scale;
        float row = floor(p.y);
        if (mod(row, 2.0) > 0.5) p.x += 0.5;
        
        vec2 id = floor(p);
        vec2 gv = fract(p) - 0.5;
        float rand_tile = hash21(id);
        
        float edge = max(abs(gv.x), abs(gv.y));
        float joint_mask = smoothstep(0.42, 0.49, edge);
        
        // Overlapping shingle lip shadow
        float shingle_lip = smoothstep(-0.45, 0.35, gv.y) * 0.18;
        
        vec3 tile_col = mix(base_color.rgb, alt_color.rgb, rand_tile);
        tile_col += vec3(shingle_lip);
        
        col = mix(tile_col, mortar_color.rgb, joint_mask * 0.70);
        rough = 0.82;
        
    } else if (material_type == 2) {
        // --- 2. TERRACOTTA TILES (Tuscan Altopiano) ---
        vec2 p = vec2(world_pos.x + world_pos.z, world_pos.y * 1.5) * texture_scale;
        float row = floor(p.y * 1.5);
        if (mod(row, 2.0) > 0.5) p.x += 0.5;
        
        vec2 id = floor(vec2(p.x * 1.4, row));
        vec2 gv = fract(vec2(p.x * 1.4, p.y * 1.5)) - 0.5;
        float rand_tile = hash21(id);
        
        float joint_mask = smoothstep(0.40, 0.49, abs(gv.x));
        float curve = sin(gv.x * PI) * 0.12; // barrel tile curve highlight
        
        vec3 tile_col = mix(base_color.rgb, alt_color.rgb, rand_tile * 0.6);
        tile_col += vec3(curve);
        
        col = mix(tile_col, mortar_color.rgb, joint_mask * 0.65);
        rough = 0.84;
        
    } else if (material_type == 3) {
        // --- 3. TIMBER BEAM & WOOD GRAIN ---
        float grain = sin(world_pos.y * 22.0 + sin(world_pos.x * 5.0) * 1.5) * 0.08;
        col = mix(base_color.rgb, alt_color.rgb, 0.5 + grain);
        rough = 0.88;
    }
    
    ALBEDO = col;
    ROUGHNESS = rough;
    SPECULAR = 0.15;
}
