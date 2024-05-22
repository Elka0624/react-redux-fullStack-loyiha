local shader =
    [[
precision highp float;
varying vec2 uv0;
uniform sampler2D pass3_inputTex_0;
uniform sampler2D noiseTex;
uniform float _time;
uniform highp vec4 texSize;
uniform float firstend;
uniform float glitchSize;
void main()
{
	vec2 uv = uv0;
	vec4 resultCol = texture2D(pass3_inputTex_0,uv);
    float colRatio=texSize.y/texSize.x;
    vec4 leftCol=resultCol;
    vec4 rightCol=resultCol;
    float timeType=1.0/firstend;
    leftCol = texture2D(pass3_inputTex_0,uv+vec2(0.1*colRatio*glitchSize,0.0));
    rightCol = texture2D(pass3_inputTex_0,uv+vec2(-0.1*colRatio*glitchSize,0.0));
    //resultCol.rgb = max(leftCol.rgb * vec3(120,2,247)/255.0,resultCol.rgb);
    //resultCol.rgb = max(rightCol.rgb * vec3(135,253,8)/255.0,resultCol.rgb);
    //resultCol.rgb = max(max(vec3(leftCol.a - resultCol.a) * vec3(255,0,255) / 255.0 , vec3(rightCol.a - resultCol.a) * vec3(0,255,0)/255.0),resultCol.rgb);
    resultCol.rgb = max(leftCol.rgb * vec3(255,0,255) / 255.0 + rightCol.rgb * vec3(0,255,0)/255.0,resultCol.rgb);
    resultCol.a = max(resultCol.a,leftCol.a);
    resultCol.a = max(resultCol.a,rightCol.a);
	gl_FragColor = resultCol;
}
]]
return shader
