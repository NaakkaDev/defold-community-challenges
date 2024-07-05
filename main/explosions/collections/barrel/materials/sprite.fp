// https://forum.defold.com/t/shaders-for-beginners/66622

varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 blink_trigger;

void main()
{
    // Write a color of the current pixel to a variable
    lowp vec4 color_of_pixel = texture2D(texture_sampler, var_texcoord0.xy);

	// Check if the blink trigger red (first vec4 value) is "on (1.0)"
	// then check if the alpha value of this pixel is not nil (0.0) then it is a visible pixel
    if ((blink_trigger.r == 1.0) && (color_of_pixel.a != 0.0))
    {
		// Set the color of this visible pixel white
        color_of_pixel = vec4(1.0, 1.0, 1.0, 1.0);
    }

	// Write the pixel color to the output
    gl_FragColor = color_of_pixel;
}
