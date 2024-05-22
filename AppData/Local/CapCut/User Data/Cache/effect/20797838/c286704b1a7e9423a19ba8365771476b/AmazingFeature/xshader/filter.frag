#version 300 es
precision highp sampler3D;
precision highp float;
in vec2 uv0;
#define textureCoordinate uv0
uniform sampler2D VIDEO;
#define inputImageTexture VIDEO
uniform sampler3D u_albedo;
#define inputImageTexture2 u_albedo
uniform float uniAlpha;
out vec4 fragColor;

vec4 sampleLut(vec4 baseColor)
{
    return texture(inputImageTexture2, baseColor.rgb);
}

void main() 
{
    vec4 srcColor = texture(inputImageTexture, textureCoordinate);
    vec4 newColor = srcColor;
    newColor.xyz = sampleLut(srcColor).xyz;
    fragColor = vec4(mix(srcColor.rgb, newColor.rgb, uniAlpha), srcColor.a);
}
