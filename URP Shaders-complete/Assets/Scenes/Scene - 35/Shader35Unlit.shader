Shader "NiksShaders/Shader35Unlit"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline"}
        
        LOD 100

        Pass
        {
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos: TEXCOORD2;
                float4 position: TEXCOORD1;
                float2 uv: TEXCOORD0;
            };

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord: TEXCOORD0;
            };

            inline float4 ScreenPosFromHCS(float4 pos) {
                float4 o = pos * 0.5f;
                o.xy = float2(o.x, o.y*_ProjectionParams.x) + o.w;
                o.zw = pos.zw;
                return o;
            }

            v2f vert (Attributes v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.positionOS.xyz);
                o.screenPos = ScreenPosFromHCS(o.vertex);
                o.position = v.positionOS;
                o.uv = v.texcoord;
                return o;
            }

            sampler2D _MainTex;

            float4 frag (v2f i) : COLOR
            {
                float2 uv;
                float2 noise = float2(0,0);

                // Generate noisy y value
                uv = float2(i.uv.x*0.7 - 0.01, frac(i.uv.y - _Time.y*0.27));
                noise.y = (tex2D(_MainTex, uv).a-0.5)*2.0;
                uv = float2(i.uv.x*0.45 + 0.033, frac(i.uv.y*1.9 - _Time.y*0.61));
                noise.y += (tex2D(_MainTex, uv).a-0.5)*2.0;
                uv = float2(i.uv.x*0.8 - 0.02, frac(i.uv.y*2.5 - _Time.y*0.51));
                noise.y += (tex2D(_MainTex, uv).a-0.5)*2.0;

                noise = clamp(noise, -1.0, 1.0);

                float perturb = (1.0 - i.uv.y) * 0.35 + 0.02;
                noise = (noise * perturb) + i.uv - 0.02;

                float4 color = tex2D(_MainTex, noise);
                color = half4(color.r*2.0, color.g*0.9, (color.g/color.r)*0.2, 1.0);
                noise = clamp(noise, 0.05, 1.0);
                color.a = tex2D(_MainTex, noise).b*2.0;
                color.a = color.a*tex2D(_MainTex, i.uv).b;

                return color;
            }
            ENDHLSL
        }
    }
}

