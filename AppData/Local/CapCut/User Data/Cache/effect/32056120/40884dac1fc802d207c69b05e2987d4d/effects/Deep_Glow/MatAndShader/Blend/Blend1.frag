precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform sampler2D u_GlowBlurTex;
uniform sampler2D u_GlowBlurTex1;
uniform sampler2D u_ColorBlurTex;
uniform float u_GlowIntensity;
uniform vec3 u_TextColor;
uniform vec4 u_ScreenParams;

uniform float final_alpha;
uniform float show_white;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z +  (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main()
{
    vec4 oriColor = texture2D(u_InputTex, uv0);
    // oriColor.rgb *= vec3(1,0,0);
    vec4 blurColor = texture2D(u_GlowBlurTex, uv0);
    vec4 blurColor1 = texture2D(u_GlowBlurTex1, uv0);
    float blurGray1 = blurColor.x ;
    float blurGray2 = blurColor.y ;
    float blurGray3 = blurColor.z ;
    float blurGray4 = blurColor.w ;
    float blurGray5 = blurColor1.x;
    float blurGray6 = blurColor1.y;
    float blurGray7 = blurColor1.z;
    float blurGray8 = blurColor1.w;

    vec3 text_col = u_TextColor;
    if(text_col.r>0.9&&text_col.g>0.9&&text_col.b>0.9) text_col *= vec3(133.,238.,247.)/255.*1.;
    if(show_white > 0.5) text_col = vec3(1);

    vec4 intensity = pow(u_GlowIntensity * 0.5, 1./2.4) * vec4(text_col, 1.0) * 1.1;
    vec4 dis1 = clamp(blurGray1 * intensity, 0.0, 1.0);
    vec4 dis2 = clamp(blurGray2 * intensity, 0.0, 1.0);
    vec4 dis3 = clamp(blurGray3 * intensity, 0.0, 1.0);
    vec4 dis4 = clamp(blurGray4 * intensity, 0.0, 1.0);
    vec4 dis5 = clamp(blurGray5 * intensity, 0.0, 1.0);
    vec4 dis6 = clamp(blurGray6 * intensity, 0.0, 1.0);
    vec4 dis7 = clamp(blurGray7 * intensity, 0.0, 1.0);
    vec4 dis8 = clamp(blurGray8 * intensity, 0.0, 1.0);
    dis1 = 1. - (1. - dis1) * (1. - dis2);
    dis1 = 1. - (1. - dis1) * (1. - dis3);
    dis1 = 1. - (1. - dis1) * (1. - dis4);
    dis1 = 1. - (1. - dis1) * (1. - dis5);
    dis1 = 1. - (1. - dis1) * (1. - dis6);
    dis1 = 1. - (1. - dis1) * (1. - dis7);
    dis1 = 1. - (1. - dis1) * (1. - dis8);

    vec4 glowColor = clamp(vec4(dis1) * max(intensity, 1.0) , 0.0, 1.0);
    // oriColor.rgb *= text_col;
    // oriColor = (1. - (1. - glowColor) * (1. - oriColor));
    oriColor += glowColor;
    oriColor = clamp(oriColor, 0., 1.);
    oriColor.rgb *= text_col;
    // vec4 blurColor_shadow = texture2D(u_GlowBlurTex, uv0 + vec2(-8.0, 8.0) / u_ScreenParams.xy);
    oriColor.rgba *= final_alpha;
    gl_FragColor = oriColor;
    // gl_FragColor = glowColor;
}
