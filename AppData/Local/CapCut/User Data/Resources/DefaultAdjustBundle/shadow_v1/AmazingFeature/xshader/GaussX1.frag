precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTex;
uniform float u_blurSize;
uniform vec4 u_ScreenParams;
uniform vec2 u_dir;
#ifdef blur_Num
#else
#define blur_Num 8
#endif
uniform float sigma;

float Gaussian (float x)
{
    return exp(-(x*x) / (2.0 * sigma*sigma));
}

float uv_Protect(vec2 uv) {
    return step(uv.x,1.)*step(uv.y,1.)*step(0.,uv.x)*step(0.,uv.y);
}
vec4 gauss_blur(sampler2D inputTexture, vec2 uv, float blurSize)
{

    vec4 result         = vec4(0.0);
    vec2 unit_uv        = vec2(blurSize)/u_ScreenParams.xy;
    // vec2 unit_uv        = vec2(0., 0.);
    vec4 centerPixel    = vec4(texture2D(inputTexture, uv));
    float sum_weight    = 1.;

    vec2 curPositiveCoordinate = uv;
    vec2 curNegativeCoordinate = uv;

    for(int i=1; i<=blur_Num; i++)
    {
        curPositiveCoordinate    += u_dir * unit_uv;
        curNegativeCoordinate    -= u_dir * unit_uv;
        vec4 fX1 = texture2D(inputTexture, curPositiveCoordinate) * uv_Protect(curPositiveCoordinate);
        vec4 fX2 = texture2D(inputTexture, curNegativeCoordinate) * uv_Protect(curNegativeCoordinate);
        centerPixel += fX1 * fX1;
        centerPixel += fX2 * fX2;
        sum_weight += uv_Protect(curPositiveCoordinate) + uv_Protect(curNegativeCoordinate);
    }
    result = centerPixel / sum_weight;
    return result;
}




void main(void)
{
    gl_FragColor = gauss_blur(inputTex, uv0, u_blurSize);
}