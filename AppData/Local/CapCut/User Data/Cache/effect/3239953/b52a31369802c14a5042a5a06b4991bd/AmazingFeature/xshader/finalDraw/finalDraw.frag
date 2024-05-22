precision highp float;
varying vec2 uv0;
uniform sampler2D src_Texture;
uniform sampler2D u_uvTexture;
#define uv_W 512.0



vec2 calibrate(vec2 val){
    const float EPSILON = 1.0/256.0/256.0;
    vec2 sign_ = sign(val);
    vec2 abs_ = max(abs(val) - EPSILON, 0.0);
    return sign_ * abs_;
}

vec2 vec4ToVec2(vec4 val){
    float a = val.x + val.y/255.0;
    float b = val.z + val.w/255.0;
    return vec2(a, b);
}
vec4 vec2ToVec4(vec2 val){
    float a = floor(val.x*255.0)/255.0;
    float b = fract(val.x*255.0);
    float c = floor(val.y*255.0)/255.0;
    float d = fract(val.y*255.0);
    return vec4(a, b, c, d);
}

vec4 interp(vec2 coord){
    vec2 w_ab = fract(coord * uv_W);
    vec2 coord_0 = coord-w_ab/uv_W ;
  
    vec4 p1 = texture2D(u_uvTexture, coord_0);
    // p1 = floor(p1*255.0+0.5)/255.0;
    vec4 p2 = texture2D(u_uvTexture, coord_0+vec2(0.0,1.0/uv_W));
    // p2 = floor(p2*255.0+0.5)/255.0;
    vec4 p3 = texture2D(u_uvTexture, coord_0+vec2(1.0/uv_W,0.0));
    // p3 = floor(p3*255.0+0.5)/255.0;
    vec4 p4 = texture2D(u_uvTexture, coord_0+vec2(1.0/uv_W,1.0/uv_W));
    // p4 = floor(p4*255.0+0.5)/255.0;
    vec4 res = p1*(1.0-w_ab.x)*(1.0-w_ab.y) + p2*(1.0-w_ab.x)*w_ab.y + p3*w_ab.x*(1.0-w_ab.y) + p4*w_ab.x*w_ab.y;
    
    return res;
}

void main(void)
{
    // // vec2 d = abs(vec4ToVec2(texture2D(u_uvTexture, origCoord)) + origCoord - 127.0/255.0 - origCoord) * 720.0*255.0;
//    lowp float mid = 0.5;
//    vec2 d = abs(calibrate(vec4ToVec2(interp(uv0-0.5/uv_W)) - mid)) * 256.0 * 128.0;
//    gl_FragColor = vec4(d.x, d.y, 0.0,1.0);
    // // gl_FragColor = vec4(d.y, d.y, d.y,1.0);

    // vec2 d = abs(vec4ToVec2(interp(origCoord-0.5/uv_W)) - origCoord) * 128.0*1.0;
    // // vec2 d = abs(vec4ToVec2(texture2D(u_uvTexture, origCoord)) - origCoord) * 256.0*1.0;
    // gl_FragColor = vec4(d.y, d.y, d.y,1.0);

    vec4 newCoord = interp(uv0-0.5/uv_W);
    vec4 textureColor = texture2D(src_Texture, (calibrate(vec4ToVec2(newCoord) - 0.5) + uv0));
    gl_FragColor = textureColor;
}
