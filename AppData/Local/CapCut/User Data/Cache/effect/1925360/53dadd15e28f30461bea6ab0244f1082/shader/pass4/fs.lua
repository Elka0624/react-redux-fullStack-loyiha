local shader =
    [[
precision highp float;
precision highp int;
varying vec2 uv0;
uniform sampler2D pass4_inputTex_0;
uniform sampler2D _MainTex;

uniform highp vec4 texSize;
uniform vec4 u_ScreenParams;
uniform float _time;

float hash21(vec2 p)
{
        float h = dot(p,vec2(127.1,311.7));
        
    return -1.0 + 2.0 * fract(sin(h)*43758.5453123);
}

float value_noise(vec2 p)
{
    vec2 pi = floor(p);
    vec2 pf = p - pi;//xiangdangyufract

    vec2 w = pf * pf * (3.0 - 2.0 * pf);//qudaismoothstepshoudongshengchengpinghuanquxian

    return mix(mix(hash21(pi + vec2(0.0, 0.0)), hash21(pi + vec2(1.0, 0.0)), w.x),
               mix(hash21(pi + vec2(0.0, 1.0)), hash21(pi + vec2(1.0, 1.0)), w.x),
               w.y);
}

uniform int flag;

void main()
{
	vec4 lightResult = vec4(0.0);
    vec2 offset = vec2(1.)/u_ScreenParams.xy;

    vec2 uv1 = floor(uv0 * 500.0) / 500.0;
    uv1.x -= 0.10 * pow(abs(uv1.y * 2.0 - 1.0),2.0);
    uv1.x *= (2.2 - 0.8 * abs(value_noise(vec2(uv0))));
    float blurSize=4.0;

    if(flag == 0)
    {
        blurSize=0.0;
        uv1 = uv0;
    }

    if(flag == 2)
    {
        blurSize=2.0;
        uv1 = uv0;
        uv1.x -= 0.1;
        uv1.x += 0.2 * pow(1.1 - uv1.y,2.0);
    }

    if(flag >= 3)
    {
        blurSize=1.0;
        uv1 = uv0;
        //uv1.x -= 0.015 * pow(abs(uv1.y * 2.0 - 1.0),2.0);
        //uv1.x += 0.0016 * value_noise(vec2(float(flag) + 1.0,(1.0 - uv0.y) * 64.0));
        uv1.x += 0.012 * value_noise(vec2(float(flag) + 10.0,(1.0 - uv0.y) * 4.0));
    }
    
	vec4 resultCol = texture2D(pass4_inputTex_0,uv1);

    float num=1.0;
    for(float i=1.0;i<2.;i++){
         resultCol=resultCol+
         texture2D(pass4_inputTex_0,uv1+vec2(i*blurSize,0.0)*offset)
         +texture2D(pass4_inputTex_0,uv1+vec2(-i*blurSize,0.0)*offset);
         num+=2.0;
    }
    resultCol=resultCol/num;
    if(flag==1)
    {
        resultCol += texture2D(pass4_inputTex_0,vec2(uv1.x - 1.4,uv1.y)) * step(0.0,uv1.x - 1.4) * step(uv1.x - 1.4,1.0) * step(uv1.y,0.35);
    }
	gl_FragColor = vec4(resultCol);
}
]]
return shader
