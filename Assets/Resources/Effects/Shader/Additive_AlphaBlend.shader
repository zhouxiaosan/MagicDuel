// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Common/Additive_AlphaBlend"
{
	Properties
	{
		[Enum(Additive,1,AlphaBlend,10)]_BlendMode("混合模式", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("单双面显示", Float) = 0
		_SoftParticleIntensity("软粒子", Float) = 0
		[Toggle]_Fresnel("Fresnel", Float) = 0
		[Toggle]_ReverseFresnel("ReverseFresnel", Float) = 0
		_RimMin("RimMin", Range( 0 , 1)) = 0
		_RimMax("RimMax", Range( 0 , 1)) = 1
		_RimPower("RimPower", Float) = 1
		_RimIntensity("RimIntensity", Float) = 1
		_Alpha("Alpha", Range( 0 , 1)) = 1
		[HDR]_TintColot("Tint Colot", Color) = (1,1,1,1)
		_TintColorIntensity("TintColorIntensity", Float) = 1
		_ParticleTexture("Particle Texture", 2D) = "white" {}
		_UVScale("UVScale", Float) = 1
		_UVRotator("UVRotator", Float) = 0
		_ScrollSpeedU("ScrollSpeedU", Float) = 0
		_ScrollSpeedV("ScrollSpeedV", Float) = 0
		[Toggle]_ScrollSpeedUV_ZW("ScrollSpeedUV_ZW", Float) = 0
		_MaskTexture("Mask Texture", 2D) = "white" {}
		_MaskTexOffsetX("MaskTexOffsetX", Float) = 0
		_MaskTexOffsetY("MaskTexOffsetY", Float) = 0
		_Mask01_Texture("Mask01_Texture", 2D) = "white" {}
		_Mask01_TexScrollSpeedU("Mask01_TexScrollSpeedU", Float) = 0
		_Mask01_TexScrollSpeedV("Mask01_TexScrollSpeedV", Float) = 0
		[Toggle]_NoiseMask01("NoiseMask01", Float) = 0
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseStrength("NoiseStrength", Float) = 0
		_NoiseScrollSpeedU("NoiseScrollSpeedU", Float) = 0
		_NoiseScrollSpeedV("NoiseScrollSpeedV", Float) = 0
		[Toggle(_DISSOLVE_2UX_ON)] _Dissolve_2Ux("Dissolve_2Ux", Float) = 0
		_DissolveStrength("DissolveStrength", Float) = 0
		[Toggle(_DISSOLVEV_ON)] _DissolveV("DissolveV", Float) = 0
		[Toggle(_DISSOLVEREVERSE_ON)] _DissolveReverse("DissolveReverse", Float) = 0
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_DissolveTexScrollSpeedU("DissolveTexScrollSpeedU", Float) = 0
		_DissolveTexScrollSpeedV("DissolveTexScrollSpeedV", Float) = 0
		_DissolveMaskTex("DissolveMaskTex", 2D) = "white" {}
		[Toggle(_SOFTORHARDDISSOLVE_ON)] _SoftOrHardDissolve("SoftOrHardDissolve", Float) = 0
		_VertexOffsetTex("VertexOffsetTex", 2D) = "white" {}
		_VertexOffsetScale("VertexOffsetScale", Vector) = (0,0,0,0)
		_VertexOffsetTex_ScrollSpeedU("VertexOffsetTex_ScrollSpeedU", Float) = 0
		_VertexOffsetTex_ScrollSpeedV("VertexOffsetTex_ScrollSpeedV", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
	LOD 0

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha [_BlendMode]
		AlphaToMask Off
		Cull [_CullMode]
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature _DISSOLVE_2UX_ON
			#pragma shader_feature _SOFTORHARDDISSOLVE_ON
			#pragma shader_feature_local _DISSOLVEREVERSE_ON
			#pragma shader_feature_local _DISSOLVEV_ON
			#pragma multi_compile_instancing
            #pragma multi_compile _ STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _CullMode;
			uniform float _BlendMode;
			uniform sampler2D _VertexOffsetTex;
			uniform float _VertexOffsetTex_ScrollSpeedU;
			uniform float _VertexOffsetTex_ScrollSpeedV;
			uniform float4 _VertexOffsetTex_ST;
			uniform float3 _VertexOffsetScale;
			uniform sampler2D _ParticleTexture;
			uniform float _ScrollSpeedUV_ZW;
			uniform float _ScrollSpeedU;
			uniform float _ScrollSpeedV;
			uniform float4 _ParticleTexture_ST;
			uniform float _UVScale;
			uniform float _UVRotator;
			uniform sampler2D _NoiseTex;
			uniform float _NoiseScrollSpeedU;
			uniform float _NoiseScrollSpeedV;
			uniform float4 _NoiseTex_ST;
			uniform float _NoiseStrength;
			uniform float4 _TintColot;
			uniform float _TintColorIntensity;
			uniform sampler2D _MaskTexture;
			uniform float4 _MaskTexture_ST;
			uniform float _MaskTexOffsetX;
			uniform float _MaskTexOffsetY;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _SoftParticleIntensity;
			uniform sampler2D _DissolveMaskTex;
			uniform float4 _DissolveMaskTex_ST;
			uniform sampler2D _DissolveTex;
			uniform float _DissolveTexScrollSpeedU;
			uniform float _DissolveTexScrollSpeedV;
			uniform float4 _DissolveTex_ST;
			uniform float _DissolveStrength;
			uniform sampler2D _Mask01_Texture;
			uniform float _Mask01_TexScrollSpeedU;
			uniform float _Mask01_TexScrollSpeedV;
			uniform float4 _Mask01_Texture_ST;
			uniform float _NoiseMask01;
			uniform float _ReverseFresnel;
			uniform float _Fresnel;
			uniform float _RimMin;
			uniform float _RimMax;
			uniform float _RimPower;
			uniform float _RimIntensity;
			uniform float _Alpha;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 appendResult75 = (float2(_VertexOffsetTex_ScrollSpeedU , _VertexOffsetTex_ScrollSpeedV));
				float2 uv_VertexOffsetTex = v.ase_texcoord.xy * _VertexOffsetTex_ST.xy + _VertexOffsetTex_ST.zw;
				float2 panner76 = ( 1.0 * _Time.y * appendResult75 + uv_VertexOffsetTex);
				float4 VertexOffset77 = ( tex2Dlod( _VertexOffsetTex, float4( panner76, 0, 0.0) ) * float4( v.ase_normal , 0.0 ) * float4( _VertexOffsetScale , 0.0 ) );
				
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = VertexOffset77.rgb;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 appendResult35 = (float2(_ScrollSpeedU , _ScrollSpeedV));
				float2 uv_ParticleTexture = i.ase_texcoord1.xy * _ParticleTexture_ST.xy + _ParticleTexture_ST.zw;
				float cos33 = cos( ( ( _UVRotator * ( 2.0 * UNITY_PI ) ) / -360.0 ) );
				float sin33 = sin( ( ( _UVRotator * ( 2.0 * UNITY_PI ) ) / -360.0 ) );
				float2 rotator33 = mul( ( ( ( uv_ParticleTexture + float2( -0.5,-0.5 ) ) * _UVScale ) + float2( 0.5,0.5 ) ) - float2( 0.5,0.5 ) , float2x2( cos33 , -sin33 , sin33 , cos33 )) + float2( 0.5,0.5 );
				float2 MainTexUV52 = rotator33;
				float2 panner49 = ( 1.0 * _Time.y * appendResult35 + MainTexUV52);
				float4 texCoord32 = i.ase_texcoord2;
				texCoord32.xy = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult34 = (float2(texCoord32.z , texCoord32.w));
				float2 appendResult42 = (float2(_NoiseScrollSpeedU , _NoiseScrollSpeedV));
				float2 uv_NoiseTex = i.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner43 = ( 1.0 * _Time.y * appendResult42 + uv_NoiseTex);
				float4 tex2DNode44 = tex2D( _NoiseTex, panner43 );
				float2 appendResult45 = (float2(tex2DNode44.r , tex2DNode44.g));
				float2 NoiseTex149 = ( appendResult45 * _NoiseStrength );
				float4 tex2DNode2 = tex2D( _ParticleTexture, ( (( _ScrollSpeedUV_ZW )?( ( MainTexUV52 + appendResult34 ) ):( panner49 )) + NoiseTex149 ) );
				float2 uv_MaskTexture = i.ase_texcoord1.xy * _MaskTexture_ST.xy + _MaskTexture_ST.zw;
				float2 appendResult132 = (float2(_MaskTexOffsetX , _MaskTexOffsetY));
				float4 tex2DNode8 = tex2D( _MaskTexture, ( uv_MaskTexture + appendResult132 ) );
				float4 screenPos = i.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth9 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth9 = abs( ( screenDepth9 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _SoftParticleIntensity ) );
				float SoftParticle80 = saturate( distanceDepth9 );
				float2 uv_DissolveMaskTex = i.ase_texcoord1.xy * _DissolveMaskTex_ST.xy + _DissolveMaskTex_ST.zw;
				float2 appendResult97 = (float2(_DissolveTexScrollSpeedU , _DissolveTexScrollSpeedV));
				float2 uv_DissolveTex = i.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 panner99 = ( 1.0 * _Time.y * appendResult97 + uv_DissolveTex);
				float4 tex2DNode56 = tex2D( _DissolveTex, panner99 );
				float4 texCoord55 = i.ase_texcoord2;
				texCoord55.xy = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _DISSOLVEV_ON
				float staticSwitch136 = texCoord55.y;
				#else
				float staticSwitch136 = texCoord55.x;
				#endif
				#ifdef _DISSOLVEREVERSE_ON
				float staticSwitch138 = ( 1.0 - staticSwitch136 );
				#else
				float staticSwitch138 = staticSwitch136;
				#endif
				float temp_output_134_0 = ( staticSwitch138 + _DissolveStrength );
				#ifdef _SOFTORHARDDISSOLVE_ON
				float staticSwitch94 = step( temp_output_134_0 , tex2DNode56.r );
				#else
				float staticSwitch94 = ( tex2D( _DissolveMaskTex, uv_DissolveMaskTex ).r * saturate( ( tex2DNode56.r + 1.0 + ( -2.0 * temp_output_134_0 ) ) ) );
				#endif
				#ifdef _DISSOLVE_2UX_ON
				float staticSwitch63 = staticSwitch94;
				#else
				float staticSwitch63 = 1.0;
				#endif
				float Dissolve60 = staticSwitch63;
				float2 appendResult89 = (float2(_Mask01_TexScrollSpeedU , _Mask01_TexScrollSpeedV));
				float2 uv_Mask01_Texture = i.ase_texcoord1.xy * _Mask01_Texture_ST.xy + _Mask01_Texture_ST.zw;
				float2 panner88 = ( 1.0 * _Time.y * appendResult89 + uv_Mask01_Texture);
				float Mask0190 = tex2D( _Mask01_Texture, ( panner88 + (( _NoiseMask01 )?( NoiseTex149 ):( float2( 0,0 ) )) ) ).r;
				float3 ase_worldNormal = i.ase_texcoord4.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult110 = dot( ase_worldNormal , ase_worldViewDir );
				float clampResult119 = clamp( dotResult110 , 0.0 , 1.0 );
				float smoothstepResult114 = smoothstep( _RimMin , _RimMax , clampResult119);
				float ReverseFresnel126 = (( _ReverseFresnel )?( ( saturate( pow( abs( (( _Fresnel )?( ( 1.0 - smoothstepResult114 ) ):( smoothstepResult114 )) ) , _RimPower ) ) * _RimIntensity ) ):( 1.0 ));
				float4 appendResult6 = (float4(( tex2DNode2 * ( _TintColot * _TintColorIntensity ) * i.ase_color ).rgb , ( tex2DNode2.a * ( _TintColot.a * _TintColorIntensity ) * i.ase_color.a * tex2DNode8.r * SoftParticle80 * Dissolve60 * Mask0190 * tex2DNode8.a * ReverseFresnel126 * _Alpha )));
				
				
				finalColor = appendResult6;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;118;137.2334,460.2153;Inherit;False;1814.6;472.8306;fresnel;16;122;117;115;124;116;113;123;114;112;111;119;110;109;108;127;128;fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;53;-3321.225,-945.5435;Inherit;False;1245.571;511.539;MainTexUV;14;18;21;22;23;28;19;20;26;29;33;52;104;106;107;MainTexUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;61;-3212.771,1198.978;Inherit;False;2653.378;668.271;Dissolve;21;60;63;64;94;58;93;59;56;57;99;98;97;95;96;100;101;102;103;134;136;138;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-3081.635,1536.827;Float;False;Property;_DissolveTexScrollSpeedU;DissolveTexScrollSpeedU;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-3081.729,1611.733;Float;False;Property;_DissolveTexScrollSpeedV;DissolveTexScrollSpeedV;35;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;104;-3263.028,-781.8611;Float;False;Constant;_Vector0;Vector 0;28;0;Create;True;0;0;0;False;0;False;-0.5,-0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PiNode;19;-3148.17,-544.4045;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;98;-2912.516,1413.927;Inherit;False;0;56;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;97;-2828.229,1560.834;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-3057.756,-858.7991;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-3065.929,-758.7661;Float;False;Property;_UVScale;UVScale;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-3101.026,-641.2347;Float;False;Property;_UVRotator;UVRotator;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2329.351,1635.036;Float;False;Constant;_Float1;Float 1;28;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-2902.247,-600.8928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;99;-2674.541,1479.346;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;106;-2920.028,-728.8611;Float;False;Constant;_Vector1;Vector 1;28;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-2913.994,-820.3156;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-2929.028,-505.8611;Float;False;Constant;_Float3;Float 3;28;0;Create;True;0;0;0;False;0;False;-360;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-2729.08,-808.2522;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;56;-2479.079,1450.718;Inherit;True;Property;_DissolveTex;DissolveTex;33;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-2746.858,305.8044;Float;False;Property;_NoiseScrollSpeedU;NoiseScrollSpeedU;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-2725.191,-589.8625;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;-360;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2142.351,1533.036;Float;False;Constant;_Float2;Float 2;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2744.751,376.7348;Float;False;Property;_NoiseScrollSpeedV;NoiseScrollSpeedV;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-2140.317,1604.157;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-2591.739,175.9048;Inherit;False;0;44;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;42;-2505.452,325.8116;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-1983.878,1477.586;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;33;-2555.751,-697.9404;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;92;-344.494,-625.3018;Inherit;False;1260.332;379.8807;Mask01;8;85;86;84;89;88;83;90;147;Mask01;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-294.494,-360.8212;Float;False;Property;_Mask01_TexScrollSpeedV;Mask01_TexScrollSpeedV;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-289.3248,-449.4473;Float;False;Property;_Mask01_TexScrollSpeedU;Mask01_TexScrollSpeedU;22;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;-1928.03,1278.012;Inherit;True;Property;_DissolveMaskTex;DissolveMaskTex;36;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-1957.573,-233.4039;Float;False;Property;_ScrollSpeedV;ScrollSpeedV;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;82;-1206.093,-1575.37;Inherit;False;948.6831;185.0002;SoftParticle;4;9;10;11;80;SoftParticle;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1960.373,-323.8037;Float;False;Property;_ScrollSpeedU;ScrollSpeedU;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;43;-2316.764,222.3239;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;79;-3327.081,-1819.965;Inherit;False;1874.806;650.0377;VertexOffset;10;73;74;75;72;76;68;66;70;67;77;VertexOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-2306.854,-673.892;Float;False;MainTexUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;44;-2109.567,219.0934;Inherit;True;Property;_NoiseTex;NoiseTex;25;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;89;-29.99014,-401.7088;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-1592.84,1389.51;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-3270.648,-1501.122;Float;False;Property;_VertexOffsetTex_ScrollSpeedV;VertexOffsetTex_ScrollSpeedV;41;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;35;-1724.572,-280.8038;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-3277.081,-1587.658;Float;False;Property;_VertexOffsetTex_ScrollSpeedU;VertexOffsetTex_ScrollSpeedU;40;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;93;-2134.632,1697.057;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1791.986,-396.3958;Inherit;False;52;MainTexUV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;86;-259.5247,-575.3018;Inherit;False;0;83;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;34;-1775.453,-24.64981;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1156.093,-1509.97;Float;False;Property;_SoftParticleIntensity;软粒子;2;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-1272.799,1489.736;Float;False;Constant;_Float0;Float 0;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1798.156,353.3683;Float;False;Property;_NoiseStrength;NoiseStrength;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;88;134.9741,-451.7766;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-1531.317,-143.0467;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;9;-923.1837,-1524.17;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;45;-1754.624,244.6945;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-2915.38,-1608.76;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;94;-1409.247,1581.607;Float;False;Property;_SoftOrHardDissolve;SoftOrHardDissolve;37;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;49;-1541.5,-327.6162;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;72;-3033.432,-1769.965;Inherit;False;0;66;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;10;-657.9825,-1525.37;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;83;347.7154,-480.6529;Inherit;True;Property;_Mask01_Texture;Mask01_Texture;21;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;76;-2689.406,-1678.973;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;63;-1113.279,1543.785;Float;False;Property;_Dissolve_2Ux;Dissolve_2Ux;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1592.461,280.8681;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-989.9578,-187.8037;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-868.6869,1545.041;Float;True;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;68;-2209.375,-1501.527;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;66;-2328.375,-1700.527;Inherit;True;Property;_VertexOffsetTex;VertexOffsetTex;38;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-482.2099,-1516.809;Float;False;SoftParticle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;70;-2237.375,-1355.527;Float;False;Property;_VertexOffsetScale;VertexOffsetScale;39;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;814.0381,-465.6288;Float;False;Mask01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-642.6055,685.6082;Inherit;False;60;Dissolve;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-777.765,-220.408;Inherit;True;Property;_ParticleTexture;Particle Texture;12;0;Create;True;0;0;0;False;0;False;-1;None;84ed019d70af07e4fb23b6f7d5540ca1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;81;-692.1074,539.066;Inherit;False;80;SoftParticle;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-639.9393,767.5078;Inherit;False;90;Mask01;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1947.373,-1628.527;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1677.073,-1596.299;Float;False;VertexOffset;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-399.3011,122.0258;Inherit;False;10;10;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;15;-1351.75,-946.7886;Inherit;False;501.6718;212.1476;调节切换;2;16;17;调节切换;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-428.4688,-112.9508;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-165.6512,176.6224;Inherit;False;77;VertexOffset;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1125.14,-891.4799;Float;False;Property;_CullMode;单双面显示;1;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;-201.743,5.120315;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-661.0735,903.834;Inherit;False;126;ReverseFresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;108;150.3245,506.8351;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;109;173.3243,644.8364;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;110;368.3246,578.8362;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;119;513.9688,579.0054;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;386.6024,704.3376;Float;False;Property;_RimMin;RimMin;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;386.2725,788.3262;Float;False;Property;_RimMax;RimMax;6;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1299.421,-897.3236;Float;False;Property;_BlendMode;混合模式;0;1;[Enum];Create;False;0;2;Additive;1;AlphaBlend;10;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;114;675.2287,552.2781;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;123;1350.591,634.3399;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;1326.495,707.5388;Float;False;Property;_RimPower;RimPower;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;116;1496.828,661.4223;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;124;1652.474,661.5148;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;1629.644,749.5042;Float;False;Property;_RimIntensity;RimIntensity;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;1807.878,701.6785;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;1808.188,624.8467;Inherit;False;Constant;_Float4;Float 4;32;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;2168.745,654.3008;Inherit;False;ReverseFresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;121;1952.364,653.2737;Inherit;False;Property;_ReverseFresnel;ReverseFresnel;4;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;128;956.7746,670.8463;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;127;1130.907,549.5125;Inherit;False;Property;_Fresnel;Fresnel;3;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-2014.453,-95.04975;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;54;-1812.608,-137.3635;Inherit;False;52;MainTexUV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-3307.225,-901.5435;Inherit;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;129;-1426.801,456.2208;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;132;-1278.391,659.3737;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;133;-1091.156,525.8346;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-1518.596,626.3542;Inherit;False;Property;_MaskTexOffsetX;MaskTexOffsetX;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-1515.262,720.5275;Inherit;False;Property;_MaskTexOffsetY;MaskTexOffsetY;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;-2285.109,1737.634;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;-1761.955,1484.404;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;55;-3429.36,1694.168;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;136;-3195.802,1715.675;Inherit;False;Property;_DissolveV;DissolveV;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;138;-2645.615,1695.56;Inherit;False;Property;_DissolveReverse;DissolveReverse;32;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;137;-2906.117,1816.998;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2515.109,1922.966;Inherit;False;Property;_DissolveStrength;DissolveStrength;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-682.4514,998.2225;Inherit;False;Property;_Alpha;Alpha;9;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;12.03513,2.578947;Float;False;True;-1;2;ASEMaterialInspector;0;5;Common/Additive_AlphaBlend;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;True;_BlendMode;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;False;;True;False;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.ColorNode;1;-1047.825,-48.96944;Float;False;Property;_TintColot;Tint Colot;10;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.9727553,1,0.9528301,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;141;-1057.543,156.1839;Inherit;False;Property;_TintColorIntensity;TintColorIntensity;11;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-809.2328,-15.1684;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-805.2327,106.8316;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-789.4764,336.0537;Inherit;True;Property;_MaskTexture;Mask Texture;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;3;-657.7374,193.7492;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;38;-1337.449,-232.1003;Float;False;Property;_ScrollSpeedUV_ZW;ScrollSpeedUV_ZW;17;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;234.5612,-333.1205;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;149;-1389.655,265.8358;Inherit;False;NoiseTex;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-282.8442,-193.5018;Inherit;False;149;NoiseTex;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;146;-16.60774,-240.6229;Inherit;False;Property;_NoiseMask01;NoiseMask01;24;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
WireConnection;97;0;95;0
WireConnection;97;1;96;0
WireConnection;22;0;18;0
WireConnection;22;1;104;0
WireConnection;26;0;20;0
WireConnection;26;1;19;0
WireConnection;99;0;98;0
WireConnection;99;2;97;0
WireConnection;23;0;22;0
WireConnection;23;1;21;0
WireConnection;28;0;23;0
WireConnection;28;1;106;0
WireConnection;56;1;99;0
WireConnection;29;0;26;0
WireConnection;29;1;107;0
WireConnection;57;0;102;0
WireConnection;57;1;134;0
WireConnection;42;0;40;0
WireConnection;42;1;39;0
WireConnection;59;0;56;1
WireConnection;59;1;103;0
WireConnection;59;2;57;0
WireConnection;33;0;28;0
WireConnection;33;2;29;0
WireConnection;43;0;41;0
WireConnection;43;2;42;0
WireConnection;52;0;33;0
WireConnection;44;1;43;0
WireConnection;89;0;85;0
WireConnection;89;1;84;0
WireConnection;101;0;100;1
WireConnection;101;1;58;0
WireConnection;35;0;24;0
WireConnection;35;1;27;0
WireConnection;93;0;134;0
WireConnection;93;1;56;1
WireConnection;34;0;32;3
WireConnection;34;1;32;4
WireConnection;88;0;86;0
WireConnection;88;2;89;0
WireConnection;36;0;54;0
WireConnection;36;1;34;0
WireConnection;9;0;11;0
WireConnection;45;0;44;1
WireConnection;45;1;44;2
WireConnection;75;0;74;0
WireConnection;75;1;73;0
WireConnection;94;1;101;0
WireConnection;94;0;93;0
WireConnection;49;0;50;0
WireConnection;49;2;35;0
WireConnection;10;0;9;0
WireConnection;83;1;147;0
WireConnection;76;0;72;0
WireConnection;76;2;75;0
WireConnection;63;1;64;0
WireConnection;63;0;94;0
WireConnection;47;0;45;0
WireConnection;47;1;46;0
WireConnection;48;0;38;0
WireConnection;48;1;149;0
WireConnection;60;0;63;0
WireConnection;66;1;76;0
WireConnection;80;0;10;0
WireConnection;90;0;83;1
WireConnection;2;1;48;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;67;2;70;0
WireConnection;77;0;67;0
WireConnection;5;0;2;4
WireConnection;5;1;144;0
WireConnection;5;2;3;4
WireConnection;5;3;8;1
WireConnection;5;4;81;0
WireConnection;5;5;62;0
WireConnection;5;6;91;0
WireConnection;5;7;8;4
WireConnection;5;8;125;0
WireConnection;5;9;139;0
WireConnection;4;0;2;0
WireConnection;4;1;143;0
WireConnection;4;2;3;0
WireConnection;6;0;4;0
WireConnection;6;3;5;0
WireConnection;110;0;108;0
WireConnection;110;1;109;0
WireConnection;119;0;110;0
WireConnection;114;0;119;0
WireConnection;114;1;111;0
WireConnection;114;2;112;0
WireConnection;123;0;127;0
WireConnection;116;0;123;0
WireConnection;116;1;113;0
WireConnection;124;0;116;0
WireConnection;117;0;124;0
WireConnection;117;1;115;0
WireConnection;126;0;121;0
WireConnection;121;0;122;0
WireConnection;121;1;117;0
WireConnection;128;0;114;0
WireConnection;127;0;114;0
WireConnection;127;1;128;0
WireConnection;132;0;130;0
WireConnection;132;1;131;0
WireConnection;133;0;129;0
WireConnection;133;1;132;0
WireConnection;134;0;138;0
WireConnection;134;1;135;0
WireConnection;58;0;59;0
WireConnection;136;1;55;1
WireConnection;136;0;55;2
WireConnection;138;1;136;0
WireConnection;138;0;137;0
WireConnection;137;0;136;0
WireConnection;0;0;6;0
WireConnection;0;1;78;0
WireConnection;143;0;1;0
WireConnection;143;1;141;0
WireConnection;144;0;1;4
WireConnection;144;1;141;0
WireConnection;8;1;133;0
WireConnection;38;0;49;0
WireConnection;38;1;36;0
WireConnection;147;0;88;0
WireConnection;147;1;146;0
WireConnection;149;0;47;0
WireConnection;146;1;150;0
ASEEND*/
//CHKSM=23711268E71E695841AFA5AF02B33380ED21B7A0