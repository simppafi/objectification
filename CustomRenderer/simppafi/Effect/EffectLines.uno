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
	public class EffectLines : simppafi.Effect.BaseEffect
	{

		public class PostPassLinesFront : simppafi.BasePass
		{
			float2 TexCoord : pixel prev;

			//TexCoord : 
			//	req(UVStart as float2)
			//		(prev * .5f) + UVStart;

			//float3 _texture : sample(TextureMap, TexCoord, Uno.Graphics.SamplerState.TrilinearWrap).XYZ;

			//PixelColor : float4(prev.XYZ * _texture, 1);

			PixelColor : prev;

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

			//float4 Metal :
			//	req(ReflectedViewDirection as float3)
			//		sample(CubeMap, ReflectedViewDirection, Uno.Graphics.SamplerState.LinearClamp);

			PixelColor : float4(prev.XYZ + FXGlobalPost.XYZ, 1f);

			apply simppafi.ShadowApply;
			
		}

		public EffectLines(float4 color = float4(1,1,1,1))
		{
			Post = new simppafi.PostFindEdges(1f, 1f, color);

			postFront 		= new PostPassLinesFront();
			finalBackground = new FinalPassLinesBackground();
			finalFront 		= new FinalPassLinesFront();

			init();
		}
	}
}
