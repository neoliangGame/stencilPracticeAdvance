Shader "neo/neoOpaque1"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_ColorStrength("Color Strength", Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		Cull Off
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _Color;
			float _ColorStrength;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				half3 lightDir = normalize(ObjSpaceLightDir(v.vertex));
				half3 normalDir = normalize(v.normal);
				o.light = dot(normalDir, lightDir);// min(dot(normalDir, lightDir) * 0.4 + 0.5, 1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col *= i.light;
				col = (1 - _ColorStrength) * col + _Color * _ColorStrength;
				return col;
			}
			ENDCG
		}
	}
}
