shader_type canvas_item;

// --- Tunable parameters (expose these in the material) ---
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.4; // overall strength
uniform float glitch_speed : hint_range(0.1, 20.0) = 8.0;    // how fast glitches trigger
uniform float rgb_split_amount : hint_range(0.0, 0.05) = 0.015; // chromatic split distance
uniform float block_size : hint_range(1.0, 50.0) = 12.0;     // size of tear blocks
uniform float color_shift_chance : hint_range(0.0, 1.0) = 0.5; // chance a block gets recolored
uniform vec3 base_color : source_color = vec3(1.0, 1.0, 1.0); // normal (non-glitched) text color
uniform bool enabled = true;

// Simple pseudo-random generator based on a seed value
float rand(float seed) {
    return fract(sin(seed * 12.9898) * 43758.5453);
}

// Cheap HSV-ish rainbow generator driven by a single random value
vec3 glitch_palette(float seed) {
    float r = rand(seed);
    if (r < 0.2) return vec3(1.0, 0.0, 1.0);      // magenta
    if (r < 0.4) return vec3(0.0, 1.0, 1.0);      // cyan
    if (r < 0.6) return vec3(1.0, 0.0, 0.2);      // red
    if (r < 0.8) return vec3(0.2, 1.0, 0.2);      // green
    return vec3(1.0, 1.0, 0.0);                   // yellow
}

void fragment() {
    vec2 uv = UV;

    if (enabled) {
        // Time bucket: changes every 1/glitch_speed seconds, making the glitch feel "stepped" not smooth
        float time_bucket = floor(TIME * glitch_speed);

        // Decide, per time_bucket, whether a glitch "burst" happens right now
        float burst = step(1.0 - glitch_intensity, rand(time_bucket));

        // --- Horizontal block tearing ---
        float block_id = floor(uv.y * block_size);
        float block_seed = block_id + time_bucket;
        float tear_offset = (rand(block_seed) - 0.5) * glitch_intensity * burst * 0.15;
        uv.x += tear_offset;

        // --- RGB channel split (offsets the ALPHA/shape, since color itself is flat) ---
        float split = rgb_split_amount * burst;
        float a_r = texture(TEXTURE, uv + vec2(split, 0.0)).a;
        float a_g = texture(TEXTURE, uv).a;
        float a_b = texture(TEXTURE, uv - vec2(split, 0.0)).a;

        // --- Decide this block's color ---
        float color_roll = rand(block_seed + 99.0);
        float should_corrupt = burst * step(1.0 - color_shift_chance, color_roll);
        vec3 col = should_corrupt > 0.5 ? glitch_palette(block_seed + 42.0) : base_color;

        // Combine the three offset alpha samples so the split is visible as colored ghosting
        // (each "channel" shows a slightly shifted silhouette tinted by col)
        float combined_alpha = max(a_r, max(a_g, a_b));
        vec3 ghost_color = mix(col, vec3(1.0, 0.3, 1.0) * a_r + vec3(0.3, 1.0, 1.0) * a_b, split > 0.0 ? 0.5 : 0.0);

        COLOR = vec4(ghost_color, combined_alpha);
    } else {
        COLOR = texture(TEXTURE, uv);
    }
}