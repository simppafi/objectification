using Uno;

namespace simppafi
{
	public class SSRPass : BasePass
	{
		
		apply simppafi.RenderLibrary.FXDeferred;

		apply simppafi.RenderLibrary.ValuePixelOnScreen;

		float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

		float3 _position : simppafi.Utils.BufferData.ToViewSpace(float3(ValuePixelOnScreen, _depth), NearCorners, FarCorners);

		float3 _normal : simppafi.Utils.BufferPacker.UnpackNormal(FXDeferred.XY);

		float4x4 _projection : BasePass.Projection;
		float _ZNear: BasePass.ZNear;
		float _ZFar: BasePass.ZFar;

		float3 CamDir : Vector.Normalize(_position);

		float max_ray_length : 16f;
		int maxSteps : (int)(max_ray_length*max_ray_length);
		float2 size : float2(simppafi.FramebufferStorage.GlobalSSRBuffer.Size.X, simppafi.FramebufferStorage.GlobalSSRBuffer.Size.Y);

		
		//float x : Uno.Math.Sin(Uno.Vector.Dot(ValuePixelOnScreen, float2(12.9898f,78.233f))) * 43758.5453f;
		//float noise : (-.5f + (x - Uno.Math.Floor(x)) * 2f) * .005f;

		//apply simppafi.RenderLibrary.MRAO;

		float4 ReflectPixel : 
		{
			float4 res = float4(0);

			
			var r_angle = Uno.Vector.Reflect(CamDir, _normal);//*(1f+roughness));
			var r_goal = _position + r_angle * max_ray_length;
			

			//return float4(_normal, 0);

			// FACING CAMERA
			var face = 1f - Math.SmoothStep(0.25f, 0.5f, Vector.Dot(-CamDir, r_angle));
		    if (face <= 0)
			{
				return res;
			}

			float4 pxCoord_start = Uno.Vector.Transform(float4(_position,1), _projection);
			float2 pxTC_start = (pxCoord_start.XY / pxCoord_start.W) * 0.5f + 0.5f; 

			float4 pxCoord_goal = Uno.Vector.Transform(float4(r_goal,1), _projection);
			float2 pxTC_goal = (pxCoord_goal.XY / pxCoord_goal.W) * 0.5f + 0.5f; 

			var rayLength = Vector.Length(pxTC_start-pxTC_goal);
			

			var dx = (pxTC_goal.X - pxTC_start.X);
			var dy = (pxTC_goal.Y - pxTC_start.Y);

			var adx = Math.Abs(dx);
			var ady = Math.Abs(dy);
			
			int Steps = (adx > ady) ? (int)(adx*size.X) : (int)(ady*size.Y);

			Steps = Steps > maxSteps ? maxSteps : Steps;

			float2 increment = float2(dx,dy) / (float)Steps;
			
			float fade = 1f;
			float2 line_px = pxTC_start;
			//float bluenoise = sample(import Uno.Graphics.Texture2D("../../Assets/bluenoise/512_512/LDR_RGBA_0.png"), ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).X * .1f;
			for(int i=0; i < Steps; i++)
			{
				// MAKE INCREMENT LARGER AT DEPTH
				var div = ((float)i/(float)Steps);// + bluenoise;
				//var exp = 1f;// + div*div*2f;
				var mv = increment * i;// * exp;
			    line_px = pxTC_start + mv;
			    
			    var rayMove = Vector.Length(mv) / rayLength;

			    
				var px_pos = _position + (r_goal - _position) * rayMove;

				float4 ray = Uno.Vector.Transform(float4(px_pos,1), _projection);
				float2 rayPX = (ray.XY / ray.W) * 0.5f + 0.5f; 

				//rayPX += float2(noise) * div;

				// OUTSIDE OF VIEWPORT
			    var UVSamplingAttenuation = Math.SmoothStep(0.05f, 0.1f, rayPX) * (1f - Math.SmoothStep(0.95f, 1f, rayPX));
				UVSamplingAttenuation.X *= UVSamplingAttenuation.Y;

				if (UVSamplingAttenuation.X < 0f)
				{
					break;
				}
				

				var px_depth = simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, rayPX, Uno.Graphics.SamplerState.LinearWrap).ZW);

				var px_ray_depth = (-px_pos.Z - _ZNear) / (_ZFar - _ZNear);
				
				//return float4(px_ray_depth, px_ray_depth, px_ray_depth, 1f);

				float weight = simppafi.Utils.BufferPacker.UnpackFloat16(sample(simppafi.FramebufferStorage.GlobalWeightBuffer.ColorBuffer, rayPX, Uno.Graphics.SamplerState.LinearWrap).XY);
				float pxFat = (weight-px_depth);

				var lp = px_ray_depth - px_depth;

				if(lp > 0f)
				{

					if(lp < pxFat)
					{

						//var gup = 1f-Math.SmoothStep(limit, pxFat, lp);

						 
						fade = (1f-div) * face * UVSamplingAttenuation.X;// * gup;

						//float4 pxCoord = Uno.Vector.Transform(float4(px_pos,1), _projection);
						//float2 pxTC = (pxCoord.XY / pxCoord.W) * 0.5f + 0.5f; 

						//float x = Uno.Math.Sin(Uno.Vector.Dot(pxTC, float2(12.9898f,78.233f))) * 43758.5453f;
						//float noise = -.5f + (x - Uno.Math.Floor(x)) * 2f;
						//pxTC += float2(noise, noise) * (1f-fade) * .01f;


						float4 glow = sample(simppafi.FramebufferStorage.GlobalGlowBuffer.ColorBuffer, rayPX, Uno.Graphics.SamplerState.LinearWrap);
						float4 albedo = sample(simppafi.FramebufferStorage.GlobalAlbedoBuffer.ColorBuffer, rayPX, Uno.Graphics.SamplerState.LinearWrap);
						res = float4((sample(FramebufferStorage.GlobalDeferredFinalBuffer.ColorBuffer, rayPX, Uno.Graphics.SamplerState.LinearWrap).XYZ * albedo.XYZ + glow.XYZ ) * fade , 1f-fade);
						
						//res = float4(sample(simppafi.RenderPipeline.PostFullFrame.ColorBuffer, rayPX, Uno.Graphics.SamplerState.LinearWrap).XYZ * fade, 1f-fade);
						break;
					}
				}
				
			}
			return res;
		};

		PixelColor : ReflectPixel;

	}
}