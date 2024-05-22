precision highp float;
varying vec2 uv0;
#define textureCoordinate uv0

uniform float inputHeight;
uniform float inputWidth;
uniform float blurStep;

uniform sampler2D _MainTex;
uniform vec2 blurDirection;
uniform mat4 u_InvModel;
#define inputImageTexture _MainTex
#define num 7

#define PI 3.14159265

vec4 directionBlur(sampler2D tex, vec2 resolution, vec2 uv, vec2 directionOfBlur, float intensity)
{
    vec2 pixelStep = 1.0/resolution * intensity;
    float dircLength = length(directionOfBlur);
	pixelStep.x = directionOfBlur.x * 1.0 / dircLength * pixelStep.x;
	pixelStep.y = directionOfBlur.y * 1.0 / dircLength * pixelStep.y;

	vec4 color = vec4(0);
	for(int i = -num; i <= num; i++)
	{
       vec2 blurCoord = uv + pixelStep * float(i);
	   vec2 uvT = vec2(1.0 - abs(abs(blurCoord.x) - 1.0), 1.0 - abs(abs(blurCoord.y) - 1.0));
	   color += texture2D(tex, uvT);
	}
	color /= float(2 * num + 1);	
	return color;
}

void main()
{
	float ratio = inputWidth / inputHeight;

	vec2 uv = (u_InvModel * vec4((uv0.x * 2.0 - 1.0) * ratio, uv0.y * 2.0 - 1.0, 0.0, 1.0)).xy;

	uv.x = (uv.x / ratio + 1.0) / 2.0;
	uv.y = (uv.y + 1.0) / 2.0;

	vec2 resolution = vec2(inputWidth,inputHeight);
	// vec2 realCoord = uvT * resolution;

	vec4 resultColor = directionBlur(inputImageTexture,resolution,uv,blurDirection, blurStep);

	gl_FragColor = vec4(resultColor.rgb, resultColor.a) * step(uv.x, 2.0) * step(uv.y, 2.0) * step(-1.0, uv.x) * step(-1.0, uv.y);
}
