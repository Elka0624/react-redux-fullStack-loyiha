precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
uniform sampler2D u_albedo1;
uniform float sigma;
void main()
{
    float meanI = texture2D(u_albedo, uv0).r;
    float meanIP = texture2D(u_albedo1, uv0).r;
    float varI = meanIP - meanI*meanI;
    float a =  varI / max(0.0001,sigma+varI);
    float b =  meanI - a * meanI;
    gl_FragColor = vec4(a,b,a,b);
    // gl_FragColor.rgb = vec3(color.r);
    // gl_FragColor.a = 1.;
    // gl_FragColor = vec4(1.);
}
