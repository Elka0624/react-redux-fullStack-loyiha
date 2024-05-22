
local shader = [[
precision highp float;
varying vec2 uv0;
uniform sampler2D pass6_inputTex_0;
uniform sampler2D pass6_inputTex_1;
uniform sampler2D _MainTex;

uniform float horizontal;
uniform float radius;
uniform float alpha;

uniform vec4 u_ScreenParams;
//const float weight = 0.2;
const int count = 11;

void main()
{
	vec2 tex_offset = mix(4.0 * radius,radius,horizontal) / vec2(720); // gets size of single texel
	vec4 diffuse = texture2D(pass6_inputTex_0, uv0);
	vec4 result = diffuse;
	for (int i = 1; i <= count; ++i)
	{
		result += texture2D(pass6_inputTex_0, uv0 + vec2(0.0, tex_offset.y * float(i)));
		result += texture2D(pass6_inputTex_0, uv0 - vec2(0.0, tex_offset.y * float(i)));
	}
	vec4 srcColor = texture2D(pass6_inputTex_1,uv0);
	vec4 blurColor = result / float(2*count+1) * radius * 0.5;
	blurColor = clamp(blurColor,0.0,1.0);
	gl_FragColor = (srcColor + blurColor) * alpha;
}
]]
return shader