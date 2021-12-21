Shader "NiksShaders/Shader22Unlit"
{
    Properties
    {
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


            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 texcoord     : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float4 positionOS   : TEXCOORD1;
                float2 uv           : TEXCOORD0;
            };
            
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionOS = IN.positionOS;
                OUT.uv = IN.texcoord;
                return OUT;
            }
            
            float getDelta(float x){
                return (sin(x)+1.0)/2.0;
            }

            float sweep(float2 pt, float2 center, float radius, float line_width, float edge_thickness){
                float2 d = pt - center;
                float theta = _Time.z;
                float2 p = float2(cos(theta), -sin(theta))*radius;
                float h = clamp( dot(d,p)/dot(p,p), 0.0, 1.0 );
                //float h = dot(d,p)/dot(p,p);
                float l = length(d - p*h);

                float gradient = 0.0;
                const float gradient_angle = PI * 0.2;

                if (length(d)<radius){
                    float angle = fmod(theta + atan2(d.y, d.x), TWO_PI);//PI2);
                    gradient = clamp(gradient_angle - angle, 0.0, gradient_angle)/gradient_angle * 0.5;
                }

                return gradient + 1.0 - smoothstep(line_width, line_width+edge_thickness, l);
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
                float rad = TWO_PI/float(sides);

                // Shaping function that modulate the distance
                float d = cos(floor(0.5 + theta/rad)*rad-theta)*length(pt);

                return 1.0 - smoothstep(radius, radius + edge_thickness, d);
            }
            
            half4 frag (Varyings i) : SV_Target
            {
                half3 axis_color = half3(0.8, 0.8, 0.8);
                half3 white = half3(1.0, 1.0, 1.0);
                half3 color = onLine(i.uv.y, 0.5, 0.002, 0.001) * axis_color;//xAxis
                color += onLine(i.uv.x, 0.5, 0.002, 0.001) * axis_color;//yAxis
                float2 center = float2(0.5, 0.5);
                color += circle(i.uv, center, 0.3, 0.002, 0.001) * axis_color;
                color += circle(i.uv, center, 0.2, 0.002, 0.001) * axis_color;
                color += circle(i.uv, center, 0.1, 0.002, 0.001) * axis_color;
                color += sweep(i.uv, center, 0.3, 0.003, 0.001) * half3(0.1, 0.3, 1.0);
                color += polygon(i.uv, float2(0.9 - sin(_Time.w)*0.05, 0.5), 0.005, 3, 0.0, 0.001) * white;
                color += polygon(i.uv, float2(0.1 - sin(_Time.w+PI)*0.05, 0.5), 0.005, 3, PI, 0.001) * white; 
                
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
