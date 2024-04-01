precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 uv;
uniform float light;
uniform float lightIns;
uniform float darkIns;
uniform float darkAdjust;
void main()
{
    vec4 col = texture2D(inputImageTexture, uv);
    //col.rgb=vec3(dot(col.rgb,vec3(0.299 ,0.587,0.114)));
    float flag;
    float mylight=light;
    if(mylight>0.){
        mylight*=lightIns;
        flag=1.0+mylight;
    }
    else{
        mylight*=darkIns;
        flag= 1.0/(1.0-mylight);
        col.rgb-=abs(light)*0.005*darkAdjust;
    }
        
    gl_FragColor = vec4(clamp(1.0-pow(1.-col.rgb,vec3(flag)),0.0,1.0),col.a);
    // gl_FragColor = vec4(1.);
}
