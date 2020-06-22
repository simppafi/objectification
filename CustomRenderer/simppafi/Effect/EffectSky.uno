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
	public class EffectSky : simppafi.Effect.BaseEffect
	{

		public class FinalPassSkyBackground : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			PixelColor : FXGlobalPost;
		}

		public class FinalPassSkyFront : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;
			
			PixelColor : float4(prev.XYZ + FXGlobalPost.XYZ, 1f);
		}

		public EffectSky()
		{
			SkipPost = true;
			finalBackground = new FinalPassSkyBackground();
			finalFront 		= new FinalPassSkyFront();
			
			init();
		}

	}
}
