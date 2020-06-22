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
	public class EffectFog : simppafi.Effect.BaseEffect
	{
		public class PostPassGlowFront : simppafi.BasePass
		{

			PixelColor : prev;

			apply simppafi.RenderLibrary.FXMask;
		}

		public class FinalPassGlowBackground : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			PixelColor : FXGlobalPost;

		}

		public class FinalPassGlowFront : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			PixelColor : float4(prev.XYZ + FXGlobalPost.XYZ, 1);

			apply simppafi.RenderLibrary.Fog;

			apply simppafi.ShadowApply;
		}

		public EffectFog()
		{
			Post = new simppafi.PostGaussianBlur(4, 1f);
			
			postFront 		= new PostPassGlowFront();
			finalBackground = new FinalPassGlowBackground();
			finalFront 		= new FinalPassGlowFront();

			init();
		}

	}
}
