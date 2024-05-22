precision highp float;
varying highp vec2 textureCoordinate;
varying highp vec4 textureShift_1;
varying highp vec4 textureShift_2;

uniform sampler2D _MainTex;
#define inputImageTexture _MainTex
// uniform sampler2D inputImageTexture;       //ori

#define USE_SEG 1
#ifdef USE_SEG
varying highp vec4 textureShift_3;
uniform sampler2D segMaskTexture;
#endif

void main()
{
    mediump vec4 src = texture2D(inputImageTexture, textureCoordinate);
    mediump vec3 sum = src.rgb;

#ifdef USE_SEG
    lowp float seg_offset = (texture2D(segMaskTexture, textureShift_3.xy)).x;
    lowp float seg_offset2 = (texture2D(segMaskTexture, textureShift_3.zw)).x;
    if(seg_offset < 0.9 || seg_offset2 < 0.9)
    {
        sum *= 5.0;
    }
    else
    {
        sum += texture2D(inputImageTexture, textureShift_1.xy).rgb;
        sum += texture2D(inputImageTexture, textureShift_1.zw).rgb;
        sum += texture2D(inputImageTexture, textureShift_2.xy).rgb;
        sum += texture2D(inputImageTexture, textureShift_2.zw).rgb;
    }
#else
        sum += texture2D(inputImageTexture, textureShift_1.xy).rgb;
        sum += texture2D(inputImageTexture, textureShift_1.zw).rgb;
        sum += texture2D(inputImageTexture, textureShift_2.xy).rgb;
        sum += texture2D(inputImageTexture, textureShift_2.zw).rgb;
#endif
    gl_FragColor = vec4(sum * 0.2, src.a);
}