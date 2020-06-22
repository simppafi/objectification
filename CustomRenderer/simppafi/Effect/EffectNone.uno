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
	public class EffectNone : simppafi.Effect.BaseEffect
	{

		public class FinalPassNoneBackground : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			PixelColor : FXGlobalPost;
		}

		public class FinalPassNoneFront : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			//float3 WorldLightPosition : simppafi.EnvShadow.lightPosition;

			float3 AmbientLightColor : float3(0f);
			float3 DiffuseLightColor : float3(1f);
			float3 SpecularLightColor : float3(1f);
			float Shininess : 110f;

			PixelColor : float4(prev.XYZ + FXGlobalPost.XYZ, 1);

			apply simppafi.ShadowApply;
		}

		public EffectNone()
		{
			SkipPost = true;
			
			finalBackground = new FinalPassNoneBackground();
			finalFront 		= new FinalPassNoneFront();
			
			init();
		}

	}
}
