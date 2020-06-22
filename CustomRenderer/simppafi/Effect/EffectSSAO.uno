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
	public class EffectSSAO : simppafi.Effect.BaseEffect
	{

		public class PostPassSSAOFront : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXSSAO;

			float ssao : FXSSAO;//*FXSSAO*FXSSAO;

			PixelColor : float4(ssao,ssao,ssao,1f);

			apply simppafi.RenderLibrary.FXMask;
		}

		public class FinalPassSSAOBackground : simppafi.BasePass
		{
			PixelColor : float4(0,0,0,1);
		}

		public class FinalPassSSAOFront : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;
			
			//float3 WorldLightPosition : simppafi.EnvShadow.lightPosition;
			
			float3 AmbientLightColor : float3(.4f);
			float3 DiffuseLightColor : float3(1f);
			float3 SpecularLightColor : float3(1f);
			float Shininess : 110f;

			//PixelColor : float4(prev.XYZ * FXGlobalPost.XYZ, 1f);
			PixelColor : float4(prev.XYZ - (1f-FXGlobalPost.XYZ), 1f);

			apply simppafi.ShadowApply;
		}

		public EffectSSAO()
		{
			Post = new simppafi.PostBilateralGauss(1);
			//Post = new simppafi.PostNone();
			//Post = new simppafi.PostGaussianBlur(1, 1f, 1f);

			postFront 		= new PostPassSSAOFront();
			finalBackground = new FinalPassSSAOBackground();
			finalFront 		= new FinalPassSSAOFront();

			init();
		}


	}
}
