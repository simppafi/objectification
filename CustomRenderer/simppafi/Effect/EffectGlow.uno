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
	public class EffectGlow : simppafi.Effect.BaseEffect
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

			apply simppafi.ShadowApply;
		}

		public EffectGlow()
		{
			Post = new simppafi.PostGaussianBlur(4, 1f);
			
			postFront 		= new PostPassGlowFront();
			finalBackground = new FinalPassGlowBackground();
			finalFront 		= new FinalPassGlowFront();

			init();
		}

	}
}
