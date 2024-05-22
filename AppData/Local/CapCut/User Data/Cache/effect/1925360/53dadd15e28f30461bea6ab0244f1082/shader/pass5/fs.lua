local shader = [[

precision highp float;
varying vec2 uv0;
uniform sampler2D pass5_inputTex_0;

uniform float horizontal;
uniform float radius;

uniform vec4 u_ScreenParams;
//const float weight = 0.2;
const int count = 11;
void main()
{
	vec2 tex_offset = mix(radius,4.0 * radius,horizontal) / vec2(720); // gets size of single texel
	vec4 diffuse = texture2D(pass5_inputTex_0, uv0);
	vec4 result = diffuse;
	for (int i = 1; i <= count; ++i)
	{
		result += texture2D(pass5_inputTex_0, uv0 + vec2(tex_offset.x * float(i), 0.0)); 
		result += texture2D(pass5_inputTex_0, uv0 - vec2(tex_offset.x * float(i), 0.0));
	}
	gl_FragColor = result / float(2*count+1);
}
]]
return shader