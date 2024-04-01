precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputImageTexture;
uniform sampler2D waterMarkTexture;
uniform float ratioX;
uniform float ratioY;
uniform float factor;

void main()
{
    vec2 waterUV = vec2(uv0.x * ratioX * factor, 0.0 - uv0.y * ratioY * factor);
    vec4 waterMarkColor = texture2D(waterMarkTexture,waterUV);

    vec4 inputColor = texture2D(inputImageTexture, uv0);
    gl_FragColor = mix(inputColor,waterMarkColor,waterMarkColor.a);
}
