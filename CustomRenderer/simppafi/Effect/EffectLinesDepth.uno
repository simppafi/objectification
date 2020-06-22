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
	public class EffectLinesDepth : simppafi.Effect.BaseEffect
	{

		public class PostPassLinesFront : simppafi.BasePass
		{
			float LinearDepth : pixel prev;
			
			float wave : 
				req(WorldPosition as float3)
					Math.Round(.5f + Math.Cos(LinearDepth * 10000f + (float)Fuse.Time.FrameTime * 6f ) * .5f) * .15f;

			PixelColor : float4(float3(wave), 1);

			apply simppafi.RenderLibrary.FXMask;
		}
		

		public class FinalPassLinesBackground : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			PixelColor : FXGlobalPost;
		}

		public class FinalPassLinesFront : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			//float3 WorldLightPosition : simppafi.EnvShadow.lightPosition;
			
			//float4 Metal :
			//	req(ReflectedViewDirection as float3)
			//		sample(CubeMap, ReflectedViewDirection, Uno.Graphics.SamplerState.LinearClamp);

			PixelColor : float4(prev.XYZ+ FXGlobalPost.XYZ, 1f);

			apply simppafi.ShadowApply;
			
		}

		public EffectLinesDepth(float4 color = float4(1,1,1,1))
		{
			//float spread = 1f, float strength = .5f, float4 color = float4(1,1,1,1))
			Post = new simppafi.PostFindEdges(1f, .75f, color);
			//Post = new simppafi.PostGaussianBlur(1, 1f);
			//Post = new simppafi.PostNone();
			//SkipMask = true;

			postFront 		= new PostPassLinesFront();
			finalBackground = new FinalPassLinesBackground();
			finalFront 		= new FinalPassLinesFront();

			init();
		}
	}
}
