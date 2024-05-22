local shader =
    [[
precision highp float;
varying vec2 uv0;
uniform sampler2D pass2_inputTex_0;
uniform sampler2D noiseTex;
uniform sampler2D _MainTex;

uniform float _time;
uniform highp vec4 texSize;
uniform float firstend;
uniform int flag;

float N21(vec2 p,float seed){
	float x=fract(sin(p.x*128.+p.y*272.+ seed*100.)*2368.); 
   return x;
}
void main()
{
    vec2 uv1 = uv0;
    uv1.y = uv1.y * 0.25;
    uv1.x = uv1.x * 0.15;
	vec4 stripNoise = texture2D(noiseTex, uv1);	
	float threshold = 1.001 - _time * 1.001;

   float uvShift = step(threshold, pow(abs(stripNoise.x), 3.0));
   vec2 uv = (uv0 + stripNoise.yz * uvShift);

   
   vec4 source = texture2D(_MainTex, uv);

    gl_FragColor = source;
}
]]
return shader
