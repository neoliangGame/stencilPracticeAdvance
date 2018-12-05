//1.写入模板缓冲遮罩值
//2.获取遮罩前后值，存入GrabTexture的RG通道
Shader "neo/stencilMaskPreWork"
{
	Properties
	{
		_Stencil("Stencil ID", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Background-1" }
		LOD 100


		//0.背面写入R通道，同时写入模板缓冲值做遮罩
		Pass
		{
			Stencil
			{
				Ref[_Stencil]
				Comp Always
				Pass Replace
			}

			Cull Front
			ColorMask R
			ZTest Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 screenPos : COLOR0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float fixedDepth = LinearEyeDepth(i.screenPos.z);//Linear01Depth(i.screenPos.z);
				return float4(fixedDepth, fixedDepth, fixedDepth, fixedDepth);
			}
			ENDCG
		}


		//1.正面写入G通道
		Pass
		{

			Cull Back
			ColorMask G
			ZTest Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 screenPos : COLOR0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float fixedDepth = LinearEyeDepth(i.screenPos.z);//Linear01Depth(i.screenPos.z);
				return float4(fixedDepth, fixedDepth, fixedDepth, fixedDepth);
			}
			ENDCG
		}

		//2.保存遮罩的前后深度值
		GrabPass{
			"neoMaskBackground"
		}
	}
}
