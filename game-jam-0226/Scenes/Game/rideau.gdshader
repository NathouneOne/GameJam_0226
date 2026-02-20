shader_type canvas_item;

uniform float velocity = 100.0;
uniform float lag_strength : hint_range(0.0, 0.01) = 0.005;

void vertex() {
    float t = UV.y; // 0 = top, 1 = bottom

    // Cubic easing for smooth top → bottom transition
    float influence = t * t * (3.0 - 2.0 * t);

    // Exaggerate curvature more
    influence = pow(influence, 1.5);        // increase non-linearity
    influence *= sin(t * 1.57) * 1.3;      // scale sine for stronger bottom effect

    // Apply horizontal offset
    VERTEX.x -= velocity * lag_strength * influence * 10.0;
}