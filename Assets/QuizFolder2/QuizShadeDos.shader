Shader "Custom/QuizShadeDos" {

//	Write a surface shader with 2 input textures. Texture 1 should be used for the Albedo channel.
//	 Texture 2 should oscillate between black and full color using a sine wave. 
//	The resulting color should be used for the Emissive channel. Turn in a file called "ShaderDrill2_username.shader". This assignment is worth 50 points.
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SecTex("Black and White", 2D) = "black" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
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
		sampler2D _SecTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_SecTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex);
			float4 e = tex2D (_MainTex, IN.uv_MainTex);
			float4 b = float4(0,0,0,1);
			o.Emission = lerp(b, e, sin(_Time.y));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
