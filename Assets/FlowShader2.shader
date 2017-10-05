Shader "Custom/FlowShader2" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpTex("Normal Map (RGB)", 2D) = "bump" {}
		_FlowTex ("FlowMap", 2D) = "bump" {}
		_Flow("Flow (X, Y, Cycle Time, Cycle Speed", Vector) = (1,1,0.1,1)
		_NoiseTex("Noise", 2D) = "black"
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
		sampler2D _BumpTex;
		sampler2D _FlowTex;
		sampler2D _NoiseTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_FlowTex;
		};

		fixed4 _Color;
		float4 _Flow;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {

			float noise = tex2D(_NoiseTex, IN.uv_FlowTex).r;

			float2 flow = 2 * tex2D(_FlowTex, IN.uv_FlowTex).xy - 1;
			float strength = length(flow);
			flow.x *= _Flow.x;
			flow.y *= _Flow.y;

			flow *= noise;

			float halfCycle = _Flow.z * 0.5;
			float phase0 = fmod(_Time.x * _Flow.w + halfCycle + noise, _Flow.z);
			float phase1 = fmod(_Time.x * _Flow.w + noise, _Flow.z);
			float t = abs(phase0 - halfCycle) / halfCycle;

			fixed4 c1 = tex2D(_MainTex, IN.uv_MainTex - flow * phase0);
			fixed4 c2 = tex2D(_MainTex, IN.uv_MainTex + float2(0.5,0.5) - flow * phase1);
			fixed4 c = lerp(c1,c2,t) * _Color;

			o.Albedo = c.rgb;
			o.Alpha = c.a;

			fixed3 n1 = UnpackNormal(tex2D(_BumpTex, IN.uv_MainTex - flow * phase0));
			fixed3 n2 = UnpackNormal(tex2D(_BumpTex, IN.uv_MainTex + float2(0.5,0.5) - flow * phase1));
			fixed3 n = lerp(float3(0.5,0.5,1), lerp(n1,n2,t), strength);
			o.Normal = n;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
