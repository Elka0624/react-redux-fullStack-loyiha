precision mediump float;
varying highp vec2 textureCoord;

varying highp vec2 textureShift_1;
varying highp vec2 textureShift_2;
varying highp vec2 textureShift_3;
varying highp vec2 textureShift_4;

uniform sampler2D _MainTex;
#define srcImageTex _MainTex
uniform sampler2D blurImageTex;
uniform sampler2D beautyMaskTexture;
uniform sampler2D skinMask;

uniform lowp float useMask;
uniform lowp float defaultMaskValue;

uniform lowp float smoothIntensity;
uniform lowp float sharpIntensity;
uniform lowp float eyeDetailIntensity;
uniform lowp float removePouchIntensity;
uniform lowp float removeLaughlineIntensity;

const float theta = 0.1;

void main()
{
    lowp vec4 inColor = texture2D(srcImageTex, textureCoord);
    lowp vec4 preColor = texture2D(blurImageTex, textureCoord);     // used by smooth, eye detail, remove laughline, remove pouch
    lowp vec3 meanColor = preColor.rgb;
    lowp vec4 maskColor = texture2D(beautyMaskTexture, vec2(textureCoord.x, 1.0 - textureCoord.y ));
    lowp vec4 skinColor =  texture2D(skinMask, vec2(textureCoord.x, 1.0 - textureCoord.y)).rgba;

    float maskValue = 0.0;
    float activeIntensity = smoothIntensity;
    if (maskColor.g > 0.1)
    {
        maskValue = maskColor.g;
        activeIntensity = maskColor.g * smoothIntensity * (1.0 - maskColor.r);
    }else if(skinColor.a > 0.1)
    {
        maskValue = skinColor.a;
        activeIntensity = skinColor.a * smoothIntensity;
    }

    //firstly, smooth
    lowp vec3 smoothColor = inColor.rgb;
    if (activeIntensity > 0.01) {        
        mediump float p = clamp((min(inColor.r, meanColor.r-0.1)-0.2)*4.0, 0.0, 1.0);
        mediump float kMin = (1.0 - preColor.a / (preColor.a + theta)) * p * activeIntensity;
        
        // #### output 1
        smoothColor = mix(inColor.rgb, meanColor.rgb, kMin * maskValue);
    }

    //secondly, sharpen

    vec3 epmColor = smoothColor;
    gl_FragColor = vec4(epmColor, inColor.a);
}