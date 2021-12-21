Shader "NiksShaders/Shader40Unlit"
{
    Properties
    {
        _TextureA("Texture A", 2D) = "white" {}
        _TextureB("Texture B", 2D) = "white" {}
        _Duration("Duration", Float) = 6.0
        _StartTime("StartTime", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}
     
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord   : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float4 positionOS   : TEXCOORD1;
            };
            
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.texcoord;
                OUT.positionOS = IN.positionOS;
                return OUT;
            }

            CBUFFER_START(UnityPerMaterial)

            sampler2D _TextureA;
            sampler2D _TextureB;
            float _Duration;
            float _StartTime;

            CBUFFER_END
            

            half4 frag (Varyings IN) : COLOR
            {
                float time = _Time.y - _StartTime;
                float2 p = -1.0 + 2.0 * IN.uv;
                float len = length(p);
                float2 ripple = IN.uv + (p/len)*cos(len*12.0-time*4.0)*0.03;
                float delta = time/_Duration;
                float2 uv = lerp(ripple, IN.uv, delta);
                half3 col1 = tex2D(_TextureA, uv).rgb;
                half3 col2 = tex2D(_TextureB, uv).rgb;
                float fade = smoothstep(delta*1.4, delta*2.5, len);
                half3 color = lerp(col2, col1, fade);
                
                return half4( color, 1.0 );
            }
            ENDHLSL
        }
    }
}

