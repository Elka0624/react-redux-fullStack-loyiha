precision highp float;
varying vec2 uv0;

vec4 vec2ToVec4(vec2 val){
    float a = floor(val.x*255.0)/255.0;
    float b = fract(val.x*255.0);
    float c = floor(val.y*255.0)/255.0;
    float d = fract(val.y*255.0);
    return vec4(a, b, c, d);
}

void main(void)
{
    // gl_FragColor = vec2ToVec4(uv0);
    gl_FragColor = vec2ToVec4(vec2(0.5, 0.5));
}
