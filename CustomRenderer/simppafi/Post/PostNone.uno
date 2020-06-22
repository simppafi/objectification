using Uno;
using Fuse;
using Uno.Vector;
using Uno.Math;
using Fuse.Drawing.Primitives;

namespace simppafi
{
	public class PostNone : BasePost
	{
		public PostNone()
		{
			
		}

		override public void Process(Fuse.DrawContext dc, framebuffer source, framebuffer target)
		{
           // /*
			dc.PushRenderTarget(target);
			dc.Clear(float4(0,0,0,0), 1.0f);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				PixelColor : sample(source.ColorBuffer, ClipPosition.XY * 0.5f + 0.5f, samplerState);
			};
			dc.PopRenderTarget();
           // */
            //target = source;
		}
	}
}