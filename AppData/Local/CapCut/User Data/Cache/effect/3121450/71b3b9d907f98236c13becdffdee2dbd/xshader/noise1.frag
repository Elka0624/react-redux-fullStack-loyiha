precision highp float;
varying highp vec2 uv0;
uniform sampler2D _MainTex;
uniform float u_Offset;
uniform float range;
uniform float u_Border;
uniform float u_Noise;
uniform vec4 u_ScreenParams;
uniform vec2 u_TextRect;
uniform vec2 u_K;
uniform float u_Progress;
uniform float u_Progress1;


float remap(float a, float b, float x, float y, float m)
{
    float n = (m - x) / (y - x);
    return clamp(n * (b - a) + a, min(a, b), max(a, b));
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



float pnoise6(vec3 co, float freq, int steps, float persistence)
{
  float value = 0.0;
  float ampl = 1.0;
  float sum = 0.0;
  for(int i=0 ; i<6 ; i++)
  {
    sum += ampl;
    value += simplex3d(co * freq) * ampl;
    freq *= 2.0;
    ampl *= persistence;
  }
  return value / sum;
}

float pnoise4(vec3 co, float freq, int steps, float persistence)
{
  float value = 0.0;
  float ampl = 1.0;
  float sum = 0.0;
  for(int i=0 ; i<4 ; i++)
  {
    sum += ampl;
    value += simplex3d(co * freq) * ampl;
    freq *= 2.0;
    ampl *= persistence;
  }
  return value / sum;
}

float pnoise8(vec3 co, float freq, int steps, float persistence)
{
  float value = 0.0;
  float ampl = 1.0;
  float sum = 0.0;
  for(int i=0 ; i<8 ; i++)
  {
    sum += ampl;
    value += simplex3d(co * freq) * ampl;
    freq *= 2.0;
    ampl *= persistence;
  }
  return value / sum;
}

float noise1(vec2 uv0)
{
    float n = pnoise4(vec3(uv0, 0.0), 16.0, 4, 0.7) * 0.5 + 0.5;
    n = clamp((1. - n - 0.5) * 1.6 + 0.5, 0.0, 1.0);
    return clamp(n, 0.0, 1.0);
}


float noise2(vec2 uv0)
{
    float n = pnoise4(vec3(uv0, 0.0), 32.0, 4, 0.7) * 0.5 + 0.5;
    n = clamp((n - 0.5) * 0.75 + 0.5, 0.0, 1.0);
    return clamp(n ,0.0, 1.0);
}

float noise3(vec2 uv0)
{
    float n = pnoise8(vec3(uv0, 0.0) - vec3(u_Progress1, 0.0, (u_Progress1 * 10.0)), 16.0, 8, 0.7) * 0.5 + 0.5;
    n = (n - 0.5) * 400.0 + 0.5;
    float str = remap(0.0, 0.6, 0.95, 1.0, u_Progress1);
    return clamp(n - range * (1. + pow(str, 2.0) * 1.5), 0.0, 1.0);
}


float noise31(vec2 uv0)
{
    float n = pnoise8(vec3(uv0, 0.0) - vec3(u_Progress1, 0.0, (u_Progress1 * 10.0)), 6.0, 8, 0.7) * 0.5 + 0.5;
    n = (n - 0.5) * 400.0 + 0.5;
    float str = remap(0.0, 0.6, 0.95, 1.0, u_Progress1);
    return clamp(n - range * 0.8 * (1. + pow(str, 2.0) * 2.125), 0.0, 1.0);
}

float noise4(vec2 uv0)
{
    float n = pnoise6(vec3(uv0, 0.0), 48.0, 6, 0.7) * 0.5 + 0.5;
    n = (n - 0.5) * 3.0 + 0.5;
    return clamp(n, 0.0, 1.0);
}

float noise41(vec2 uv0)
{
    float n = pnoise6(vec3(uv0, 0.0), 20.0, 6, 0.7) * 0.5 + 0.5;
    n = (n - 0.5) * 4.0 + 0.5;
    return clamp(n, 0.0, 1.0);
}
float noise42(vec2 uv0)
{
    float n = pnoise6(vec3(uv0, 0.0), 48.0, 6, 0.7) * 0.5 + 0.5;
    n = (n - 0.5) * 2.0 + 0.5;
    return clamp(n, 0.0, 1.0);
}
float noise5(vec2 uv0)
{
    float n4 = noise4(uv0);
    float n3 = noise3(uv0);
    return clamp(n3 * n4, 0.0, 1.0);
}

float noise51(vec2 uv0)
{
    float n4 = noise42(uv0);
    float n3 = noise31(uv0);
    return clamp(n3 * n4, 0.0, 1.0);
}
float remap(float a, float b, float x)
{
    return (x - a) / (b - a); 
}

vec2 rotate(vec2 uv, float angle)
{
    uv -= 0.5;
    uv *= u_TextRect.xy / max(u_TextRect.x, u_TextRect.y);
    float theta = radians(angle);
    mat2 rotMat = mat2(
        cos(theta), -sin(theta),
        sin(theta), cos(theta)
    );
    uv = rotMat * uv;
    uv *= max(u_TextRect.x, u_TextRect.y) / u_TextRect.xy;
    return uv + 0.5;
}

float noiseMask(vec2 uv0, float offset, float offset2)
{
    uv0 += vec2(0.0, offset);
    vec2 uv = rotate(uv0, 18.0);
    vec2 uv1 = uv;
    uv1 -= 0.5;
    uv1 *= u_TextRect.xy / max(u_TextRect.x, u_TextRect.y);
    uv1 += 0.5;
    float n = pnoise6(vec3(uv1 * vec2(2.0, 1.5) + vec2(0.0, offset2), 0.0), 5.0, 6, 0.5);
    float flag = step(0.0, uv.y);
    uv.y = remap(0.5 - u_Border, 0.5 + u_Border, uv.y);
    // uv.y = (uv.y - 0.5) * 32.0 + 0.5;
    n = n * u_Noise + uv.y;
    n = (n - 0.5) * 16.0 + 0.5;
    return clamp(n * flag, 0.0, 1.0);
}


float remap01(float a, float b, float x)
{
    return (b - a) * x + a;
}

float noise2Curve(float x)
{
    float z = x - 1.;
    float w = 1. - x * x;
    z = abs(z * z); 
    w = pow(w, 11.0);
    float m = clamp((x - 0.1) * 4.0 + 0.5, 0.0, 1.0);
    m = 3.0 * m * m - 2.0 * m * m * m;
    return z * m + w * (1. - m);
}
void main()
{
    vec2 uv = uv0;
    uv -= 0.5;
    uv *= u_TextRect.xy / max(u_TextRect.x, u_TextRect.y) * vec2(1.0, 1.3);
    uv += 0.5;
    float cp = clamp(u_Progress, 0.0, 1.0);
    float cp1 = clamp(u_Progress1, 0.0, 1.0);
    float textXOffset = min(remap01(0., 3.2, min(pow(cp, 0.3)*1.0, 1.0)) - 3.0, 0.0) * u_TextRect.y / u_TextRect.x;
    float noise1Offset = remap01(0.0, 1.25, cp);
    float maskOffset = remap01(-0.1 * u_TextRect.x / u_TextRect.y - 0.6, 0.1 * u_TextRect.x / u_TextRect.y + 1.2, pow(cp, 1.2));
    float maskOffset1 = remap01(0.0, 1.0, cp);
    vec2 uv1 = uv0;
    uv1 -= 1.0;
    uv1 += 1.0;
    float mask = noiseMask(uv1, maskOffset, maskOffset1);
    float n1 = noise1(uv - vec2(noise1Offset, 0.0));
    float n2 = noise2(uv - vec2(noise1Offset, 0.0));
    float n4 = noise4(uv);
    float n5 = noise5(uv - vec2(textXOffset, 0.0));
    float n51 = noise51(uv - vec2(textXOffset, 0.0));
    float p = pow(noise2Curve(cp1), 0.15);
    float x = remap01(0.003, -0.2, p) * 0.75 * u_TextRect.y / u_TextRect.x;
    float y = remap01(0.003, 0.05, p) * 0.75;
    float x1 = remap01(0.001, -0.05, p) * 0.7 * u_TextRect.y / u_TextRect.x;
    float str = remap(0.0, 1.0, 0.0, 0.5, 1. - cp1); 
    float s = pow(str, 1.2);
    vec4 textColor = texture2D(_MainTex, uv0 - vec2(textXOffset, 0.0));
    vec2 uvk = uv0 - vec2(textXOffset, 0.0) - vec2(x, y) * (n2 * 2.0 - 1.0) * (1. - textColor.a) * mask * s;
    vec4 textColor1 = texture2D(_MainTex, uvk);
    mask = noiseMask(uv1 - vec2(x, y) * (n2 * 2.0 - 1.0) * (1. - mask) * s, maskOffset, maskOffset1);
    // gl_FragColor = n1 * textColor * mask;
    // gl_FragColor = n2 * (1. - textColor * mask);
    // gl_FragColor.a = (1. - textColor.a * mask);
    textColor1 = vec4(textColor1) * (1. - n4 * pow(remap(0.8, 1.0, 0.0, 0.2, 1. - cp1), 1.2)) * mask;

    // vec4 color1 = n1;
    vec4 textColor2 = texture2D(_MainTex, uv0 - vec2(textXOffset, 0.0) - vec2(x * s, y * 0.0) * (n1 * 2.0 - 1.0) * textColor.a) * mask;
    vec4 resColor = (textColor1 * textColor.a + textColor2 * (1. - textColor1.a) * (1. - n51) * (1. - n5)) * step(0.0, uv0.y) * step(uv0.y, 1.0) * step(0.02, u_Progress);
    // gl_FragColor = textColor1;
    vec4 oriColor = texture2D(_MainTex, uv0);
    gl_FragColor = mix(resColor, oriColor, smoothstep(0.99, 1.0, u_Progress));
}

// void main()
// {

//     vec2 ScreenRatio = u_TextRect.xy;
//     vec2 uv = uv0;
//     uv -= 0.5;
//     uv *= ScreenRatio.xy / max(ScreenRatio.x, ScreenRatio.y);
//     uv += 0.5;
//     vec4 c1 = texture2D(_MainTex, uv0  - vec2(0.5 / ScreenRatio.x, 0.0));
//     vec4 c2 = texture2D(_MainTex, uv0  + vec2(0.5 / ScreenRatio.x, 0.0));
//     vec4 c3 = texture2D(_MainTex, uv0  - vec2(0.0, 0.5 / ScreenRatio.y));
//     vec4 c4 = texture2D(_MainTex, uv0  + vec2(0.0, 0.5 / ScreenRatio.y));
//     vec4 c = texture2D(_MainTex, uv0);

//     float n21 = noise2(uv - vec2(0.5 / ScreenRatio.x, 0.0)) * (1. - c1.a);
//     float n22 = noise2(uv + vec2(0.5 / ScreenRatio.x, 0.0)) * (1. - c2.a);
//     float n23 = noise2(uv - vec2(0.0, 0.5 / ScreenRatio.y)) * (1. - c3.a);
//     float n24 = noise2(uv + vec2(0.0, 0.5 / ScreenRatio.y)) * (1. - c4.a);
//     float n2 = (noise2(uv) * 2.0 - 1.0) * (1. - c.a);
//     vec2 n = (vec2((n22 - n21), (n24 - n23))) * 4.0;
//     float noi = noise2(uv - u_K * n2);
//     vec4 textColor1 = texture2D(_MainTex, uv0 + step(0.2, abs(noi)) * sign(noi) * 0.008);
//     float p = noise2Curve(u_Progress);
//     float x = remap01(0.001, -0.06667, p);
//     float y = remap01(0.001, 0.031667, p);
//     vec4 textColor2 = texture2D(_MainTex, uv0 - vec2(x, y) * n2);
//     gl_FragColor = vec4(textColor2);
// }