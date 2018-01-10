Shader "Custom/Ground" {
    Properties {
       [HDR] _WireColor ("Wire Color", Color) = (1,1,1)
        _InsideColor("Inside Color", Color) = (1,1,1)
        _Stroke("Stroke Size", range(0,1)) = .01
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        half _Stroke;
        float4 _WireColor;
        float4 _InsideColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        // size is 0-1, maps square to size of canvas, aspect is aspect ratio of canvas
        float Square(float2 uv, float size, float aspect)
        {
            size *= aspect;

            // Create a horizontal bar and a vertical bar then multiply together
            float horzBar = 1.0f - floor(min(abs(uv.y) / size, .5f) + .5f);
            float vertBar = 1.0f - floor(min(abs(uv.x) / size, .5f) + .5f);

            return vertBar * horzBar;
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {

            float2 uv = IN.uv_MainTex;

            uv *= 10;


            uv = frac(uv);


            uv.x -= .5;
            uv.y -= .5;


            float s = Square(uv, 1.0f-_Stroke, 1.0f);

            o.Albedo = float4(0,0,0,1);

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1.0f;

            float3 c = tex2D(_MainTex, IN.uv_MainTex).rgb;

            o.Emission = lerp(_InsideColor, _WireColor, 1.0f-s);
            o.Emission = c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
