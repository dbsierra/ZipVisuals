
// size is 0-1, maps square to size of canvas, aspect is aspect ratio of canvas
float Square(float2 uv, float size, float aspect)
{
    size *= aspect;

    // Create a horizontal bar and a vertical bar then multiply together
    float horzBar = 1.0f - floor(min(abs(uv.y) / size, .5f) + .5f);
    float vertBar = 1.0f - floor(min(abs(uv.x) / size, .5f) + .5f);

    return vertBar * horzBar;
}

float2x2 Rotate2d(float _angle) {
    return float2x2(cos(_angle), -sin(_angle),
        sin(_angle), cos(_angle));
}

// Size is 0-1 value, percentage of square size occupying UV space
float SquareStroke(float2 uv, float size, float aspect, float strokeWidth)
{
    float strokeSize = strokeWidth;

    // Ensure you never divide by 0
    size = max(size, .0001f);
    float size2 = max(size - strokeSize, .0001f);

    // Map UV's to absolute space
    uv = abs(uv);
    float2 uv2 = uv;

    // Contract UV's to fit size of SquareStroke
    uv /= size;

    // For the second square, contract UV's to maintain a consistent width regardless of the aspect ratio
    uv2.x /= max(size2 - .1f, .0001f);
    uv2.y /= max(size2 - .1f*aspect, .0001f);

    // Ensure UV's never surpass 1, then force to 0 or 1, then reverse
    uv = 1.0f - floor(saturate(uv));
    uv2 = 1.0f - floor(saturate(uv2));

    // Multiply vertical bar by horizontal bar for each square, then subtract to make a stroke
    return uv.y*uv.x - uv2.y*uv2.x;
}

float rand(float2 co) {
    return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

// Creates a vertical bar going along uvY at position "pos" and intensity "intenstiy"
// range controls the size of the bar
float verticalBar(float pos, float uvY, float intensity, float range) {
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, uvY) * intensity;
    x -= smoothstep(pos, edge1, uvY) * intensity;
    return x;
}

// Shifts and modifies UVs to have effect of VHS tape
float2 vhs(float2 uv, float noiseQuality, float noiseIntensity, float offsetIntensity, bool flip, float time)
{
    float tmp = uv.y;

    if (flip)
    {
        uv.y = uv.x;
        uv.x = tmp;
    }

    for (float i = 0.0; i < 0.71; i += 0.1313) {
        float d = fmod((time * i), 1.7);
        float o = sin(1.0 - tan(time * 0.24 * i));
        o *= offsetIntensity;
        uv.x += verticalBar(d, uv.y, o, 0.08f);
    }

    float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(float2(time * 0.00001, uvY));
    uv.x += noise * noiseIntensity;

    if (flip)
    {
        tmp = uv.y;
        uv.y = uv.x;
        uv.x = tmp;
    }

    return uv;
}


/*
_Phase ("Phase", float) = 0
_ColorLookup ("ColorLookup", float) = 0
_Mode ("Mode", float) = 0
_Mask ("Mask", float) = 0
_MaskFlip ("MaskFlip", float) = 0
_GlitchColor ("GlitchColor", float) = 1

sampler2D _Color1;
sampler2D _Color2;
sampler2D _Color3;

float _Rows;
float _Cols;
*/
float2 glitchBars(float2 uv, float _Rows, float _Cols, float _Phase, float _Mode, float _Mask, float _MaskFlip, float _GlitchColor)
{
    float b = 0.0f;

    float r = (uv.y*_Rows) / _Rows;
    float c = (uv.x*_Cols) / _Cols;

    float rowI = floor(uv.y*_Rows);
    float colI = floor(uv.x*_Cols);

    float phase = round(uv.x*_Cols) / _Cols;

    float modifier = 12.5*colI;

    // Horizontal lines
    if (_Mode < 2)
    {
        modifier = 6.5*colI;
        //phase = round(uv.y*_Rows)/_Rows;
        //modifier = r;
        //phase = r;
    }
    // Blocks
    else if (_Mode < 3)
    {
        modifier = 22.5*rowI;
        //phase = r;

    }
    else if (_Mode < 4)
    {
        modifier = 22.5*rowI;
        phase = round(uv.y*_Rows) / _Rows;
    }
    float wave = cos(phase*6.28*modifier + _Phase)*.5 + .5;

    // ----
    float mSeed = uv.x;
    if (_MaskFlip == 1)
        mSeed = 1. - uv.x;
    float mWave = (cos(rowI*16.28 + 4.*_Time)*.5 + .5) + 1.;
    float mask = min(floor(mSeed / (pow( max(_Mask,.0001f), mWave))), 1.0f);

    float cBar = fmod(colI, 2.0) * wave;
    float rBar = fmod(rowI, 2.0) * wave;
    float bars = rBar;

    if (_Mode < 2)
        bars = cBar;
    else if (_Mode < 3)
        bars = rBar * cBar;

    b = (1. - cBar*rBar) * wave;

    b *= lerp(0.0, min( rand(float2(colI, rowI)), 421.0), _GlitchColor);// * wave;

    bars *= mask;
    b *= mask;

    return float2(bars, b);
}