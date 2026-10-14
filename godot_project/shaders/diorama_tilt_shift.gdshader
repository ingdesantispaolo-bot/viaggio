shader_type canvas_item;

// THE LONG MERIDIAN - Art of Rally / Tiny Glade Optical Tilt-Shift Miniature Lens
// Simulates an optical tilt-shift diorama lens with horizontal focal plane,
// creamy Poisson-disk circle of confusion (CoC), subtle optical chromatic aberration,
// and soft peripheral vignetting.

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool enable_tilt_shift = true;
uniform float focus_plane_y : hint_range(0.0, 1.0) = 0.58;
uniform float focus_band_width : hint_range(0.02, 1.0) = 0.65;
uniform float max_blur_radius : hint_range(0.0, 24.0) = 1.8;
uniform float chromatic_aberration : hint_range(0.0, 4.0) = 0.08;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.10;
uniform vec4 vignette_color : source_color = vec4(0.03, 0.05, 0.08, 1.0);

void fragment() {
    vec2 uv = SCREEN_UV;
    
    if (!enable_tilt_shift || max_blur_radius <= 0.01) {
        COLOR = texture(SCREEN_TEXTURE, uv);
    } else {
        // Distance from the horizontal focal plane band (car & road corridor in full sharp focus)
        float dist_from_focus = abs(uv.y - focus_plane_y);
        float blur_factor = smoothstep(focus_band_width * 0.5, focus_band_width * 1.5, dist_from_focus);
        
        // Non-linear blur growth for creamy optical bokeh circle of confusion
        blur_factor = pow(blur_factor, 1.8);
        
        vec4 c_center = texture(SCREEN_TEXTURE, uv);
        vec4 sum_color = c_center * 2.5;
        float total_weight = 2.5;
        
        // 16-tap Poisson disk distribution for velvety miniature bokeh
        vec2 samples[16] = vec2[](
            vec2( 0.00,  1.00), vec2( 0.92,  0.38), vec2( 0.71, -0.71), vec2(-0.38, -0.92),
            vec2(-1.00,  0.00), vec2(-0.71,  0.71), vec2( 0.38,  0.92), vec2( 0.92, -0.38),
            vec2( 0.00,  0.55), vec2( 0.51,  0.21), vec2( 0.39, -0.39), vec2(-0.21, -0.51),
            vec2(-0.55,  0.00), vec2(-0.39,  0.39), vec2( 0.21,  0.51), vec2( 0.51, -0.21)
        );
        
        vec2 blur_step = (blur_factor * max_blur_radius) * SCREEN_PIXEL_SIZE;
        vec2 ca_offset = blur_step * chromatic_aberration * 0.18;
        
        for (int i = 0; i < 16; i++) {
            vec2 offset_uv = uv + samples[i] * blur_step;
            float sample_weight = 1.0 - (float(i) / 32.0);
            
            // Chromatic aberration fringe on out-of-focus highlights
            float r_chan = texture(SCREEN_TEXTURE, offset_uv + ca_offset).r;
            float g_chan = texture(SCREEN_TEXTURE, offset_uv).g;
            float b_chan = texture(SCREEN_TEXTURE, offset_uv - ca_offset).b;
            float a_chan = texture(SCREEN_TEXTURE, offset_uv).a;
            
            sum_color += vec4(r_chan, g_chan, b_chan, a_chan) * sample_weight;
            total_weight += sample_weight;
        }
        
        vec4 bokeh_color = sum_color / total_weight;
        vec4 final_color = mix(c_center, bokeh_color, clamp(blur_factor * 2.5, 0.0, 1.0));
        
        // Soft peripheral diorama vignette
        vec2 vig_uv = (uv - 0.5) * vec2(1.0, 0.85);
        float vig_dist = length(vig_uv);
        float vig_mask = smoothstep(0.44, 0.82, vig_dist);
        final_color = mix(final_color, vignette_color, vig_mask * vignette_strength);
        
        COLOR = final_color;
    }
}
