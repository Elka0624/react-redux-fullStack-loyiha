precision lowp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform sampler2D edgeTex;
uniform vec2 textSize;
varying vec4 pos;
uniform float progress;

uniform float s0;
uniform float scale;
uniform vec2 s1;
uniform vec2 s2;
uniform vec2 s3;
uniform vec2 s4;
uniform vec2 s5;
uniform vec2 s6;
uniform vec2 s7;
uniform vec2 s8;
uniform vec2 s9;
uniform vec2 s10;
uniform vec2 s11;
uniform vec2 s12;
uniform vec2 s13;

uniform float a0;
uniform float a1;
uniform float a2;
uniform float a3;
uniform float a4;
uniform float a5;
uniform float a6;
uniform float a7;
uniform float a8;
uniform float a9;
uniform float a10;
uniform float a11;
uniform float a12;
uniform float a13;


void main()
{
    vec2 uv1 = uv0;
    uv1 -= 0.5;
    // uv1 /= scale;
    uv1 += 0.5;
    vec4 res = vec4(0);
    // res = texture2D(u_InputTex, vec2(uv1))*a0;
    vec4 org = res;


    vec4 res1 = texture2D(edgeTex, vec2(uv1+s1 )) * a1  ;
    res = res1;
    res1 = texture2D(edgeTex, vec2(uv1+s2 )) *  a2*(1.0-smoothstep(0.92,0.98,a2));
    res = res + res1*(1.0-res.a);
    res1 = texture2D(edgeTex, vec2(uv1+s3 )) *  a3*(1.0-smoothstep(0.92,0.98,a3));
    res = res + res1*(1.0-res.a);
    res1 = texture2D(edgeTex, vec2(uv1+s4 )) *  a4*(1.0-smoothstep(0.92,0.98,a4));
    res = res + res1*(1.0-res.a);
    res1 = texture2D(edgeTex, vec2(uv1+s5 )) *  a5*(1.0-smoothstep(0.92,0.98,a5));
    res = res + res1*(1.0-res.a);
    // res1 = texture2D(edgeTex, vec2(uv1+s6 )) *  a6*(1.0-smoothstep(0.92,0.98,a6));
    // res = res + res1*(1.0-res.a);


    gl_FragColor = res;
}
