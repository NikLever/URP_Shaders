Shader "NiksShaders/Shader50bLit" {

    Properties {
        [NoScaleOffset] _BaseMap ("Texture", 2D) = "white" {}
        _Ambient ("Ambient", Range(0.0, 1.0)) = 0.3
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
            float _Ambient;

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
                half3 ambient = (half3)_Ambient;
                half3 color = texel * saturate(lightingColor + ambient);
	            return half4(color, 1.0);
            }           

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }

}
