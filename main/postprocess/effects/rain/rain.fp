#version 140

in vec2 var_texcoord0;

uniform sampler2D texture_sampler;

uniform input_data {
    vec4 tint;
    vec4 time;
    vec4 resolution;
};

out vec4 frag_color;

float noise(vec2 p) { return fract(sin(dot(p, vec2(256.315, 568.146))) * 38554.14159); }

vec3 getColorFromNoise(vec2 p) {
    float r = noise(p + vec2(13.31, 57.87));
    float g = noise(p + vec2(45.32, 98.21));
    float b = noise(p + vec2(78.12, 23.54));
    return vec3(r, g, b);
}

vec3 sampleGradient(float t) {
    vec3 colorStart = vec3(1.000, 0.000, 0.000); // Example: light blue
    vec3 colorEnd = vec3(0.067, 0.000, 1.000);   // Example: darker blue
    return mix(colorStart, colorEnd, t);
}

float getBrightnessFromNoise(vec2 p) { return mix(0.5, 1.5, noise(p + vec2(89.65, 41.23))); }

// Helper function to convert RGB to HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Helper function to convert HSV to RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Adjust Brightness, Contrast, Hue, Saturation
vec3 adjustBCSH(vec3 col, float brightness, float contrast, float hue, float saturation) {
    // Adjust brightness
    col = col + brightness;

    // Adjust contrast
    col = (col - 0.5) * contrast + 0.5;

    // Convert to HSV for hue and saturation adjustments
    vec3 hsv = rgb2hsv(col);

    // Adjust hue
    hsv.x = fract(hsv.x + hue);

    // Adjust saturation
    hsv.y *= saturation;

    // Convert back to RGB
    col = hsv2rgb(hsv);

    return col;
}

// https://www.shadertoy.com/view/cstcWB
void main() {
    vec2 uv = (var_texcoord0 - .5 * resolution.xy) / resolution.y;
    uv.y -= .5;
    uv.y /= 1.1;
    uv.x *= 1000.;
    float t = time.x / 50.;

    vec2 fuv = floor(uv);
    float bright = 0.9 / getBrightnessFromNoise(fuv);
    float wNoise = noise(fuv);

    float speedVariation = mix(0.5, 1.5, noise(fuv + vec2(12.34,
                                                          56.78))); // Different offsets to get a new noise value
    wNoise -= t * speedVariation;

    vec2 sub = fract(uv - vec2(wNoise));
    sub.y = .24 - sub.y;
    float rain = sub.y;
    float glow = smoothstep(.22, 1., rain) * 50.;
    rain = clamp(rain, 0., 1.);

    float gradientFactor = fract(fuv.x * 1000.3); // Adjust the multiplier for gradient frequency
    vec3 RrainColor = getColorFromNoise(fuv) * .2;

    vec3 rainColor = sampleGradient(gradientFactor);
    rainColor = (rainColor + RrainColor) / 2.;

    vec3 col = rain * rainColor * bright * 2.3;

    float thresholdForGlow = 1.5; // You can adjust this value to suit your needs
    if (bright > thresholdForGlow) {
        float glow = smoothstep(.22, 1., rain) * 50.;
        col += glow * 6.;
    }

    float brightness = 0.00;
    float contrast = 1.10;
    float hue = 1.0 - time.x / 80.;
    float saturation = 1.30;

    col = adjustBCSH(col, brightness, contrast, hue, saturation);

    vec4 color = texture(texture_sampler, var_texcoord0);

    frag_color = mix(color, vec4(col, 0.5), 0.5);
}