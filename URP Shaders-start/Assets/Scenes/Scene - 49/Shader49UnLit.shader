Shader "NiksShaders/Shader49Unlit"
{
    Properties
    {
        _Scale("Scale", Range(0.1, 3)) = 0.3
        _MainTex("Main Texture", 2D) = "white" {}
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
                float3 normal     : NORMAL;
                float2 texcoord   : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float4 screenPos    : TEXCOORD2;
                float2 uv           : TEXCOORD0;
                float4 noise        : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)

            float _Scale;
            sampler2D _MainTex;

            CBUFFER_END
            
            float random( float3 pt, float seed ){
                float3 scale = float3( 12.9898, 78.233, 151.7182 );
                return frac( sin( dot( pt + seed, scale ) ) * 43758.5453 + seed ) ;
            }

            Varyings vert (Attributes IN)
            {
                Varyings OUT = (Varyings)0;
                // add time to the noise parameters so it's animated
                OUT.noise = 0;
                // get a turbulent 3d noise using the normal, normal to high freq
                OUT.noise.x = 10.0 *  -0.10 * turbulence( 0.5 * IN.normal + _Time.y );
                // get a 3d noise using the position, low frequency
                float3 size = 100;
                float b = _Scale * 0.5 * pnoise( 0.05 * IN.positionOS.xyz + _Time.y, size );
                float displacement = b - _Scale * OUT.noise.x;

                // move the position along the normal and transform it
                float3 newPosition = IN.positionOS.xyz + IN.normal * displacement;
                OUT.positionHCS = TransformObjectToHClip(newPosition);
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                OUT.uv = IN.texcoord;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // get a random offset
                float3 fragCoord = float3(IN.screenPos.xy * _ScreenParams.xy, 0);
                float r = .01 * random( fragCoord, 0.0 );
                // lookup vertically in the texture, using noise and offset
                // to get the right RGB colour
                float2 uv = float2( 0, 1.3 * IN.noise.x + r );
                half3 color = tex2D( _MainTex, uv ).rgb;

                return half4( color, 1 );
            }
            ENDHLSL
        }
    }
}

