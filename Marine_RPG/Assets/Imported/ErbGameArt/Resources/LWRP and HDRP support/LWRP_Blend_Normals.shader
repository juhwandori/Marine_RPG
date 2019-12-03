// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ERB/LWRP/Particles/Blend_Normals"
{
    Properties
    {
		_MainTex("MainTex", 2D) = "white" {}
		_Noise("Noise", 2D) = "white" {}
		_SpeedMainTexUVNoiseZW("Speed MainTex U/V + Noise Z/W", Vector) = (0,0,0,0)
		_Emission("Emission", Float) = 2
		_Color("Color", Color) = (0.5,0.5,0.5,1)
		_Depthpower("Depth power", Float) = 1
		_Mask("Mask", 2D) = "white" {}
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_NormalMap("Normal Map", 2D) = "white" {}
		_NormalScale("Normal Scale", Float) = 1
		[Toggle]_Usecenterglow("Use center glow?", Float) = 0
		[Toggle]_Usedepth("Use depth?", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }


    SubShader
    {
		
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
        Pass
        {
			
        	Tags { "LightMode"="LightweightForward" }

        	Name "Base"
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
            
        	HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles

            

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

        	#define ASE_SRP_VERSION 60901
        	#define _NORMALMAP 1
        	#define REQUIRE_DEPTH_TEXTURE 1


        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Noise;
			float4 _Noise_ST;
			sampler2D _Mask;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float _Usecenterglow;
			float4 _SpeedMainTexUVNoiseZW;
			float4 _Color;
			float4 _Mask_ST;
			float _NormalScale;
			float _Emission;
			float _Usedepth;
			float _Depthpower;
			float _Opacity;
			CBUFFER_END

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                float4 lightmapUVOrVertexSH	  : TEXCOORD0;
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;
				float4 tSpace0					: TEXCOORD3;
				float4 tSpace1					: TEXCOORD4;
				float4 tSpace2					: TEXCOORD5;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
				float4 ase_texcoord8 : TEXCOORD8;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };

			
            GraphVertexOutput vert (GraphVertexInput v  )
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord8 = screenPos;
				
				o.ase_texcoord7.xyz = v.ase_texcoord.xyz;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal =  v.ase_normal ;

        		// Vertex shader outputs defined by graph
                float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
        	    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
        	    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
        	    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN  ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

        		float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );
    
				float2 appendResult21 = (float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y));
				float2 temp_output_24_0 = ( appendResult21 * _Time.y );
				float2 uv0_MainTex = IN.ase_texcoord7.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode13 = tex2D( _MainTex, ( temp_output_24_0 + uv0_MainTex ) );
				float2 appendResult22 = (float2(_SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w));
				float3 uv0_Noise = IN.ase_texcoord7.xyz;
				uv0_Noise.xy = IN.ase_texcoord7.xyz.xy * _Noise_ST.xy + _Noise_ST.zw;
				float4 tex2DNode14 = tex2D( _Noise, ( ( _Time.y * appendResult22 ) + (uv0_Noise).xy ) );
				float3 temp_output_54_0 = (( tex2DNode13 * tex2DNode14 * _Color * IN.ase_color )).rgb;
				float2 uv_Mask = IN.ase_texcoord7.xyz.xy * _Mask_ST.xy + _Mask_ST.zw;
				float3 temp_output_58_0 = (tex2D( _Mask, uv_Mask )).rgb;
				float3 temp_cast_0 = ((1.0 + (uv0_Noise.y - 0.0) * (0.0 - 1.0) / (1.0 - 0.0))).xxx;
				
				float2 uv0_NormalMap = IN.ase_texcoord7.xyz.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				
				float temp_output_60_0 = ( tex2DNode13.a * tex2DNode14.a * _Color.a * IN.ase_color.a );
				float4 screenPos = IN.ase_texcoord8;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth49 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth49 = abs( ( screenDepth49 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depthpower ) );
				
				
		        float3 Albedo = lerp(temp_output_54_0,( temp_output_54_0 * saturate( ( temp_output_58_0 * saturate( ( temp_output_58_0 - temp_cast_0 ) ) ) ) ),_Usecenterglow);
				float3 Normal = UnpackNormalScale( tex2D( _NormalMap, ( temp_output_24_0 + uv0_NormalMap ) ), _NormalScale );
				float3 Emission = ( lerp(temp_output_54_0,( temp_output_54_0 * saturate( ( temp_output_58_0 * saturate( ( temp_output_58_0 - temp_cast_0 ) ) ) ) ),_Usecenterglow) * _Emission );
				float3 Specular = float3(0.5, 0.5, 0.5);
				float Metallic = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = ( lerp(temp_output_60_0,( temp_output_60_0 * saturate( distanceDepth49 ) ),_Usedepth) * _Opacity );
				float AlphaClipThreshold = 0;

        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;

        #ifdef _NORMALMAP
        	    inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
        #else
            #if !SHADER_HINT_NICE_QUALITY
                inputData.normalWS = WorldSpaceNormal;
            #else
        	    inputData.normalWS = normalize(WorldSpaceNormal);
            #endif
        #endif

        #if !SHADER_HINT_NICE_QUALITY
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
        #else
        	    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
        #endif

        	    inputData.shadowCoord = IN.shadowCoord;

        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);

        		half4 color = LightweightFragmentPBR(
        			inputData, 
        			Albedo, 
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

			#ifdef TERRAIN_SPLAT_ADDPASS
				color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
			#else
				color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
			#endif

        #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

		#if ASE_LW_FINAL_COLOR_ALPHA_MULTIPLY
				color.rgb *= color.a;
		#endif
        		return color;
            }

        	ENDHLSL
        }

		
        Pass
        {
			
        	Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

            HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles

            

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #define ASE_SRP_VERSION 60901
            #define REQUIRE_DEPTH_TEXTURE 1


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Noise;
			float4 _Noise_ST;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float _Usecenterglow;
			float4 _SpeedMainTexUVNoiseZW;
			float4 _Color;
			float4 _Mask_ST;
			float _NormalScale;
			float _Emission;
			float _Usedepth;
			float _Depthpower;
			float _Opacity;
			CBUFFER_END

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord7 : TEXCOORD7;
                float4 ase_color : COLOR;
                float4 ase_texcoord8 : TEXCOORD8;
                UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
        	};

			
            // x: global clip space bias, y: normal world space bias
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v )
        	{
        	    VertexOutput o;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO (o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord8 = screenPos;
				
				o.ase_texcoord7.xyz = v.ase_texcoord.xyz;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;

        	    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;

                // normal bias is negative since we want to apply an inset normal offset
                positionWS = _LightDirection * _ShadowBias.xxx + positionWS;
				positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);

                // _ShadowBias.x sign depens on if platform has reversed z buffer
                //clipPos.z += _ShadowBias.x;

        	#if UNITY_REVERSED_Z
        	    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#else
        	    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#endif
                o.clipPos = clipPos;

        	    return o;
        	}

            half4 ShadowPassFragment(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

               float2 appendResult21 = (float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y));
               float2 temp_output_24_0 = ( appendResult21 * _Time.y );
               float2 uv0_MainTex = IN.ase_texcoord7.xy * _MainTex_ST.xy + _MainTex_ST.zw;
               float4 tex2DNode13 = tex2D( _MainTex, ( temp_output_24_0 + uv0_MainTex ) );
               float2 appendResult22 = (float2(_SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w));
               float3 uv0_Noise = IN.ase_texcoord7.xyz;
               uv0_Noise.xy = IN.ase_texcoord7.xyz.xy * _Noise_ST.xy + _Noise_ST.zw;
               float4 tex2DNode14 = tex2D( _Noise, ( ( _Time.y * appendResult22 ) + (uv0_Noise).xy ) );
               float temp_output_60_0 = ( tex2DNode13.a * tex2DNode14.a * _Color.a * IN.ase_color.a );
               float4 screenPos = IN.ase_texcoord8;
               float4 ase_screenPosNorm = screenPos / screenPos.w;
               ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
               float screenDepth49 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
               float distanceDepth49 = abs( ( screenDepth49 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depthpower ) );
               

				float Alpha = ( lerp(temp_output_60_0,( temp_output_60_0 * saturate( distanceDepth49 ) ),_Usedepth) * _Opacity );
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }

            ENDHLSL
        }

		
        Pass
        {
			
        	Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }

            ZWrite On
			ColorMask 0

            HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles


            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #define ASE_SRP_VERSION 60901
            #define REQUIRE_DEPTH_TEXTURE 1


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Noise;
			float4 _Noise_ST;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float _Usecenterglow;
			float4 _SpeedMainTexUVNoiseZW;
			float4 _Color;
			float4 _Mask_ST;
			float _NormalScale;
			float _Emission;
			float _Usedepth;
			float _Depthpower;
			float _Opacity;
			CBUFFER_END

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_color : COLOR;
                float4 ase_texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

			           

            VertexOutput vert(GraphVertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord.xyz = v.ase_texcoord.xyz;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

				float2 appendResult21 = (float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y));
				float2 temp_output_24_0 = ( appendResult21 * _Time.y );
				float2 uv0_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode13 = tex2D( _MainTex, ( temp_output_24_0 + uv0_MainTex ) );
				float2 appendResult22 = (float2(_SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w));
				float3 uv0_Noise = IN.ase_texcoord.xyz;
				uv0_Noise.xy = IN.ase_texcoord.xyz.xy * _Noise_ST.xy + _Noise_ST.zw;
				float4 tex2DNode14 = tex2D( _Noise, ( ( _Time.y * appendResult22 ) + (uv0_Noise).xy ) );
				float temp_output_60_0 = ( tex2DNode13.a * tex2DNode14.a * _Color.a * IN.ase_color.a );
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth49 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth49 = abs( ( screenDepth49 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depthpower ) );
				

				float Alpha = ( lerp(temp_output_60_0,( temp_output_60_0 * saturate( distanceDepth49 ) ),_Usedepth) * _Opacity );
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
		
        Pass
        {
			
        	Name "Meta"
            Tags { "LightMode"="Meta" }

            Cull Off

            HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles


            #pragma vertex vert
            #pragma fragment frag

            #define ASE_SRP_VERSION 60901
            #define REQUIRE_DEPTH_TEXTURE 1


			uniform float4 _MainTex_ST;
			
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			sampler2D _MainTex;
			sampler2D _Noise;
			float4 _Noise_ST;
			sampler2D _Mask;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float _Usecenterglow;
			float4 _SpeedMainTexUVNoiseZW;
			float4 _Color;
			float4 _Mask_ST;
			float _NormalScale;
			float _Emission;
			float _Usedepth;
			float _Depthpower;
			float _Opacity;
			CBUFFER_END

            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_color : COLOR;
                float4 ase_texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

			
            VertexOutput vert(GraphVertexInput v  )
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord.xyz = v.ase_texcoord.xyz;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;
#if !defined( ASE_SRP_VERSION ) || ASE_SRP_VERSION  > 51300				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST);
#else
				o.clipPos = MetaVertexPosition (v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST);
#endif
        	    return o;
            }

            half4 frag(VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float2 appendResult21 = (float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y));
           		float2 temp_output_24_0 = ( appendResult21 * _Time.y );
           		float2 uv0_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
           		float4 tex2DNode13 = tex2D( _MainTex, ( temp_output_24_0 + uv0_MainTex ) );
           		float2 appendResult22 = (float2(_SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w));
           		float3 uv0_Noise = IN.ase_texcoord.xyz;
           		uv0_Noise.xy = IN.ase_texcoord.xyz.xy * _Noise_ST.xy + _Noise_ST.zw;
           		float4 tex2DNode14 = tex2D( _Noise, ( ( _Time.y * appendResult22 ) + (uv0_Noise).xy ) );
           		float3 temp_output_54_0 = (( tex2DNode13 * tex2DNode14 * _Color * IN.ase_color )).rgb;
           		float2 uv_Mask = IN.ase_texcoord.xyz.xy * _Mask_ST.xy + _Mask_ST.zw;
           		float3 temp_output_58_0 = (tex2D( _Mask, uv_Mask )).rgb;
           		float3 temp_cast_0 = ((1.0 + (uv0_Noise.y - 0.0) * (0.0 - 1.0) / (1.0 - 0.0))).xxx;
           		
           		float temp_output_60_0 = ( tex2DNode13.a * tex2DNode14.a * _Color.a * IN.ase_color.a );
           		float4 screenPos = IN.ase_texcoord1;
           		float4 ase_screenPosNorm = screenPos / screenPos.w;
           		ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
           		float screenDepth49 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
           		float distanceDepth49 = abs( ( screenDepth49 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depthpower ) );
           		
				
		        float3 Albedo = lerp(temp_output_54_0,( temp_output_54_0 * saturate( ( temp_output_58_0 * saturate( ( temp_output_58_0 - temp_cast_0 ) ) ) ) ),_Usecenterglow);
				float3 Emission = ( lerp(temp_output_54_0,( temp_output_54_0 * saturate( ( temp_output_58_0 * saturate( ( temp_output_58_0 - temp_cast_0 ) ) ) ) ),_Usecenterglow) * _Emission );
				float Alpha = ( lerp(temp_output_60_0,( temp_output_60_0 * saturate( distanceDepth49 ) ),_Usedepth) * _Opacity );
				float AlphaClipThreshold = 0;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = Albedo;
                metaInput.Emission = Emission;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
        }
		
    }
    
	
	
}
/*ASEBEGIN
Version=17000
545;73;934;656;2294.772;175.9689;3.280989;True;False
Node;AmplifyShaderEditor.Vector4Node;15;-3103.802,24.82627;Float;False;Property;_SpeedMainTexUVNoiseZW;Speed MainTex U/V + Noise Z/W;2;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;22;-2739.856,185.038;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;33;-2267.097,648.0693;Float;True;Property;_Mask;Mask;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;17;-2772.28,53.38881;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2742.397,-37.24139;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-2631.914,822.8644;Float;False;0;14;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-2305.455,-181.7341;Float;False;0;13;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-2525.724,-35.90024;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-2523.281,230.8774;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;58;-1941.441,650.6088;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;81;-2323.092,401.2327;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;36;-1923.092,912.1827;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-2055.981,216.3253;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;37;-1700.092,897.7924;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2002.501,-62.12165;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;83;-1515.119,899.3074;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;13;-1803.192,-66.2159;Float;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;32;-1670.612,486.0577;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;50;-992.9719,832.5517;Float;False;Property;_Depthpower;Depth power;5;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-1728.612,316.0578;Float;False;Property;_Color;Color;4;0;Create;True;0;0;False;0;0.5,0.5,0.5,1;0.5,0.5,0.5,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-1804.579,119.2214;Float;True;Property;_Noise;Noise;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;49;-781.927,777.129;Float;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1366.442,-10.46807;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1344.594,664.8295;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;82;-1149.587,659.351;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;84;-492.8427,703.0654;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;54;-1179.816,34.84627;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-636.2719,433.2454;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-346.6087,557.533;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-891.9798,234.1309;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;78;-121.3793,433.1614;Float;False;Property;_Usedepth;Use depth?;11;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-119.2192,570.4644;Float;False;Property;_Opacity;Opacity;7;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;79;-626.8267,175.5887;Float;False;Property;_Usecenterglow;Use center glow?;10;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;52;16.44016,286.3999;Float;False;Property;_Emission;Emission;3;0;Create;True;0;0;False;0;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;235.7081,235.5761;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;70;-107.6205,-52.2539;Float;True;Property;_NormalMap;Normal Map;8;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;262.643,402.9155;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;74;-2347.178,-236.1942;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-631.4565,-249.8404;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;72;-959.345,-129.9445;Float;False;0;70;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-385.8843,15.4308;Float;False;Property;_NormalScale;Normal Scale;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;77;462.3044,181.8964;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;76;462.3044,181.8964;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;75;464.2399,166.4125;Float;False;True;2;Float;;0;2;ERB/LWRP/Particles/Blend_Normals;1976390536c6c564abb90fe41f6ee334;True;Base;0;0;Base;11;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;;0;0;Standard;2;Vertex Position,InvertActionOnDeselection;1;Receive Shadows;0;1;_FinalColorxAlpha;0;4;True;True;True;True;False;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;80;464.2399,196.4125;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
WireConnection;22;0;15;3
WireConnection;22;1;15;4
WireConnection;21;0;15;1
WireConnection;21;1;15;2
WireConnection;24;0;21;0
WireConnection;24;1;17;2
WireConnection;23;0;17;2
WireConnection;23;1;22;0
WireConnection;58;0;33;0
WireConnection;81;0;69;0
WireConnection;36;0;69;2
WireConnection;27;0;23;0
WireConnection;27;1;81;0
WireConnection;37;0;58;0
WireConnection;37;1;36;0
WireConnection;26;0;24;0
WireConnection;26;1;29;0
WireConnection;83;0;37;0
WireConnection;13;1;26;0
WireConnection;14;1;27;0
WireConnection;49;0;50;0
WireConnection;30;0;13;0
WireConnection;30;1;14;0
WireConnection;30;2;31;0
WireConnection;30;3;32;0
WireConnection;39;0;58;0
WireConnection;39;1;83;0
WireConnection;82;0;39;0
WireConnection;84;0;49;0
WireConnection;54;0;30;0
WireConnection;60;0;13;4
WireConnection;60;1;14;4
WireConnection;60;2;31;4
WireConnection;60;3;32;4
WireConnection;48;0;60;0
WireConnection;48;1;84;0
WireConnection;41;0;54;0
WireConnection;41;1;82;0
WireConnection;78;0;60;0
WireConnection;78;1;48;0
WireConnection;79;0;54;0
WireConnection;79;1;41;0
WireConnection;51;0;79;0
WireConnection;51;1;52;0
WireConnection;70;1;73;0
WireConnection;70;5;71;0
WireConnection;61;0;78;0
WireConnection;61;1;62;0
WireConnection;74;0;24;0
WireConnection;73;0;74;0
WireConnection;73;1;72;0
WireConnection;75;0;79;0
WireConnection;75;1;70;0
WireConnection;75;2;51;0
WireConnection;75;6;61;0
ASEEND*/
//CHKSM=F8467DD33ACC56BD6326C86E1FF0A6F48158C046