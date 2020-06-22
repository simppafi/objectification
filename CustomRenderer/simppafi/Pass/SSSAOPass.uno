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

namespace simppafi
{
	public class SSSAOPass : BasePass
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

		//float3 _lightVector : _lightPosition - _position;
		//float attenuation : 1f - (Uno.Math.Saturate(1.0f - Uno.Vector.Length(_lightVector)/_lightRadius) * _lightPower);
		//attenuation : prev * prev;


		
		float Multiplier 		: 2.65f;
		float Exponent 			: 18.0f;
		float Bias				: 0.01f;
		float Eps 				: 0.01f;
		float _Radius 			: 12.0f;
		float MaxScreenRadius 	: 0.1f;
		float RandomizationFactor : .5f;
		float2 ScreenCoord : ValuePixelOnScreen;
		float2 ScreenSize : float2(simppafi.FramebufferStorage.GlobalSSSAOBuffer.Size.X, simppafi.FramebufferStorage.GlobalSSSAOBuffer.Size.Y);

		apply simppafi.RenderLibrary.NearCorners;
		apply simppafi.RenderLibrary.FarCorners;
		
		float2 PixelCoord2 : ScreenCoord * ScreenSize;

		float ScreenRadius : Math.Min(MaxScreenRadius, _Radius / -_position.Z);

		
		float angularOffset : RandomizationFactor * Dot(PixelCoord2, float2(2.3734372915f, 3.58540627421f));
		float2 AspectScale : float2(1.0f, BasePass.dcRatio);

		///*
		//SSS
		float4x4 _projection : Projection;
		float _ZNear: ZNear;
		float _ZFar: ZFar;
		
		float SSS : 
		{
			
			var steps = 32;
			float res = 0f;
			
			float3 PrevPxPos = float3(0,0,0);
			float bluenoise = sample(import Texture2D("../../Assets/bluenoise/1024_1024/LDR_RGBA_0.png"), ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).X * .1f;
			for(var i = 0; i < steps; i++)
			{
				var div = ((float)i/(float)steps) + bluenoise;
				div = div*div;
				
				var px_pos = _position + (_lightPosition - _position) * div;
				
				// CONFIRMED TO BE CORRECT PIXEL IN COORDINATE
				float4 pxCoord = Uno.Vector.Transform(float4(px_pos,1), _projection);
				float2 pxTC = (pxCoord.XY / pxCoord.W) * 0.5f + 0.5f; 

				if(pxTC.X > 1f || pxTC.X < 0f || pxTC.Y > 1f || pxTC.Y < 0f)
				{
					break;
				}

				float px_depth = simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, pxTC, Uno.Graphics.SamplerState.LinearWrap).ZW);
				
				// CONFIRMED TO BE CORRECT
				float px_ray_depth = (-px_pos.Z - _ZNear) / (_ZFar - _ZNear);

				float weight = simppafi.Utils.BufferPacker.UnpackFloat16(sample(simppafi.FramebufferStorage.GlobalWeightBuffer.ColorBuffer, pxTC, Uno.Graphics.SamplerState.LinearWrap).XY);
				float fat = (weight-px_depth)+.003f;

				var lp = px_ray_depth - px_depth;
				var limit = 0;
				if(lp > limit)
				{
					if(lp < fat)
					{
						res = .5f-div*.5f;
						//res = 1f-div;
						break;
					}
				}

			}

			return res;
		};
		
		PixelColor : float4(SSS,SSS,SSS,1);
		// END OF SSS
		//*/


		/*
		//SSAO
		float FXSSAO :
		{
			const float oneOverSampleCount = 1.0f / 9.0f;
			const float twoOverSampleCount = oneOverSampleCount * 2.0f;

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

		FXSSAO : (1f-prev);// * .5f;

		PixelColor : prev + 
		 float4(FXSSAO,FXSSAO,FXSSAO,1f);
		// END OF SSAO
		//*/
		
		///*
		float3 _lightVector : _lightPosition - _position;
	    float attenuation : Uno.Math.Saturate( (1.0f - Uno.Vector.Length(_lightVector)/_lightRadius) * 10f );
	    PixelColor : prev * attenuation;


		WriteDepth: false;
	    DepthTestEnabled: false;
		CullFace: Uno.Graphics.PolygonFace.Front;
		BlendSrc: Uno.Graphics.BlendOperand.One;
		BlendDst: Uno.Graphics.BlendOperand.One;
		BlendEnabled: true;
		//*/

		//WriteDepth: false;
	   // DepthTestEnabled: false;
	}
}