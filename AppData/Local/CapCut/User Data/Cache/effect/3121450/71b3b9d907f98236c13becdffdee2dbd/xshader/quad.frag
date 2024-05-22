precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
uniform vec4 u_ScreenParams;
uniform vec2 u_K;
uniform float u_Progress;
varying vec2 offset;

float N31 (vec3 p, vec3 seed) {
    p = fract(p * seed);
    p += dot(p, p+(seed.x + seed.y + seed.x) * 0.02);
    return fract(p.x * p.y * p.z);
}
float N21(vec2 p){
    float x=fract(sin(p.x*100.+p.y*168.+floor(0.0))*2368.);
    return x;
}
vec2 Noise(vec2 uv, float th, float c)
{
    vec2 id = floor(uv);
    vec2 f = fract(uv);
    vec2 resUV = id;
    float MaxScale = 0.0;
    vec3 mm = vec3(0.0);
    float x = 1.0;
    for (int i = -1; i < 2; ++i)
    {
        // for (int j = -1; j < 2; ++j)
        // {
            vec2 idOffset = vec2(i, i);
            vec2 curID = id + idOffset;
            float curID_randy = N31(vec3(curID.yy, c), vec3(233.12, 829.23, 482.21));
            // curID_randy = smoothstep(0.0, 1.0, curID_randy);
            float maskScaley = (curID_randy * 0.5) + 1.0;
            float y = abs(f.y - idOffset.y - 0.5) * 2.0;
            if ((y < maskScaley) && MaxScale < maskScaley)
            {
                MaxScale = maskScaley;
                resUV.y = curID.y;

            }

        // }
    }
    
    float N = (N21(resUV.yy + c * 100.0 + 100.0));
    float uvx = uv.x + N;
    MaxScale = 0.0; 

    id.x = floor(uvx);
    id.y = resUV.y;
    f.x =  fract(uvx);
    resUV.x = id.x;
    for (int i = -1; i < 2; ++i)
    {
        vec2 idOffset = vec2(i, 0);
        vec2 curID = id + idOffset;
        float curID_randx = N31(vec3(curID, c + 2.0), vec3(198.12, 769.23, 642.21));
        float maskScalex = (curID_randx * 0.5) + 1.0;
        float x = abs(f.x - idOffset.x - 0.5) * 2.0;
        if ((x < maskScalex) && MaxScale < maskScalex)
        {
            MaxScale = maskScalex;
            resUV.x = curID.x;

        }

    }
    N = (N21(resUV.xy + 1.0 * 100.0 + 100.0));
    float n = N31(vec3(resUV, c + 1.0), vec3(881.12, 389.23, 780.21));
    float rat = clamp((max(u_ScreenParams.x / u_ScreenParams.y, 1.0) - 1.0) * 0.05 + 1.0, 0.8, 1.2);
    return vec2(step(th * rat, n) , N);
}
vec3 N33(vec3 p)
{
    p = fract(p * vec3(234.51, 254.64, 214.57));
    p += dot(p, p.yzx + 28.21);
    return fract(vec3(p.zyx * (p.xzy + p.yxz))) * 2.0 - 1.0;
}


/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;
/* 3d simplex noise */
float simplex3d(vec3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
	 
	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));
	 
	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;
	 
	 /* 2. find four surflets and store them in d */
	 vec4 w, d;
	 
	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);
	 
	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);
	 
	 /* calculate surflet components */
	 d.x = dot(N33(s), x);
	 d.y = dot(N33(s + i1), x1);
	 d.z = dot(N33(s + i2), x2);
	 d.w = dot(N33(s + 1.0), x3);
	 
	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;
	 
	 /* 3. return the sum of the four surflets */
	 return dot(d, vec4(52.0));
}
float pnoise(vec3 co, float freq, int steps, float persistence)
{
  float value = 0.0;
  float ampl = 1.0;
  float sum = 0.0;
  for(int i=0 ; i<8 ; i++)
  {
    if(i>=steps)break;
    sum += ampl;
    value += simplex3d(co * freq) * ampl;
    freq *= 2.0;
    ampl *= persistence;
  }
  return value / sum;
}
float noise41(vec2 uv0)
{
    float n = pnoise(vec3(uv0, 0.0), 20.0, 6, 0.7) * 0.5 + 0.5;
    n = (n - 0.5) * 4.0 + 0.5;
    return clamp(n, 0.0, 1.0);
}


vec2 noiseBlock(vec2 uv0, float offset, out vec2 n1, out vec2 n2)
{
    vec2 uv = uv0;
    uv -= 0.5;
    uv *= u_ScreenParams.xy / max(u_ScreenParams.x, u_ScreenParams.y);
    uv += 0.5;
    n1 = Noise((uv - vec2(offset * 0.25, 0.0)) * vec2(4.0, 12.0), 0.6, (offset * 1.0) + 2.0);
    n1.y = n1.y * 0.3 + 0.5;
    n2 = Noise((1. - (uv - vec2(offset * 0.25, 0.0))) * vec2(4.0, 12.0) + vec2(12.4, 514.3), 0.6, (offset * 1.0) + 2.0);
    n2.y = n2.y * 0.3 + 0.5;
    float nk1 = (noise41(uv + vec2(n1.y, 0.0) / 6.0 * (1. - offset))) * n1.x;
    float nk2 = (noise41(uv + vec2(n2.y, 0.0) / 6.0 * (1. - offset))) * n2.x;
    return 1. - vec2(nk1, nk2);
}
float remap01(float a, float b, float x)
{
    return (b - a) * x + a;
}

void main()
{
    vec2 uv = uv0;
    uv.y = 1. - uv.y;
    vec2 blockN1 = vec2(0.0);
    vec2 blockN2 = vec2(0.0);
    float remapProgress = smoothstep(0.2, 0.58, u_Progress);
    vec2 blockNoise = noiseBlock(uv - offset * 0.5 * vec2(u_ScreenParams.y / u_ScreenParams.x, 1.0), remapProgress, blockN1, blockN2);
    vec4 color1 = texture2D(u_albedo, uv + vec2(blockN1.y, 0.0) / 6.0 * (1. - remapProgress)) * blockN1.x;
    vec4 color2 = texture2D(u_albedo, uv + vec2(blockN2.y, 0.0) / 6.0 * (1. - remapProgress)) * blockN2.x;
    vec4 color = texture2D(u_albedo, uv);
    color1 = color2 * blockNoise.y + color1 * blockNoise.x * (1. - color2.a * blockNoise.y);
    // color1 = vec4(1. - blockNoise) * color1;
    gl_FragColor = color + color1 * (1. - color.a);
    // gl_FragColor = vec4(blockNoise.y);
    // gl_FragColor = color;
}
