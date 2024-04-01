precision highp float;
varying vec2 uv0;

uniform sampler2D inputImageTexture;

uniform int imageWidth;
uniform int imageHeight;

uniform int lightNoise;
uniform int darkNoise;
uniform float grayIns;

float hash13(vec3 p3)
{
	p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

int randRange(int a, int b) {
    return int(hash13(gl_FragCoord.xyz) * float(b - a) + float(a));
}

vec3 rgb2yuv(float r, float g, float b) {
	return vec3(
        floor(r *  .299000 + g *  .587000 + b *  .114000),
        floor(r * -.168736 + g * -.331264 + b *  .500000 + 128.),
        floor(r *  .500000 + g * -.418688 + b * -.081312 + 128.)
    );
}

vec3 yuv2rgb(float y, float u, float v) {
	return vec3(
        clamp(floor(y + 1.4075 * (v - 128.)), 0., 255.),
        clamp(floor(y - 0.3455 * (u - 128.) - (0.7169 * (v - 128.))), 0., 255.),
        clamp(floor(y + 1.7790 * (u - 128.)), 0., 255.)
    );
}

void main(void) 
{
    vec2 screenSize = vec2(imageWidth, imageHeight);
    vec4 color = texture2D(inputImageTexture, uv0);
    float gray = dot(color.rgb,vec3(0.299 ,0.587,0.114));
    color.rgb *= 255.;
    color.rgb = rgb2yuv(color.r, color.g, color.b);

    // noise
    

    float ins=mix(grayIns,1.0,gray);
    vec2 myNoise=vec2(lightNoise,darkNoise)*vec2(ins);
    int mylightNoise=int(myNoise.x);
    int mydarkNoise=int(myNoise.y);

    color.r += float(randRange(0, mylightNoise) - mylightNoise / 2);
    color.r += float(randRange(0, mydarkNoise) - mydarkNoise / 2) * (255. - color.r) / 255.;

// #if INVERTLIGHT == 1
//     color.r = 255. - color.r;
// #endif

    color.rgb = yuv2rgb(color.r, color.g, color.b) / 255.;
    vec4 resultCol = color;
    gl_FragColor = clamp(resultCol, 0.0, resultCol.a);
}

