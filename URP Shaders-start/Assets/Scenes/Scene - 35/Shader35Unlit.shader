Shader "NiksShaders/Shader35Unlit"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "RenderPipeLine"="UniversalPipeline"}

        LOD 100

        Pass
        {
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 positionOS: TEXCOORD1;
                float2 uv: TEXCOORD0;
            };

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord: TEXCOORD0;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT =(Varyings)0;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionOS = IN.positionOS;
                OUT.uv = IN.texcoord;
                return OUT;
            }

            sampler2D _MainTex;

            float4 frag (Varyings IN) : COLOR
            {
                float2 uv;
                float2 noise = float2(0,0);

                // Generate noisy y value
                uv = float2(IN.uv.x*0.7 - 0.01, frac(IN.uv.y - _Time.y*0.27));
                noise.y = (tex2D(_MainTex, uv).a-0.5)*2.0;
                uv = float2(IN.uv.x*0.45 + 0.033, frac(IN.uv.y*1.9 - _Time.y*0.61));
                noise.y += (tex2D(_MainTex, uv).a-0.5)*2.0;
                uv = float2(IN.uv.x*0.8 - 0.02, frac(IN.uv.y*2.5 - _Time.y*0.51));
                noise.y += (tex2D(_MainTex, uv).a-0.5)*2.0;

                noise = clamp(noise, -1.0, 1.0);

                float perturb = (1.0 - IN.uv.y) * 0.35 + 0.02;
                noise = (noise * perturb) + IN.uv - 0.02;

                float4 color = tex2D(_MainTex, noise);
                color = half4(color.r*2.0, color.g*0.9, (color.g/color.r)*0.2, 1.0);
                noise = clamp(noise, 0.05, 1.0);
                color.a = tex2D(_MainTex, noise).b*2.0;
                color.a = color.a*tex2D(_MainTex, IN.uv).b;

                return color;
            }
            ENDHLSL
        }
    }
}

