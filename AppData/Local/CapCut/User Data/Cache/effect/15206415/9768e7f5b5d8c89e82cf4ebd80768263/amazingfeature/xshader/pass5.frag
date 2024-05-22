precision highp float;
varying vec2 uv0;

uniform sampler2D inputImageTexture;
uniform sampler2D maskTexture;
uniform int imageWidth;
uniform int imageHeight;
float blendScreen(float base, float blend) {
    return 1.0-((1.0-base)*(1.0-blend));
}

vec4 blendScreen(vec4 base, vec4 blend) {
    return vec4(blendScreen(base.r,blend.r),blendScreen(base.g,blend.g),blendScreen(base.b,blend.b),base.a);
}

vec4 blendLinearDodge(vec4 base, vec4 blend)
{
	return vec4(min(base.rgb+blend.rgb,vec3(1.0)),1.0);
}

void main(void) 
{
    vec2 screenSize = vec2(imageWidth,imageHeight);
    vec4 curColor = texture2D(inputImageTexture,uv0);
    vec4 maskColor = texture2D(maskTexture,uv0);
    vec4 resultColor = curColor;
    resultColor = maskColor;
    resultColor = blendLinearDodge(curColor,resultColor);
    resultColor.a = curColor.a;
    gl_FragColor = resultColor;
}
