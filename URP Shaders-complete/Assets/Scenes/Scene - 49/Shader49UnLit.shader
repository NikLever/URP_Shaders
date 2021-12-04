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

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 screenPos: TEXCOORD2;
                float2 uv: TEXCOORD0;
                float4 noise: TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)

            float _Scale;
            sampler2D _MainTex;

            CBUFFER_END
            
            float random( float3 pt, float seed ){
                float3 scale = float3( 12.9898, 78.233, 151.7182 );
                return frac( sin( dot( pt + seed, scale ) ) * 43758.5453 + seed ) ;
            }

            inline float4 ScreenPosFromHCS(float4 pos) {
                float4 o = pos * 0.5f;
                o.xy = float2(o.x, o.y*_ProjectionParams.x) + o.w;
                o.zw = pos.zw;
                return o;
            }

            v2f vert (Attributes v)
            {
                v2f o;
                // add time to the noise parameters so it's animated
                o.noise = 0;
                // get a turbulent 3d noise using the normal, normal to high freq
                o.noise.x = 10.0 *  -0.10 * turbulence( 0.5 * v.normal + _Time.y );
                // get a 3d noise using the position, low frequency
                float3 size = 100;
                float b = _Scale * 0.5 * pnoise( 0.05 * v.positionOS + _Time.y, size );
                float displacement = b - _Scale * o.noise.x;

                // move the position along the normal and transform it
                float3 newPosition = v.positionOS + v.normal * displacement;
                o.pos = TransformObjectToHClip(newPosition);
                o.screenPos = ScreenPosFromHCS(o.pos);
                o.uv = v.texcoord;

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // get a random offset
                float3 fragCoord = float3(i.screenPos.xy * _ScreenParams, 0);
                float r = .01 * random( fragCoord, 0.0 );
                // lookup vertically in the texture, using noise and offset
                // to get the right RGB colour
                float2 uv = float2( 0, 1.3 * i.noise.x + r );
                half3 color = tex2D( _MainTex, uv ).rgb;

                return half4( color, 1 );
            }
            ENDHLSL
        }
    }
}

