Shader "NiksShaders/Shader57Lit" {

    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _LevelCount("Level Count", Float ) = 3
    }

    Subshader {

        Tags {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }

        Pass{
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            CBUFFER_START(UnityPerMaterial)

            float _LevelCount;
            half4 _Color;
            sampler2D _MainTex;

            CBUFFER_END
        
            half4 LightingRamp (float3 normal) {
                Light light = GetMainLight();
                half NdotL = dot (normal, light.direction);
                half diff = pow(NdotL * 0.5 + 0.5, 2.0);
                half3 ramp = floor(diff * _LevelCount)/_LevelCount;
                half4 c;
                c.rgb = _Color * light.color.rgb * ramp;
                c.a = 1.0;
                return c;
            }

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal     : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normal : NORMAL;
            };
     
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal = IN.normal;
                return OUT;
            }

            

            half4 frag(Varyings IN) : SV_Target {
	            return LightingRamp(IN.normal);
            }           

            ENDHLSL
        }
    }

}
