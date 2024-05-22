

precision highp float;
varying vec2 texCoord;
varying vec2 sucaiTexCoord;
uniform float intensity;
uniform float opacity;

uniform sampler2D inputTexture;
uniform sampler2D maskImageTexture;
uniform sampler2D lutImageTexture;

uniform int openMouth;
uniform float enableWhitenTeeth;

const float teethDegree = 1.4;

vec4 lut(sampler2D lutTexture, vec4 textureColor) 
{ 
     float blueColor = textureColor.b * 15.0; 
     vec2 quad1; 
     quad1.y = max(min(4.0,floor(floor(blueColor) * 0.25)),0.0); 
     quad1.x = max(min(4.0,floor(blueColor) - (quad1.y * 4.0)),0.0); 
 
     vec2 quad2; 
     quad2.y = max(min(floor(ceil(blueColor) * 0.25),4.0),0.0); 
     quad2.x = max(min(ceil(blueColor) - (quad2.y * 4.0),4.0),0.0); 
 
     vec2 texPos1; 
     texPos1.x = (quad1.x * 0.25) + 0.0078125 + ((0.234375) * textureColor.r); 
     texPos1.y = (quad1.y * 0.25) + 0.0078125 + ((0.234375) * textureColor.g); 
     texPos1.y = texPos1.y;
 
     vec2 texPos2; 
     texPos2.x = (quad2.x * 0.25) + 0.0078125 + ((0.234375) * textureColor.r); 
     texPos2.y = (quad2.y * 0.25) + 0.0078125 + ((0.234375) * textureColor.g);
     texPos2.y = texPos2.y;
 
     vec4 newColor1 = texture2D(lutTexture, texPos1); 
     vec4 newColor2 = texture2D(lutTexture, texPos2); 
 
     vec4 newColor = mix(newColor1, newColor2, fract(blueColor)); 
     return newColor; 
} 
void main()
{
    vec4 src = texture2D(inputTexture, texCoord);
    vec4 mask = texture2D(maskImageTexture, sucaiTexCoord);
    float alpha = (openMouth > 0) ? mask.g : mask.r;      // close, open, teeth
    vec3 colorRes = src.rgb;
 
    if (openMouth > 0 && enableWhitenTeeth > 0.0) { 
        float teethAlpha = mask.b;
        vec4 tem = lut(lutImageTexture, vec4(colorRes, 1.0));
        colorRes = mix(colorRes, tem.rgb, teethAlpha * teethDegree * intensity);
        alpha = alpha + teethAlpha; 
    } 

    colorRes = mix(src.rgb, colorRes, intensity * opacity);
    
    gl_FragColor = vec4(colorRes, src.a);
}

