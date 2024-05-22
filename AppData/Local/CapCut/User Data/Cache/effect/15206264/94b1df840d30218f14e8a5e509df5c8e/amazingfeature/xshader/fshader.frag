precision highp float;

varying vec2 uv;
varying vec2 uRenderSize;
uniform sampler2D inputImageTexture;
uniform float timer;

#define TWO_PI (3.141592653*2.0)


void main()
{
//    float time = clamp(timer,0.0,1.0);
	vec4 curColor = texture2D(inputImageTexture,uv);
	vec4 resultColor = curColor;
    vec4 whiteColor = vec4(1.0);
	float duration = 3.0;
	float firstStage = duration*0.6;
	float time = clamp(timer,0.0,duration);//mod(timer,duration);
	if(time<firstStage)
		resultColor = vec4(time/firstStage);
	else
		resultColor = mix(curColor,whiteColor,1.0-(time-firstStage)/(duration-firstStage));

	gl_FragColor = vec4(resultColor.rgb,1.0);
}
