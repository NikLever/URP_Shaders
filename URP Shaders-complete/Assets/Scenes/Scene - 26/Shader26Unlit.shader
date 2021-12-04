Shader "NiksShaders/Shader26Unlit"
{
    Properties
    {
        _BrickColor("Brick Color", Color) = (0.9, 0.3, 0.4, 1)
        _MortarColor("Mortar Color", Color) = (0.7, 0.7, 0.7, 1)
        _TileCount("Tile Count", Int) = 10
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

            CBUFFER_START(UnityPerMaterial)

            half4 _BrickColor;
            half4 _MortarColor;
            int _TileCount;

            CBUFFER_END

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
                OUT.positionOS = IN.positionOS;
                OUT.uv = IN.texcoord;
                return OUT;
            }

            float brick(float2 pt, float mortar_height, float edge_thickness){
                if (pt.y>0.5) pt.x = frac(pt.x + 0.5);
                float half_mortar_height = mortar_height/2.0;
                //Draw bottom line
                float result = 1 - smoothstep(half_mortar_height, half_mortar_height + edge_thickness, pt.y);
                //Draw top line
                result += smoothstep(1.0 - half_mortar_height - edge_thickness, 1.0 - half_mortar_height, pt.y);
                //Draw middle line
                result += smoothstep(0.5 - half_mortar_height - edge_thickness, 0.5 - half_mortar_height, pt.y) - smoothstep(0.5 + half_mortar_height, 0.5 + half_mortar_height + edge_thickness, pt.y);
                //Draw vertical lines
                result += smoothstep(-half_mortar_height - edge_thickness, -half_mortar_height, pt.x) - smoothstep(half_mortar_height, half_mortar_height + edge_thickness, pt.x) + smoothstep(1.0-half_mortar_height-edge_thickness, 1.0-half_mortar_height, pt.x);
                
                return saturate(result);
            }

            half4 frag (Varyings i) : SV_Target
            {
                float2 uv = frac(i.uv * _TileCount);
                half3 color = lerp(_BrickColor.rgb, _MortarColor.rgb, brick(uv, 0.05, 0.001));
                
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
