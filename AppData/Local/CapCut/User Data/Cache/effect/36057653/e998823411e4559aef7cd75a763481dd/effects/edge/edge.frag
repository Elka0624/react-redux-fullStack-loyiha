precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform sampler2D _MainTex;
uniform vec4 u_ScreenParams;
uniform float u_TextFontSize;
uniform vec4 u_TextColor;
vec4 find_edge(vec2 uv, sampler2D i_InputTex)
{
        
	// vec2 uv = uv0;
    
    // vec2 ratio = vec2(360.0) * u_ScreenParams.xy / min(u_ScreenParams.x, u_ScreenParams.y);
    // ratio = u_ScreenParams.xy / u_TextFontSize;
    vec2 ratio = u_ScreenParams.xy;
    vec4 TL = texture2D(i_InputTex, uv + vec2(-1, 1)/ ratio.xy);
    vec4 TM = texture2D(i_InputTex, uv + vec2(0, 1)/ ratio.xy);
    vec4 TR = texture2D(i_InputTex, uv + vec2(1, 1)/ ratio.xy);
    
    vec4 ML = texture2D(i_InputTex, uv + vec2(-1, 0)/ ratio.xy);
    vec4 MR = texture2D(i_InputTex, uv + vec2(1, 0)/ ratio.xy);
    
    vec4 BL = texture2D(i_InputTex, uv + vec2(-1, -1)/ ratio.xy);
    vec4 BM = texture2D(i_InputTex, uv + vec2(0, -1)/ ratio.xy);
    vec4 BR = texture2D(i_InputTex, uv + vec2(1, -1)/ ratio.xy);
   
    vec4 MN22 = texture2D(i_InputTex, uv + vec2(-2, 2)/ ratio.xy);
    vec4 MN12 = texture2D(i_InputTex, uv + vec2(-1, 2)/ ratio.xy);
    vec4 M02 = texture2D(i_InputTex, uv + vec2(0, 2)/ ratio.xy);
    vec4 M12 = texture2D(i_InputTex, uv + vec2(1, 2)/ ratio.xy);
    vec4 M22 = texture2D(i_InputTex, uv + vec2(2, 2)/ ratio.xy);

    vec4 MN2N2 = texture2D(i_InputTex, uv + vec2(-2, -2)/ ratio.xy);
    vec4 MN1N2 = texture2D(i_InputTex, uv + vec2(-1, -2)/ ratio.xy);
    vec4 M0N2 = texture2D(i_InputTex, uv + vec2(0, -2)/ ratio.xy);
    vec4 M1N2 = texture2D(i_InputTex, uv + vec2(1, -2)/ ratio.xy);
    vec4 M2N2 = texture2D(i_InputTex, uv + vec2(2, -2)/ ratio.xy);

    vec4 MN21 = texture2D(i_InputTex, uv + vec2(-2, 1)/ ratio.xy);
    vec4 M21 = texture2D(i_InputTex, uv + vec2(2, 1)/ ratio.xy);

    vec4 MN20 = texture2D(i_InputTex, uv + vec2(-2, 0)/ ratio.xy);
    vec4 M20 = texture2D(i_InputTex, uv + vec2(2, 0)/ ratio.xy);

    vec4 MN2N1 = texture2D(i_InputTex, uv + vec2(-2, -1)/ ratio.xy);
    vec4 M2N1 = texture2D(i_InputTex, uv + vec2(2, -1)/ ratio.xy);
                       
    vec4 GradX = -TL + TR - 2.0 * ML + 2.0 * MR - BL + BR - MN22 + M22 - 2.0 * MN21 + 2.0 * M21
                - 4.0 * MN20 + 4.0 * M20 - 2.0 * MN2N1 + 2.0 * M2N1 - MN2N2 + M2N2;
    vec4 GradY = TL + 2.0 * TM + TR - BL - 2.0 * BM - BR + MN22 + 2.0 * MN12 + 4.0 * M02 + 2.0 * M12
                + M22 - MN2N2 - 2.0 * MN1N2 - 4.0 * M0N2 - 2.0 * M1N2 - M2N2;
   	
   	
    vec4 res = vec4(0.0);

    res.a = length(vec2(GradX.a, GradY.a));
    res = clamp(res,0.0, 1.0);
    // res.a = (res.a * texture2D(i_InputTex, uv).a);
    float org_a = texture2D(i_InputTex, uv).a;

    res.a = (res.a -org_a );
    // res.a = smoothstep(0.0,0.05,org_a)*(1.0-smoothstep(0.95,1.0,org_a));
    return res;
}

void main()
{
    vec4 res = find_edge(uv0, u_InputTex);
    vec2 uv1 = uv0 + vec2(1.0 / u_ScreenParams.x, 0.0);
    res += find_edge(uv1, u_InputTex);
    // uv1 = uv0 - vec2(1.0 / u_ScreenParams.x, 0.0);
    // res += find_edge(uv1, u_InputTex);
    uv1 = uv0 + vec2(0.0, 1.0 / u_ScreenParams.y);
    res += find_edge(uv1, u_InputTex);
    uv1 = uv0 + vec2(1.0 / u_ScreenParams.x, 1.0 / u_ScreenParams.y);
    res += find_edge(uv1, u_InputTex);
    res *= 0.25;
    res.a = smoothstep(0.2, 0.8, res.a);
    // res.a = pow( res.a,2.0);
    res.rgb = u_TextColor.rgb;
    res.rgb *= res.a;
    gl_FragColor = res;
    // gl_FragColor = texture2D(u_InputTex, uv0);
}
