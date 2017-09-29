Shader "Custom/Snow" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormTex ("Normal Map", 2D) = "bump" {}
		_SnowNorm ("Snow Map", 2D) = "bump" {}

		_HeightTex ("Height Map", 2D) = "black" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_SnowDir("Snow Direction", Vector) = (0,1,0,0)
		_SnowAmt("Snow Buildup", Range(0,2)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NormTex;
		sampler2D _HeightTex;
		sampler2D _SnowNorm;

		struct Input {
			float2 uv_MainTex;
			float3 worldNormal;
			INTERNAL_DATA
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float4 _SnowDir;
		float _SnowAmt;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Normal = UnpackNormal(tex2D(_NormTex, IN.uv_MainTex));

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float3 worldNorm = WorldNormalVector(IN, o.Normal);
			float up = _SnowAmt * saturate(dot(worldNorm, _SnowDir));
			o.Normal = lerp(o.Normal, UnpackNormal(tex2D(_SnowNorm, IN.uv_MainTex)), up);
			o.Albedo = lerp(c.rgb, 1, up);
			o.Metallic = lerp(_Metallic, 0, up);
			o.Smoothness = lerp(_Glossiness, 0.7, up);
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
