precision highp float;
varying vec2 maskTexCoord;
uniform sampler2D inputImageMaskTexture;

void main()
{
    lowp vec4 maskColor = texture2D(inputImageMaskTexture, maskTexCoord);
    gl_FragColor = vec4(maskColor.rgb, 1.0);
}