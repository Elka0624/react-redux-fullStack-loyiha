attribute vec3 position;
attribute vec2 texcoord0;
attribute vec2 texcoord1;
#define inputTextureCoordinate texcoord0
varying vec2 uv0;
#define textureCoordinate uv0
varying vec2 sucaiTexCoord;
varying vec2 origCoord;

uniform mat4 u_MVP;
uniform float _surfaceWidth;
uniform float _surfaceHeight;
#define MAX_STEP 40
#define MIN_FLOAT 0.001

uniform vec2 uDeformationStartPoint[MAX_STEP];
uniform vec2 uDeformationEndPoint[MAX_STEP];
uniform float uDeformationActionType[MAX_STEP];
uniform float uDeformationIntensity[MAX_STEP];
uniform float uDeformationRadius[MAX_STEP];
uniform float uDeformationRealStep;
//#define uDeformationRealStep 40

uniform float uIntensity; //default [0.0~1.0]
vec2 stretchFun(vec2 textureCoord, vec2 originPosition, vec2 targetPosition, float radius, float intensity)
{
    vec2 offset = vec2(0.0);
    vec2 result = vec2(0.0);
    vec2 direction = targetPosition - originPosition;
    float lengthA = length(direction);
    //if(lengthA<0.0001)   return (textureCoord-direction);
    float infect = distance(textureCoord, originPosition)/radius;
    infect = 1.0-infect;
    infect = clamp(infect,0.0,1.0);
    offset = direction * infect * intensity;
    result = textureCoord - offset;
    return result;
    
}

vec2 enlargeFun(vec2 curCoord,vec2 circleCenter,float radius,float intensity)
{
    float currentDistance = distance(curCoord,circleCenter);
    //if (currentDistance<=radius)
    {
        float weight = currentDistance/radius;
        weight = 1.0-intensity*(1.0-weight*weight);
        weight = clamp(weight,0.0,1.0);
        curCoord = circleCenter+(curCoord-circleCenter)*weight;
    }
    return curCoord;
}

vec2 narrowFun(vec2 curCoord,vec2 circleCenter,float radius,float intensity)
{
    float currentDistance = distance(curCoord,circleCenter);
    //if (currentDistance<=radius)
    {
        float weight = currentDistance/radius;
        weight = 1.0-intensity*(1.0-weight*weight);
        weight = clamp(weight,0.0001,1.0);
        curCoord = circleCenter+(curCoord-circleCenter)/weight;
        
    }
    return curCoord;
}

void main()
{
    if(uIntensity <= 0.0)
    {
        gl_Position = vec4(1.0, 1.0, 1.0, 1.0);
        return;
    }
    gl_Position = vec4(position.x, position.y, 0.0, 1.0);
    vec2 x_y = vec2(_surfaceWidth,_surfaceHeight);
    vec2 curCoord = inputTextureCoordinate*x_y;
    vec2 srcPoint               = vec2(0.0);
    vec2 dstPoint               = vec2(0.0);
    int n = int(uDeformationRealStep);
    for(int i=0;i<100;i++)
    {
        if(i>=n) break;
        srcPoint        = uDeformationStartPoint[i];
        dstPoint        = uDeformationEndPoint[i];
        if(abs(uDeformationActionType[i] - 0.0) < MIN_FLOAT)       //stretch
        {
            curCoord        = stretchFun(curCoord,srcPoint,dstPoint, uDeformationRadius[i],uDeformationIntensity[i]);
        }
        else if(abs(uDeformationActionType[i] - 1.0) < MIN_FLOAT)     //enlarge
        {
            curCoord = enlargeFun(curCoord, dstPoint, uDeformationRadius[i],uDeformationIntensity[i]);
        }
        else if(abs(uDeformationActionType[i] - 2.0) < MIN_FLOAT)    //narrow
        {
            curCoord = narrowFun(curCoord, dstPoint, uDeformationRadius[i],uDeformationIntensity[i]);
        }
    }

    float final_intensity = abs(uIntensity);

    textureCoordinate = inputTextureCoordinate+(curCoord/x_y-inputTextureCoordinate)*final_intensity*0.38;    

    sucaiTexCoord = texcoord1;
    origCoord = inputTextureCoordinate;
}
