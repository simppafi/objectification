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
	public class EffectRadial : BaseEffect
	{
		public class PostPassRadialFront : simppafi.BasePass
		{
			PixelColor : prev;
			apply simppafi.RenderLibrary.FXMask;
		}

		public class FinalPassRadialBackground : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			PixelColor : FXGlobalPost;

		}

		public class FinalPassRadialFront : simppafi.BasePass
		{
			apply simppafi.RenderLibrary.FXGlobalPost;

			PixelColor : float4(prev.XYZ + FXGlobalPost.XYZ*2f, 1);

			apply simppafi.ShadowApply;
		}

		public EffectRadial()
		{
			Post = new simppafi.PostRadialRemi();

			//(Post as simppafi.PostRadialRemi).Zoom = .9887f;//.9927f;
            //(Post as simppafi.PostRadialRemi).Blend = .96f;
            //(Post as simppafi.PostRadialRemi).Passes = 4;
            
            (Post as simppafi.PostRadialRemi).Brightness = 2.0f;

			postFront 		= new PostPassRadialFront();
			finalBackground = new FinalPassRadialBackground();
			finalFront 		= new FinalPassRadialFront();
			
			init();
		}

	}
}
