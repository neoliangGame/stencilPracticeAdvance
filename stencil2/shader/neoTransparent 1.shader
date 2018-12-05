Shader "neo/neoTransparent1"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Transparent("Transparent", Range(0,1)) = 1
	}
	SubShader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _Color;
			float _Transparent;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				half3 lightDir = normalize(ObjSpaceLightDir(v.vertex));
				half3 normalDir = normalize(v.normal);
				half lightStrength = min(dot(normalDir, lightDir) * 0.8 + 0.2, 1);
				o.light = float4(lightStrength,0,0,0);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float a = col.a;
				col.xyz *= i.light.x * _Color.xyz;
				return float4(col.xyz, a * _Transparent);
			}
			ENDCG
		}
	}
}
