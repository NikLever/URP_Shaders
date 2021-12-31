Shader "NiksShaders/Shader50aLit" {

    Properties {
        [NoScaleOffset] _BaseMap ("Texture", 2D) = "white" {}
    }

    Subshader {

        Tags {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }

        Pass{
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            CBUFFER_START(UnityPerMaterial)

            sampler2D _BaseMap;

            CBUFFER_END

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 texcoord         : TEXCOORD0;
                float3 normal           : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS      : SV_POSITION;
                float2 uv               : TEXCOORD0;
                float3 normal           : NORMAL;
            };
     
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.texcoord;
                OUT.normal = IN.normal;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {
                Light light = GetMainLight();
                half3 lightingColor = LightingLambert(light.color, light.direction, IN.normal);
                half3 texel = tex2D(_BaseMap, IN.uv).rgb;
                half ambient = 0.4;
                half3 color = texel * saturate(lightingColor + ambient);
	            return half4(color, 1.0);
            }           

            ENDHLSL
        }
    }

}
