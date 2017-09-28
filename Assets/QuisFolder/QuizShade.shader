Shader "Unlit/QuizShade"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tex2("Texture", 2D) = "red" {}
		_Tex3("Texture", 2D) = "blue "{}
		//_Color("Green", Color) = (0,1,0,1) 
		_Slider ("VertSlide", Range (1, 10)) = 5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _Tex2;
			float4 _Tex2_ST;

			sampler2D _Tex3;
			float4 _Tex3_ST;

			fixed4 _Color;

			float _Slider;
			//The first 2 should be blended together using the 3rd's green channel. 
			//Add a slider that goes from 1 to 10 that scales the vertices. Turn in a file called "ShaderDrill1_username.shader". 
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex  * _Slider);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex ) ;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col2 = tex2D(_Tex2, i.uv);
				fixed4 col3 = tex2D(_Tex3, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return lerp(col, col2, col3.y);
			}
			ENDCG
		}
	}
}
