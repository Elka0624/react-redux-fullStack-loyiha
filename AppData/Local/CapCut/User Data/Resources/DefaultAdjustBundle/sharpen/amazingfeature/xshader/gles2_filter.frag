precision highp float;
uniform sampler2D _MainTex;

varying vec2 uv0;
uniform float intensity;
uniform float inputWidth;
uniform float inputHeight;

#define VIDEO _MainTex

void main() {

    float surfaceWidth=inputWidth;
    float surfaceHeight=inputHeight;

    vec4 color = texture2D(VIDEO, uv0);
    vec4 result_color = color;

    float bitmapMaxLength = max(surfaceHeight, surfaceWidth);
    float f = abs(intensity);

    float f2 = (bitmapMaxLength - 1000.0) / 2000.0;
    f2 = max(0.0, min(f2, 1.0));
    f = ((f * 4.0) * (((1.0 - f2) * 0.65) + (f2 * 1.2))) + 1.0;
    float f3 = (1.0 - f) * 0.25;

    vec4 color_left = texture2D(VIDEO, uv0+vec2(-1.0/surfaceWidth, 0.0));
    vec4 color_right = texture2D(VIDEO, uv0+vec2(1.0/surfaceWidth, 0.0));
    vec4 color_bottom = texture2D(VIDEO, uv0+vec2(0.0, 1.0/surfaceHeight));
    vec4 color_top = texture2D(VIDEO, uv0+vec2(0.0, -1.0/surfaceHeight));
    result_color.rgb = f*result_color.rgb + f3*color_left.rgb + f3*color_right.rgb + f3*color_top.rgb + f3*color_bottom.rgb;

    
    gl_FragColor = result_color;
//    gl_FragColor = vec4(0.3, 0.3, 0.3, 1.0);
}
