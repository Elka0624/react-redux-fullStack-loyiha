precision highp float;

varying vec2 uv;
varying vec2 uRenderSize;
uniform sampler2D inputImageTexture;
uniform vec2 direction;
#define TWO_PI (3.141592653*2.0)


void main()
{
	vec4 curColor = texture2D(inputImageTexture,uv+direction);
	vec4 resultColor = curColor;
	// resultColor.a = 1.0;
	gl_FragColor = resultColor;
}
