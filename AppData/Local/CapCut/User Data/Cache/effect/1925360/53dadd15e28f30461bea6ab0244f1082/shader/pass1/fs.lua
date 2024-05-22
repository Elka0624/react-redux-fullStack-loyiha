local shader = [[

precision highp float;
varying vec2 uv0;
uniform sampler2D _MainTex;

uniform float horizontal;
uniform float radius;
uniform float _time;
uniform highp vec4 texSize;

float N21(vec2 p,float seed){
	float x=fract(sin(p.x*128.+p.y*272.+ seed*100.)*2368.); 
   return x;
}
float disX(vec2 p,vec2 q){
    return abs(p.x-q.x);
}
void main()
{

	
	vec2 uv = uv0+vec2(0.0,0.0);
    vec2 scale = vec2(3.8,6)*vec2(floor(texSize.x/texSize.y),1.0);
    vec2 newUV=uv*scale;
    vec2 id=floor(newUV);
    vec2 offset=fract(newUV);
    vec2 maskUV=id/scale;
    // Time varying pixel color
    vec2 lastUV = maskUV;
    float tempScale=1.;    
        for(int j=-1;j<=1;j++){ 
            vec2 idOffset = vec2(j,0);
        	vec2 newid= id+idOffset;
            float newid_rand = N21(newid,0.0+_time);
            float maskScale=newid_rand*0.5+1.2;
            if(disX(offset,idOffset+0.5)*2.<maskScale&&tempScale<maskScale)
            {
                tempScale=maskScale;
                lastUV=newid/scale;

            }
        }
    // Output to screen
    float glitchFlag = N21(lastUV,5.0+_time);
	float glitchFlag2 = N21(lastUV,50.0+_time);
	gl_FragColor = vec4(glitchFlag,glitchFlag2,0.0,1.0) ;
}
]]
return shader