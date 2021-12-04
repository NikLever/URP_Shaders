Shader "NiksShaders/Shader23Unlit"
{
    Properties
    {
        _Sides("Sides", Int) = 3
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

            #define PI2 6.28318530718

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord   : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float4 screenPos: TEXCOORD2;
                float4 position: TEXCOORD1;
                float2 uv: TEXCOORD0;
            };

            inline float4 ScreenPosFromHCS(float4 pos) {
                float4 o = pos * 0.5f;
                o.xy = float2(o.x, o.y*_ProjectionParams.x) + o.w;
                o.zw = pos.zw;
                return o;
            }

            Varyings vert (Attributes IN)
            {
                Varyings o;
                o.vertex = TransformObjectToHClip(IN.positionOS.xyz);
                o.screenPos = ScreenPosFromHCS(o.vertex);
                o.position = IN.positionOS;
                o.uv = IN.texcoord;
                return o;
            }

            CBUFFER_START(UnityPerMaterial)
            int _Sides;
            CBUFFER_END

            float getDelta(float x){
                return (sin(x)+1.0)/2.0;
            }

            float circle(float2 pt, float2 center, float radius, float line_width, float edge_thickness){
                pt -= center;
                float len = length(pt);
                //Change true to false to soften the edge
                float result = smoothstep(radius-line_width/2.0-edge_thickness, radius-line_width/2.0, len) - smoothstep(radius + line_width/2.0, radius + line_width/2.0 + edge_thickness, len);

                return result;
            }

            float onLine(float x, float y, float line_width, float edge_width){
                return smoothstep(x-line_width/2.0-edge_width, x-line_width/2.0, y) - smoothstep(x+line_width/2.0, x+line_width/2.0+edge_width, y);
            }

            float polygon(float2 pt, float2 center, float radius, int sides, float rotate, float edge_thickness){
                pt -= center;

                // Angle and radius from the current pixel
                float theta = atan2(pt.y, pt.x) + rotate;
                float rad = PI2/float(sides);

                // Shaping function that modulate the distance
                float d = cos(floor(0.5 + theta/rad)*rad-theta)*length(pt);

                return 1.0 - smoothstep(radius, radius + edge_thickness, d);
            }
            
            half4 frag (Varyings i) : SV_Target
            {
                float2 pt = i.screenPos.xy * _ScreenParams.xy;
                float2 center = _ScreenParams.xy * 0.5;
                float radius = 80.0;
                half3 color = polygon(pt, center, radius, _Sides, 0.0, 1.0) * half3(1.0, 1.0, 0.0);
                color += circle(pt, center, radius, 1.0, 1.0) * half3(1.0, 1.0, 1.0); 
                
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
