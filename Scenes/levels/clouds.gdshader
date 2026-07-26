shader_type canvas_item;

// Diese Textur MUSST du im Inspektor zuweisen (siehe Schritt 2)
uniform sampler2D noise_texture : repeat_enable, filter_linear_mipmap;

uniform vec2 speed = vec2(0.03, 0.01); // Geschwindigkeit der Wolken
uniform float density : hint_range(0.0, 1.0) = 0.4; // Wie viele Wolken (kleinerer Wert = mehr Wolken)
uniform float softness : hint_range(0.01, 1.0) = 0.15; // Wie weich die Ränder sind

uniform vec4 sky_color : source_color = vec4(0.2, 0.5, 0.9, 1.0);   // Hintergrund-Blau
uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Wolken-Weiß

void fragment() {
    // Bewegt die UV-Koordinaten unendlich in eine Richtung
    vec2 moving_uv = UV + (speed * TIME);
    
    // Liest den Rotkanal der Noise-Textur aus
    float noise_value = texture(noise_texture, moving_uv).r;
    
    // Erzeugt die Wolkenform mit weichen Kanten
    float cloud_factor = smoothstep(density, density + softness, noise_value);
    
    // Mischt das Blau und das Weiß basierend auf dem Wolken-Faktor
    COLOR = mix(sky_color, cloud_color, cloud_factor);
}
