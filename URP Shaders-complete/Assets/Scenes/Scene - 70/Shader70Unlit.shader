Shader "NiksShaders/Shader70Unlit"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _TintColor("Tint Color", Color) = (1,1,1,1)
        _TintStrength("Tint Strength", Range(0,1)) = 0.5
        _Brightness("Brightness", Range(0,3)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)

            float4 _TintColor;
            float _TintStrength;
            float _Brightness;
            sampler2D _MainTex;

            CBUFFER_END
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.texcoord;
                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                // sample the texture
                half4 texel = tex2D(_MainTex, input.uv);
                half gray = (texel.r + texel.g + texel.b)/3.0;
                half4 tinted = _TintColor * gray * _Brightness;
                half4 col = lerp(texel, tinted, _TintStrength);
                return col;
            }
            ENDHLSL
        }
    }
}
