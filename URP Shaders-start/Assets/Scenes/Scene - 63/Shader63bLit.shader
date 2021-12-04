Shader "NiksShaders/Shader63bMask"
{
	Properties{}

	SubShader{

		Tags {
			"RenderType" = "Opaque"
		}

		Pass {
			ColorMask 0
			ZWrite Off
		}
	}
}
