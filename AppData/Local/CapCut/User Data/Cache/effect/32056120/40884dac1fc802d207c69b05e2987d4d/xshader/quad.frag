precision lowp float;
varying highp vec2 uv0;
uniform sampler2D _MainTex;
uniform sampler2D edgeTex;
uniform vec2 textSize;
varying vec4 pos;
uniform float progress;

uniform float s0;

uniform float s1;
uniform float s2;
uniform float s3;
uniform float s4;
uniform float s5;
uniform float s6;
uniform float s7;
uniform float s8;
uniform float s9;
uniform float s10;
uniform float s11;
uniform float s12;
uniform float s13;

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

vec2 Scale(vec2 _u, float _s){
    return (_u-0.5)/_s+0.5;
}

void main()
{
    vec2 uv1 = uv0;
    uv1 -= 0.5;
    uv1 /= s0;
    uv1 += 0.5;
    vec4 res = vec4(0);
    res = texture2D(_MainTex, Scale(uv0, s0));
    res = texture2D(edgeTex, Scale(uv0, s1 )) * (1.-res.a) * 1.00 * a1  + res;
    res = texture2D(edgeTex, Scale(uv0, s2 )) * (1.-res.a) * 1.00 * a2  + res;
    res = texture2D(edgeTex, Scale(uv0, s3 )) * (1.-res.a) * 1.00 * a3  + res;
    res = texture2D(edgeTex, Scale(uv0, s4 )) * (1.-res.a) * 0.95 * a4  + res;
    res = texture2D(edgeTex, Scale(uv0, s5 )) * (1.-res.a) * 0.90 * a5  + res;
    res = texture2D(edgeTex, Scale(uv0, s6 )) * (1.-res.a) * 0.85 * a6  + res;
    res = texture2D(edgeTex, Scale(uv0, s7 )) * (1.-res.a) * 0.80 * a7  + res;
    res = texture2D(edgeTex, Scale(uv0, s8 )) * (1.-res.a) * 0.75 * a8  + res;
    res = texture2D(edgeTex, Scale(uv0, s9 )) * (1.-res.a) * 0.70 * a9  + res;
    res = texture2D(edgeTex, Scale(uv0, s10)) * (1.-res.a) * 0.65 * a10 + res;
    res = texture2D(edgeTex, Scale(uv0, s11)) * (1.-res.a) * 0.60 * a11 + res;
    res = texture2D(edgeTex, Scale(uv0, s12)) * (1.-res.a) * 0.55 * a12 + res;
    res = texture2D(edgeTex, Scale(uv0, s13)) * (1.-res.a) * 0.50 * a13 + res;

    // res = texture2D(edgeTex, Scale(uv0, s1 )) * (1.-res.a) * 0.40 * a1  + res;
    // res = texture2D(edgeTex, Scale(uv0, s2 )) * (1.-res.a) * 0.45 * a2  + res;
    // res = texture2D(edgeTex, Scale(uv0, s3 )) * (1.-res.a) * 0.50 * a3  + res;
    // res = texture2D(edgeTex, Scale(uv0, s4 )) * (1.-res.a) * 0.55 * a4  + res;
    // res = texture2D(edgeTex, Scale(uv0, s5 )) * (1.-res.a) * 0.60 * a5  + res;
    // res = texture2D(edgeTex, Scale(uv0, s6 )) * (1.-res.a) * 0.65 * a6  + res;
    // res = texture2D(edgeTex, Scale(uv0, s7 )) * (1.-res.a) * 0.70 * a7  + res;
    // res = texture2D(edgeTex, Scale(uv0, s8 )) * (1.-res.a) * 0.75 * a8  + res;
    // res = texture2D(edgeTex, Scale(uv0, s9 )) * (1.-res.a) * 0.80 * a9  + res;
    // res = texture2D(edgeTex, Scale(uv0, s10)) * (1.-res.a) * 0.85 * a10 + res;
    // res = texture2D(edgeTex, Scale(uv0, s11)) * (1.-res.a) * 0.90 * a11 + res;
    // res = texture2D(edgeTex, Scale(uv0, s12)) * (1.-res.a) * 0.95 * a12 + res;
    // res = texture2D(edgeTex, Scale(uv0, s13)) * (1.-res.a) * 1.00 * a13 + res;

    // res = mix(res, texture2D(edgeTex, Scale(uv0, s1)), (1.-res.a) * 1.00 * a1);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s2)), (1.-res.a) * 1.00 * a2);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s3)), (1.-res.a) * 1.00 * a3);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s4)), (1.-res.a) * 0.95 * a4);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s5)), (1.-res.a) * 0.90 * a5);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s6)), (1.-res.a) * 0.85 * a6);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s7)), (1.-res.a) * 0.80 * a7);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s8)), (1.-res.a) * 0.75 * a8);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s9)), (1.-res.a) * 0.70 * a9);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s10)), (1.-res.a) * 0.75 * a10);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s11)), (1.-res.a) * 0.70 * a11);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s12)), (1.-res.a) * 0.65 * a12);
    // res = mix(res, texture2D(edgeTex, Scale(uv0, s13)), (1.-res.a) * 0.60 * a13);
    // res = texture2D(edgeTex, Scale(uv0, s2 )) * (1.-res.a) * 1.00 * a2  + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s3 )) * (1.-res.a) * 1.00 * a3  + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s4 )) * (1.-res.a) * 0.95 * a4  + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s5 )) * (1.-res.a) * 0.90 * a5  + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s6 )) * (1.-res.a) * 0.85 * a6  + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s7 )) * (1.-res.a) * 0.80 * a7  + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s8 )) * (1.-res.a) * 0.75 * a8  + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s9 )) * (1.-res.a) * 0.70 * a9  + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s10)) * (1.-res.a) * 0.65 * a10 + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s11)) * (1.-res.a) * 0.60 * a11 + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s12)) * (1.-res.a) * 0.55 * a12 + res * res.a;
    // res = texture2D(edgeTex, Scale(uv0, s13)) * (1.-res.a) * 0.50 * a13 + res * res.a;

    gl_FragColor = res;
}
