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
	public class EffectTransparency : simppafi.Effect.BaseEffect
	{

		public class FinalPassTransparencyBackground : simppafi.BasePass
		{
			PixelColor : float4(0,0,0,0);
		}

		public class FinalPassTransparencyFront : simppafi.BasePass
		{
			//apply simppafi.RenderLibrary.FXGlobalPost;

			//float3 WorldLightPosition : simppafi.EnvShadow.lightPosition;

			//float3 AmbientLightColor : float3(0f);
			//float3 DiffuseLightColor : float3(1f);
			//float3 SpecularLightColor : float3(1f);
			//float Shininess : 110f;

			//float LinearDepth : pixel prev;
			//PixelColor : float4(LinearDepth, 1, 1, 1);//prev.XYZ, LinearDepth);//float4(prev.XYZ + FXGlobalPost.XYZ, 1);

			apply simppafi.RenderLibrary.FXDeferred;
			float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

			float LinearDepth : pixel prev;

			float cut : Math.Round(((_depth - LinearDepth) + 1f) * .5f);

			PixelColor : prev * cut;
			//apply simppafi.ShadowApply;
		}

		public EffectTransparency()
		{
			SkipPost = true;
			
			finalBackground = new FinalPassTransparencyBackground();
			finalFront 		= new FinalPassTransparencyFront();
			
			init();
		}

	}
}
