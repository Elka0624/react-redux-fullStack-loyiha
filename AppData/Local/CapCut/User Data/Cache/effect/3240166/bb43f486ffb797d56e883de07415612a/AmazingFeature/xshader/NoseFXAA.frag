precision highp float;

uniform sampler2D u_video;
uniform sampler2D u_mask;
uniform vec4 u_ScreenParams;

varying vec2 v_src_uv;
varying vec2 v_material_uv;

void main() {
    float FXAA_SPAN_MAX = 8.0;
    float FXAA_REDUCE_MUL = 1.0/8.0;
    float FXAA_REDUCE_MIN = 1.0/128.0;
    vec2 pixels = vec2(1.0, 1.0) / u_ScreenParams.xy;

    vec3 rgbNW = texture2D(u_video, v_src_uv + (vec2(-1.0, -1.0) * pixels)).xyz;
    vec3 rgbNE = texture2D(u_video, v_src_uv + (vec2(1.0, -1.0) * pixels)).xyz;
    vec3 rgbSW = texture2D(u_video, v_src_uv + (vec2(-1.0, 1.0) * pixels)).xyz;
    vec3 rgbSE = texture2D(u_video, v_src_uv + (vec2(1.0, 1.0) * pixels)).xyz;
    vec3 rgbM = texture2D(u_video, v_src_uv).xyz;

    vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    vec2 dir = vec2(-((lumaNW + lumaNE) - (lumaSW + lumaSE)), ((lumaNW + lumaSW) - (lumaNE + lumaSE)) );
    float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
          max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)) / u_ScreenParams.xy;

    vec3 rgbA = 0.5 * (
        texture2D(u_video, v_src_uv + dir * (1.0/3.0 - 0.5)).xyz +
        texture2D(u_video, v_src_uv + dir * (2.0/3.0 - 0.5)).xyz);
    vec3 rgbB = 0.5 * rgbA + 0.25 * (
        texture2D(u_video, v_src_uv + dir * - 0.5).xyz +
        texture2D(u_video, v_src_uv + dir * 0.5).xyz);
    float lumaB = dot(rgbB, luma);

    vec3 resColor;
    if ((lumaB < lumaMin) || (lumaMax < lumaB)){
        resColor = rgbA;
    }
    else {
        resColor = rgbB;
    }
    vec3 srcColor = texture2D(u_video, v_src_uv).rgb;
    float alpha = texture2D(u_mask, v_material_uv).r;
    gl_FragColor = vec4(mix(srcColor, resColor, alpha), 1.0);
    // gl_FragColor = vec4(srcColor, 1.0);
    // gl_FragColor = vec4(mix(gl_FragColor.rgb, vec3(alpha), 0.4), 1.0);
    // gl_FragColor = texture2D(u_mask, v_material_uv);
}
