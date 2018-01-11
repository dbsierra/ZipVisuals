Shader "Unlit/VideoWallTexW"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "../Shaders/VJRoutines.cginc" 

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Col1;
            float3 _Col2;
            float3 _Col3;

            float _Square;
            float _Aspect;
            float _Rotate;
            float _Rows;
            float _Cols;
            float _Mask;
            float _MaskFlip;
            float _Mode;
            float _Spectrum[256];
            float _SpectrumMag;
            float _Static;
            float _GlitchColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // Spectrum
             //   int index = (int)round((round(uv.y * 50.) / 50.) * 255);
            //    float v = pow(_Spectrum[index], .55) * 30;

                // When static is on, mask is always 0
                float mask = lerp(_Mask, 0, _Static);

                float2 fx = glitchBars(uv, _Rows, _Cols, _Time.y, _Mode, mask, _MaskFlip, _GlitchColor);
                float3 col = float3(0, 0, 0);
                col.rgb = lerp(_Col1.rgb, _Col2.rgb, fx.x);
                col.rgb = lerp(col.rgb, _Col3.rgb, fx.y);

                //  col.rgb = lerp(col.rgb, col.rgb * v, _SpectrumMag);

           //     col.rgb += lerp(v*col.rgb*_SpectrumMag*3., float3(v,v,v)*_SpectrumMag, .5);

               // col.rgb = clamp(col.rgb, 0, 2.5f);

               // Map uvs so center is 0, sides are - .5 and .5
                uv.x -= .5f;
                uv.y -= .5f;

               // 0 - 1 slider rotates from 0 to 90 degrees
                float2 rotateUv = mul(float2(uv.x*_Aspect, uv.y), Rotate2d((1.0f - _Rotate)*1.57f));

                // Stretch for aspect ratio to make perfect square
                float squareMask = 1.0f - Square(rotateUv, _Square, _Aspect);

              //  squareMask *= Square(uv, _Square, _Aspect);

                col.rgb = lerp(col.rgb*.05f, col.rgb, squareMask);

             //   return fixed4(1, 0, 0, 1);
                return fixed4(col.r, col.g, col.b, 1.0);
            }
            ENDCG
        }
    }
}
