Shader "Unlit/FlowShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FlowTex ("FlowMap", 2D) = "bump" {}
		_Flow("Flow (X, Y, Cycle Time, Cycle Speed", Vector) = (1,1,0.1,1)

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
				float2 uv2 :  TEXCOORD1;

				float4 vertex : SV_POSITION;
			};

			sampler2D _FlowTex;
			float4 _FlowTex_ST;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _Flow;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _FlowTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 flow = 2 * tex2D(_FlowTex, i.uv).xy - 1;
				flow.x *= _Flow.x;
				flow.y *= _Flow.y;

				float halfCycle = _Flow.z * 0.5;
				float phase0 = fmod(_Time.x * _Flow.w + halfCycle, _Flow.z);
				float phase1 = fmod(_Time.x * _Flow.w, _Flow.z);
				float t = abs(phase0 - halfCycle) / halfCycle;

				fixed4 c1 = tex2D(_MainTex, i.uv - flow * phase0);
				fixed4 c2 = tex2D(_MainTex, i.uv - flow * phase1);
				fixed4 col = lerp(c1,c2,t);

				return col;
			}
			ENDCG
		}
	}
}
