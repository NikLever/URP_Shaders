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
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
     
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

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 position: TEXCOORD1;
            };
            
            v2f vert (Attributes v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = v.texcoord;
                o.position = v.positionOS;
                return o;
            }

            CBUFFER_START(UnityPerMaterial)
            sampler2D _TextureA;
            sampler2D _TextureB;
            float _Duration;
            float _StartTime;
            CBUFFER_END  
             
            float4 frag (v2f i) : COLOR
            {
                float time = _Time.y - _StartTime;
                float2 p = -1.0 + 2.0 * i.uv;
                float len = length(p);
                float2 ripple = i.uv + (p/len)*cos(len*12.0-time*4.0)*0.03;
                float delta = time/_Duration;
                float2 uv = lerp(ripple, i.uv, delta);
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

