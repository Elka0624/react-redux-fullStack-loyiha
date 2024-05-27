precision mediump float;

// 变亮,ok
#define BlendLightenf(base, blend)      max(blend, base)
// 变暗,ok
#define BlendDarkenf(base, blend)       min(blend, base)
// 正片叠底,ok
#define BlendMulitiplyf(base, blend)    (base * blend)
// 滤色,x
#define BlendScreenf(base, blend)       (1.0 - ((1.0 - base) * (1.0 - blend)))
// 叠加,x
#define BlendOverlayf(base, blend)      (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend))) 
// 柔光,x
#define BlendSoftLightf(base, blend)    ((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
// 强光,x,base和blend交换
#define BlendHardlightf(base, blend)    (blend < 0.5 ? (2.0 * blend * base) : (1.0 - 2.0 * (1.0 - blend) * (1.0 - base))) 
// 颜色减淡,x
#define BlendColorDodgef(base, blend)   ((blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0))
// 颜色加深,x
#define BlendColorBurnf(base, blend)    ((blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0))
// 线性加深,ok
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

    color = mix(colorA.rgb, BlendDarkenf(colorA.rgb, clamp(colorB.rgb / colorB.a, 0.0, 1.0)), _alpha * colorB.a);

    
    gl_FragColor = vec4(color,1.0);
}
