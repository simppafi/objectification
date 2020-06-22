using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Uno.Content;
using Uno.Content.Models;
using Fuse.Drawing.Primitives;
using Fuse.Entities;
using Uno.Math;
using Uno.Vector;

namespace simppafi.Effect
{
	public class EffectDeferred : simppafi.Effect.BaseEffect
	{

		public class PostPassDeferredFront : simppafi.BasePass
		{
			float3x3 TangentToView :
				req(ViewTangent as float3)
				req(ViewBinormal as float3)
				req(ViewNormal as float3)
					float3x3(ViewTangent, ViewBinormal, ViewNormal);

			float3 PerPixelViewNormal :
				req (TangentNormal as float3)
					Uno.Vector.Transform(TangentNormal, TangentToView),
				req(ViewNormal as float3)
					ViewNormal;
			
			float LinearDepth : pixel prev;
			PixelColor : simppafi.Utils.BufferPacker.PackNormalDepth(pixel PerPixelViewNormal, LinearDepth);
		}


		public class FinalPassDeferredBackground : simppafi.BasePass
		{
			PixelColor : float4(0,0,0,1);
		}

		public class FinalPassDeferredFront : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXDeferred;

			apply simppafi.RenderLibrary.ValuePixelOnScreen;

			float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);
			
			float3 _position : simppafi.Utils.BufferData.ToViewSpace(float3(ValuePixelOnScreen, _depth), NearCorners, FarCorners);

			float3 _normal : simppafi.Utils.BufferPacker.UnpackNormal(FXDeferred.XY);

			float _lightRadius :
				req(LightRadius as float)
					LightRadius, 100f;

			float3 _lightPosition :
				req(LightPosition as float3)
					LightPosition, float3(0,0,0);

			float3 _lightColor :
				req(LightColor as float3)
					LightColor, float3(1,1,1);

			float _lightPower :
				req(LightPower as float)
					LightPower, 1f;

			_lightPosition :
				req(WorldView as float4x4)
					Uno.Vector.Transform(prev, WorldView).XYZ;


			apply simppafi.RenderLibrary.MRAO;
			float3 albedo : sample(simppafi.FramebufferStorage.GlobalAlbedoBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			
			

			float3 N : Vector.Normalize(_normal);
    		float3 V : 
    			req(CameraPosition as float3)
    				Vector.Normalize(CameraPosition - _position);

    		float3 F0 : float3(0.04f); 
    		//F0 : Math.Mix(prev, albedo, metallic);
    		//x Start, y end, a value;
    		//x×(1−a)+y×a 
    		F0 : prev * (1f-metallic) + albedo*metallic;

    		float3 Lo : float3(0f);
    		//{
    		// calculate per-light radiance
	        float3 L : Vector.Normalize(_lightPosition - _position);
	        float3 H : Vector.Normalize(V + L);
	        
	        //float distance    : Vector.Length(_lightPosition - _position);
	        //float attenuation : (1.0f / (distance * distance));// * 100f;
	        float3 _lightVector : _lightPosition - _position;
	        float attenuation : Uno.Math.Saturate( (1.0f - Uno.Vector.Length(_lightVector)/_lightRadius) * _lightPower );// * _lightPower;
			//float attenuation : Uno.Math.Saturate(1.0f - Uno.Vector.Length(_lightVector)/_lightRadius) * _lightPower;
			attenuation : Math.Min(1f, prev * prev * 2f);

			
	        
	        float3 radiance   : _lightColor * attenuation;   

	        // cook-torrance brdf
	        //float NDF : DistributionGGX(N, H, roughness);     
	        float NDF :
	        {
	        	float a      = roughness*roughness;
			    float a2     = a*a;
			    float NdotH  = Math.Max(Vector.Dot(N, H), 0.0f);
			    float NdotH2 = NdotH*NdotH;
				
			    float nom   = a2;
			    float denom = (NdotH2 * (a2 - 1.0f) + 1.0f);
			    denom = Math.PIf * denom * denom;
				
			    return nom / denom;
	        };
	        

	        //float G   : GeometrySmith(N, V, L, roughness); 
	        // GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
	        float G : 
	        {
	        	float NdotV = Math.Max(Vector.Dot(N, V), 0.0f);
			    float NdotL = Math.Max(Vector.Dot(N, L), 0.0f);

			    //float ggx2  = GeometrySchlickGGX(NdotV, roughness);
			    
			    float r = (roughness + 1.0f);
			    float k = (r*r) / 8.0f;

			    float nom2   = NdotV;
			    float denom2 = NdotV * (1.0f - k) + k;
				
			    float ggx2  =  nom2 / denom2;


			    //float ggx1  = GeometrySchlickGGX(NdotL, roughness);
			    float nom1   = NdotL;
			    float denom1 = NdotL * (1.0f - k) + k;
				
			    float ggx1  =  nom1 / denom1;

				
			    return ggx1 * ggx2;
	        };

	        //float3 F  : fresnelSchlick(max(dot(H, V), 0.0), F0); 
	        //vec3 fresnelSchlick(float cosTheta, vec3 F0)
			//{
			//    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
			//}  
			float cosTheta : Math.Max(Vector.Dot(H, V), 0.0f);
			float3 F : F0 + (1.0f - F0) * Math.Pow(1.0f - cosTheta, 5.0f);


			float3 kS : F;
	        float3 kD : float3(1.0f) - kS;
	        //kD *= 1.0f - metallic;
	        kD : prev * (1.0f - metallic);

	        float3 nominator  : NDF * G * F;
	        float denominator : 4f * Math.Max(Vector.Dot(N, V), 0.0f) * Math.Max(Vector.Dot(N, L), 0.0f) + 0.001f; 
	        float3 brdf : nominator / denominator;

	        float NdotL : Math.Max(Vector.Dot(N, L), 0.0f);                
        	//Lo += (kD * albedo / PI + brdf) * radiance * NdotL; 
        	Lo : (kD * albedo / Math.PIf + brdf) * radiance * NdotL; 
        	//}


        	// REFLECTION
        	float3 CamDir : Vector.Normalize(_position);
        	float3 r_angle : Uno.Vector.Reflect(CamDir, _normal);
        	float3 Reflecti : sample(import Uno.Graphics.TextureCube("../../Assets/cubemap3_burn.jpg"), r_angle*roughness, Uno.Graphics.SamplerState.LinearClamp).XYZ * metallic * albedo;

        	Lo : prev + Reflecti * radiance;

        	float3 color : Lo*ao;
			
		    color : prev / (prev + float3(1.0f));
		    color : Math.Pow(prev, float3(1.0f/2.2f));  

		    PixelColor : float4(color,1f);
			
			//*/

	        //PixelColor : float4(_uv, 1,1);

			/*

			float3 _lightVector : _lightPosition - _position;

			float attenuation : Uno.Math.Saturate(1.0f - Uno.Vector.Length(_lightVector)/_lightRadius);

			float3 _lightDir : Vector.Normalize(_lightVector);

			float3 _eyeDir :
				req(CameraPosition as float3)
					Vector.Normalize(CameraPosition-_position);

			float3 _vHalfVector : Vector.Normalize(_lightDir+_eyeDir);



			PixelColor : float4(		float3(Vector.Dot(_normal,_lightDir)) +
		                				Math.Pow(Vector.Dot(_normal,_vHalfVector), 100f) * 8f
										,1);

			PixelColor : float4(attenuation * prev.XYZ * _lightColor * _lightPower, 1f);
			
			*/
			
			//PixelColor : float4(		float3(Math.Max(0, Vector.Dot(_normal,_lightDir))) +
		    //             				Math.Max(0, Math.Pow(Vector.Dot(_normal,_vHalfVector), 100f) * 8f)
			//							, 1);
			//PixelColor : float4(		float3(Math.Max(0, Vector.Dot(_normal,_lightDir))) +
		    //             				Math.Max(0, Math.Pow(Vector.Dot(_normal,_vHalfVector), 100f) * 1.5f)
			//							+ Ambient
			//							, 1);
			
			//PixelColor : float4(		float3(Math.Max(0, Vector.Dot(_normal,_lightDir))) +
		    //             				Math.Max(0, Math.Pow(Vector.Dot(_normal,_vHalfVector), 100f)) // + Ambient
			//							, 1);

			//PixelColor : float4(		float3(Vector.Dot(_normal,_lightDir)) +
		   //             				Math.Pow(Vector.Dot(_normal,_vHalfVector), 100f) 
			//							,1);

			
			//PixelColor : float4(attenuation * prev.XYZ * _texture * Reflect.XYZ * _lightColor * _lightPower, 1f);

			//PixelColor : float4(attenuation * prev.XYZ * _texture * Reflect.XYZ * _lightColor * _lightPower, 1f);

			//float4 silhuette : sample(FramebufferStorage.GlobalSilhuetteBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
			//PixelColor : prev + silhuette;	

			
			//PixelColor : float4(Math.Min(1f,prev.X),Math.Min(1f,prev.Y),Math.Min(1f,prev.Z),1f);

			//PixelColor : float4(Math.Min(1f, prev.X), Math.Min(1f, prev.Y), Math.Min(1f, prev.Z), 1f);
			


			// MATERIAL
			//float4 material : sample(simppafi.FramebufferStorage.GlobalMaterialBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
			//PixelColor : float4(prev.XYZ * material.XYZ, 1f);

			// LIGHT SOURCES TO REFLECTION
			//float4 lightSources : sample(simppafi.FramebufferStorage.GlobalLightSourcesBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
			//PixelColor : float4(prev.XYZ + lightSources.XYZ*2f, 1f);
			
			
			//PixelColor : float4(_normal, 1);

			
			//float2 ScreenCoord : ValuePixelOnScreen;
			//float2 ScreenSize : float2(BasePass.dcViewportSize.X, BasePass.dcViewportSize.Y);
			
			/*
			//SSS
			float4x4 _projection : Projection;
			float _ZNear: ZNear;
			float _ZFar: ZFar;
			
			float2 size : simppafi.FramebufferStorage.GlobalDeferredFinalBuffer.Size;

			float2 PixelCoord2 : ScreenCoord * ScreenSize;

			float distanceToLight : Vector.Length(_position - _lightPosition) / _lightRadius;
			
			float2 pxSize : float2((1.0f/size.X), (1.0f/size.Y));
			float SSS : 
			{
				//var steps = 22;
				//var steps = (int)Math.Max(10f, (Vector.LengthSquared(_position - _lightPosition) * 0.001f));
				//var steps = (int)Math.Max(15f, (1f-attenuation) * 30f);
				var steps = (int) Math.Min(40f, (Vector.Length(_position - _lightPosition) * .25f) );

				float res = 1f;
				
				float x = Uno.Math.Sin(Uno.Vector.Dot(ScreenCoord, float2(12.9898f,78.233f))) * 43758.5453f;
				float noise = -.5f + (x - Uno.Math.Floor(x)) * 2f;

				for(var i = 0; i < steps; i++)
				{
					var div = (float)i/(float)steps;

					var px_pos = _position + (_lightPosition - _position) * div;
					
					// CONFIRMED TO BE CORRECT PIXEL IN COORDINATE
					float4 pxCoord = Uno.Vector.Transform(float4(px_pos,1), _projection);
					float2 pxTC = (pxCoord.XY / pxCoord.W) * 0.5f + 0.5f; 

					if(pxTC.X > 1f || pxTC.X < 0f || pxTC.Y > 1f || pxTC.Y < 0f)
					{
						break;
					}
					
					//float2 sampleCoord = pxTC + (noise * pxSize * 12f * div*div);
					float2 sampleCoord = pxTC;

					float px_depth = simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, sampleCoord, Uno.Graphics.SamplerState.LinearWrap).ZW);
					
					// CONFIRMED TO BE CORRECT
					float px_ray_depth = (-px_pos.Z - _ZNear) / (_ZFar - _ZNear);
					
					if( (px_ray_depth - px_depth) > .001f) //.001f
					{
						res = div;
						break;
					}

				}

				return res;
			};
			
			PixelColor : prev * SSS;
			// END OF SSS
			//*/


			/*
			//SSAO
			float Multiplier 		: 2.65f;
			float Exponent 			: 18.0f;
			float Bias				: 0.01f;
			float Eps 				: 0.01f;
			float _Radius 			: 12.0f;
			float MaxScreenRadius 	: 0.1f;
			float RandomizationFactor : .5f;
			
			apply simppafi.RenderLibrary.NearCorners;
			apply simppafi.RenderLibrary.FarCorners;
			
			float2 PixelCoord2 : ScreenCoord * ScreenSize;
			float2 AspectScale : float2(1.0f, BasePass.dcRatio);

			float ScreenRadius : Math.Min(MaxScreenRadius, _Radius / -_position.Z);

			float FXSSAO :
			{
				const float oneOverSampleCount = 1.0f / 9.0f;
				const float twoOverSampleCount = oneOverSampleCount * 2.0f;

	       		float angularOffset = RandomizationFactor * Dot(PixelCoord2, float2(2.3734372915f, 3.58540627421f));

				float ao = 0.0f;
				for (int i = 0; i<9; i++)
				{
					float alpha = oneOverSampleCount * ((float)i + 0.5f);
					float theta = 2.0f * Math.PIf * alpha + angularOffset;
					var dir = float2(Cos(theta), Sin(theta));
					float2 spiral = dir * alpha;
					float2 sampleCoord = ScreenCoord + (spiral * ScreenRadius) * AspectScale;

					float4 data = sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, sampleCoord, Uno.Graphics.SamplerState.LinearWrap);

					float3 viewSample =  simppafi.Utils.BufferData.ReadViewPosition(data, sampleCoord, NearCorners, FarCorners);
					float3 v_i = (viewSample - _position);
					float3 n = _normal;
					ao += Max(0, Dot((v_i), n) + _position.Z * Bias)
						  / ((Dot(v_i, v_i) + Eps));
				}
				ao *= twoOverSampleCount * Multiplier;
				return Pow(Max(0, 1.0f - ao), Exponent);
			};

			PixelColor : prev * float4(FXSSAO,FXSSAO,FXSSAO,1f);
			// END OF SSAO
			//*/
			



			WriteDepth: false;
		    DepthTestEnabled: false;
			CullFace: Uno.Graphics.PolygonFace.Front;
			BlendSrc: Uno.Graphics.BlendOperand.One;
			BlendDst: Uno.Graphics.BlendOperand.One;
			BlendEnabled: true;

		}

		public EffectDeferred()
		{
			postBackground = postFront		= new PostPassDeferredFront();
			finalBackground = finalFront 	= new FinalPassDeferredFront();

			init();
		}

	}
}
