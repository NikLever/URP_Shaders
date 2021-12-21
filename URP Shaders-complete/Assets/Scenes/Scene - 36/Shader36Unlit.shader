Shader "NiksShaders/Shader36Unlit"
{
    Properties
    {
        _PaleColor("Pale Color", Color) = (0.733, 0.565, 0.365, 1)
        _DarkColor("Dark Color", Color) = (0.49, 0.286, 0.043, 1)
        _Frequency("Frequency", Float) = 2.0
        _NoiseScale("Noise Scale", Float) = 6.0
        _RingScale("Ring Scale", Float) = 0.6
        _Contrast("Contrast", Float) = 4.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
     
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/hlsl/noiseSimplex.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float4 positionOS     : TEXCOORD1;
            
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionOS = IN.positionOS;
                return OUT;
            }

            CBUFFER_START(UnityPerMaterial)

            float4 _PaleColor;
            float4 _DarkColor;
            float _Frequency;
            float _NoiseScale;
            float _RingScale;
            float _Contrast;

            CBUFFER_END

            float4 frag (Varyings i) : COLOR
            {
                float3 pos = i.positionOS.xyz * 2.0;
                float n = snoise( pos );
                float ring = frac( _Frequency * pos.z + _NoiseScale * n );
                ring *= _Contrast * ( 1.0 - ring );

                // Adjust ring smoothness and shape, and add some noise
                float delta = pow( ring, _RingScale ) + n;
                float3 color = lerp(_DarkColor, _PaleColor, delta);

                return float4( color, 1.0 );
            }
            ENDHLSL
        }
    }
}

