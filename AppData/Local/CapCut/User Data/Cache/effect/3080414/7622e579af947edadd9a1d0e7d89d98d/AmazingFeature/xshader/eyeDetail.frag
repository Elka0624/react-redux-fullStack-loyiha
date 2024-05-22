precision highp float;
varying vec2 texCoord;
varying vec2 sucaiTexCoord;
varying vec2 textureShift_1;
varying vec2 textureShift_2;
varying vec2 textureShift_3;
varying vec2 textureShift_4;

// uniform sampler2D _MainTex;
// #define inputImageTexture _MainTex
uniform sampler2D inputImageTexture;
uniform sampler2D inputScaledTexture;
uniform sampler2D inputScaledBlurTexture;
uniform sampler2D inputImageMaskTexture;
uniform sampler2D lutImageTexture;

uniform float intensity;
uniform float eyeDetailIntensity;
uniform float removePouchIntensity;
uniform float removeNasolabialFoldsIntensity;
uniform vec2 inputSize;

#define USE_SEG 1
#ifdef USE_SEG
varying vec2 segCoord;
uniform sampler2D segMaskTexture;
#endif


vec4 LUT8x8(vec4 inColor, sampler2D lutImageTexture)
{
    highp float blueColor = inColor.b * 63.0;
    
    highp vec2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    highp vec2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);
    
    highp vec2 texPos1 = (quad1.xy * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * inColor.rg);
    highp vec2 texPos2 = (quad2.xy * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * inColor.rg);
    
    lowp vec4 newColor2_1 = texture2D(lutImageTexture, texPos1);
    lowp vec4 newColor2_2 = texture2D(lutImageTexture, texPos2);

    lowp vec4 newColor22 = mix(newColor2_1, newColor2_2, fract(blueColor));

    return newColor22;
}

void main()
{
    vec4 color = texture2D(inputImageTexture, texCoord);
    mediump vec4 maskColor = texture2D(inputImageMaskTexture, sucaiTexCoord);
    vec3 resultColor = color.rgb;
    float border = 0.1;

    // bright eye
    if(maskColor.g > border && maskColor.r > border && eyeDetailIntensity >= 0.01)
    {
        highp vec2 step1 = vec2(0.00208, 0.0);
        highp vec2 step2 = vec2(0.0, 0.00134);
        highp vec3 sumColor = vec3(0.0, 0.0, 0.0);
        for(float t = -2.0; t < 2.5; t += 1.0)
        {
            for(float p = -2.0;p < 2.5; p += 1.0)
            {
                sumColor += texture2D(inputImageTexture,texCoord + t * step1 + p * step2).rgb;
            }
        }
        sumColor = sumColor * 0.04;
        sumColor = clamp(sumColor + (color.rgb - sumColor) * 3.0, 0.0, 1.0);
        sumColor = max(color.rgb, sumColor);
        resultColor = mix(color.rgb, sumColor, eyeDetailIntensity * maskColor.g * 0.5);
    }

    // strip eye bag
    if(maskColor.r > border && maskColor.g < border && removePouchIntensity >= 0.01)
    {
        lowp vec3 scaledColor = texture2D(inputScaledTexture, texCoord).rgb;
        lowp vec3 scaledBlurColor = texture2D(inputScaledBlurTexture, texCoord).rgb;

        lowp vec3 highColor = color.rgb - scaledColor;
        lowp vec3 newColor = scaledBlurColor + highColor; 
        lowp float diff = clamp(15.0 * (newColor.r - color.r) + 1.0, 0.0, 1.0); 

        // lighten up dark areas
        vec4 originColor = vec4(newColor.rgb, 1.0);
        vec4 brightColor = LUT8x8(originColor, lutImageTexture);
        newColor = mix(newColor.rgb, brightColor.rgb, maskColor.r * 0.4);

        // high frequency reservation
        mediump vec3 sum = texture2D(inputImageTexture, textureShift_1).rgb;
        sum += texture2D(inputImageTexture, textureShift_2).rgb;
        sum += texture2D(inputImageTexture, textureShift_3).rgb;
        sum += texture2D(inputImageTexture, textureShift_4).rgb;
        sum = sum * 0.25;

        vec3 hColor = clamp((color.rgb - sum) / 2.0 + 0.5, 0.0, 1.0);
        vec3 evenColor = clamp(newColor.rgb + 2.0 * hColor.rgb - 1.0, vec3(0.0), vec3(1.0));
        float removePouchIntensityValue = removePouchIntensity * 1.25;
        resultColor = mix(resultColor, evenColor, removePouchIntensityValue * maskColor.r * diff);
    }

    // strip Nasolabial folds
    if(maskColor.g > border && maskColor.r < border && removeNasolabialFoldsIntensity >= 0.01)
    {
        lowp vec3 scaledColor = texture2D(inputScaledTexture, texCoord).rgb;
        lowp vec3 scaledBlurColor = texture2D(inputScaledBlurTexture, texCoord).rgb;

        lowp vec3 highColor = color.rgb - scaledColor;
        lowp vec3 newColor = scaledBlurColor + highColor; 
        // lowp float diff = 1.0;
        float ratio = 1080.0 / inputSize.x;
        if (ratio < 1.0)
        {
            ratio = 1.0;
        }
        float diff = clamp(ratio * 5.0 * (newColor.r - color.r) + 1.0, 0.0, 1.0);

        // lighten up dark areas
        vec4 originColor = vec4(newColor.rgb, 1.0);
        vec4 brightColor = LUT8x8(originColor, lutImageTexture);
        newColor = mix(newColor.rgb, brightColor.rgb, maskColor.g * 0.4);

        // high frequency reservation
        mediump vec3 sum = texture2D(inputImageTexture, textureShift_1).rgb;
        sum += texture2D(inputImageTexture, textureShift_2).rgb;
        sum += texture2D(inputImageTexture, textureShift_3).rgb;
        sum += texture2D(inputImageTexture, textureShift_4).rgb;
        sum = sum * 0.25;

        vec3 hColor = clamp((color.rgb - sum) / 2.0 + 0.5, 0.0, 1.0);
        vec3 evenColor = clamp(newColor.rgb + 2.0 * hColor.rgb - 1.0, vec3(0.0), vec3(1.0));
        float removeNasolabialFoldsIntensityValue = removeNasolabialFoldsIntensity * 1.25;
        resultColor = mix(resultColor, evenColor, removeNasolabialFoldsIntensityValue * maskColor.g * diff);
    }
    
    #ifdef USE_SEG
    float seg_opacity = (texture2D(segMaskTexture, segCoord)).x;
    if(clamp(segCoord, 0.0, 1.0) != segCoord) seg_opacity = 1.;
    resultColor = mix(color.rgb, resultColor, seg_opacity);
#endif

    gl_FragColor = vec4(mix(color.rgb, resultColor, intensity), color.a);
}