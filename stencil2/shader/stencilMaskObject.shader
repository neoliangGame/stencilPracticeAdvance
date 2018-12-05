Shader "neo/stencilMaskObject"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_ColorStrength("Color Strength", Range(0,1)) = 0.5

		_Stencil("Stencil ID", Float) = 0
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }
		LOD 100

		//0.根据Grab的值进行控制深度前后
		//	其他逻辑正常
		Pass
		{
			Stencil
			{
				Ref [_Stencil]
				Comp Equal
			}
			Tags{ "LightMode" = "ForwardBase" }

			Cull Off
			ZTest On
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma multi_compile_fwdbase

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 light : COLOR0;
				float4 zMaskUV : COLOR1;
				float4 screenPos : COLOR2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _Color;
			float _ColorStrength;

			sampler2D neoMaskBackground;
			float4 neoMaskBackground_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				half3 lightDir = normalize(ObjSpaceLightDir(v.vertex));
				half3 normalDir = normalize(v.normal);
				o.light = min(dot(normalDir, lightDir) * 0.9 + 0.2, 1);

				o.zMaskUV = ComputeGrabScreenPos(o.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 zMask = tex2Dproj(neoMaskBackground, i.zMaskUV);
				float fixedDepth = LinearEyeDepth(i.screenPos.z);
				clip(fixedDepth - zMask.r);
				clip(zMask.g - fixedDepth);

				fixed4 col = tex2D(_MainTex, i.uv);
				col *= i.light;
				col = (1 - _ColorStrength) * col + _Color * _ColorStrength;
				return col;
			}
			ENDCG
		}
	}
}
