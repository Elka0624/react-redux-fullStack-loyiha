precision highp float;
varying vec2 uv0;

uniform sampler2D inputImageTexture;
uniform sampler2D blurTexture;
uniform int imageWidth;
uniform int imageHeight;
uniform float intensity;
float blendScreen(float base, float blend) {
    return 1.0-((1.0-base)*(1.0-blend));
}

vec4 blendScreen(vec4 base, vec4 blend) {
    return vec4(blendScreen(base.r,blend.r),blendScreen(base.g,blend.g),blendScreen(base.b,blend.b),base.a);
}

vec4 getEdge(sampler2D inputTexture,sampler2D inputTexture1,vec2 uv)
{
    float amplify = 8.0;
    vec3 grayW = vec3(0.299,0.587,0.114);
    vec4 curColor = texture2D(inputTexture,uv);
    vec4 blurColor = texture2D(inputTexture1,uv);
    float curGray = dot(curColor.rgb,grayW);
    float blurGray = dot(blurColor.rgb,grayW);
    float diffGray = curGray-blurGray;
    if(diffGray<0.0)   
        diffGray *= -amplify;
    else             
        diffGray *= amplify*0.5; 

    vec4 diffColor = vec4(vec3(diffGray),1.0);
    diffColor = abs(curColor-blurColor)*intensity;	
    diffColor = step(vec4(0.1),diffColor)*diffColor;
    diffColor.a = 1.0;
    
    return diffColor;
}

void main(void) 
{
    vec2 screenSize = vec2(imageWidth,imageHeight);

    vec4 maskColor = getEdge(inputImageTexture,blurTexture,uv0);

    vec4 edgeColor = vec4(0.2902, 0.9333, 0.3647, 1.0);


    vec4 curColor = texture2D(inputImageTexture,uv0);
    vec4 resultColor = blendScreen(curColor,edgeColor);
    resultColor = mix(curColor,resultColor,maskColor.r);

    resultColor = maskColor;

    gl_FragColor = resultColor;
}
