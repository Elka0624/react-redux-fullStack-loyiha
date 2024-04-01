precision mediump float;

// bianliang,ok
#define BlendLightenf(base, blend)      max(blend, base)
// bianan,ok
#define BlendDarkenf(base, blend)       min(blend, base)
// zhengpiandiedi,ok
#define BlendMulitiplyf(base, blend)    (base * blend)
// lvse,x
#define BlendScreenf(base, blend)       (1.0 - ((1.0 - base) * (1.0 - blend)))
// diejia,x
#define BlendOverlayf(base, blend)      (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend))) 
// rouguang,x
#define BlendSoftLightf(base, blend)    ((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
// qiangguang,x,baseheblendjiaohuan
#define BlendHardlightf(base, blend)    (blend < 0.5 ? (2.0 * blend * base) : (1.0 - 2.0 * (1.0 - blend) * (1.0 - base))) 
// yansejiandan,x
#define BlendColorDodgef(base, blend)   ((blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0))
// yansejiashen,x
#define BlendColorBurnf(base, blend)    ((blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0))
// xianxingjiashen,ok
#define BlendLinearburnf(base, blend)   max(base + blend - vec3(1.0), vec3(0.0))

uniform sampler2D _MainTex;
uniform sampler2D baseTex;
uniform float _alpha;

varying vec2 uv0;
varying vec2 uv1;

void main (void) {
    vec3 color = vec3(0.0);

    vec4 colorA = texture2D(baseTex, uv1);
    vec4 colorB = texture2D(_MainTex, uv0);
    if (colorB.a > 0.0)
        colorB = vec4(clamp(colorB.rgb / colorB.a, 0.0, 1.0), colorB.a);

    color = mix(colorA.rgb, vec3(BlendScreenf(colorA.r, colorB.r), BlendScreenf(colorA.g, colorB.g), BlendScreenf(colorA.b, colorB.b)), _alpha * colorB.a);

    
    gl_FragColor = vec4(color,1.0);
}
