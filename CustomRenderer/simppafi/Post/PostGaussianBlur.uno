using Uno;
using Fuse.Drawing.Primitives;
using Fuse;
using Uno.Vector;
using Uno.Math;

namespace simppafi
{
	public class PostGaussianBlur : BasePost
	{
		public int Steps { get; set; }

		private int2 						size;

		private float2 						BLUR_RES;
		private float 						Stretch;
		private float 						Resolution;

		public PostGaussianBlur(int steps = 8, float stretch = 1f, float resolution = 1f)
		{
			Steps = steps;
			Stretch = stretch;
			Resolution = resolution;
		}

		override public void Process(Fuse.DrawContext dc, 	framebuffer source, framebuffer target)
		{

			var _size = source.Size;
			if(_size != size)
			{
				size = _size;
				BLUR_RES = float2((1.0f/size.X), (1.0f/size.Y)) * Stretch;
			}

			if(Resolution < 1f)
			{
				_size = int2((int)(_size.X * Resolution), (int)(_size.Y * Resolution));
				BLUR_RES = float2((1.0f/size.X), (1.0f/size.Y)) * Stretch;
			}

			var Src = FramebufferPool.Lock(_size, Uno.Graphics.Format.RGBA8888, true);
			var Blur = FramebufferPool.Lock(_size, Uno.Graphics.Format.RGBA8888, true);

			dc.PushRenderTarget(Src);
			dc.Clear(float4(0,0,0,0), 1.0f);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				PixelColor : sample(source.ColorBuffer, ClipPosition.XY * 0.5f + 0.5f, samplerState);
			};
			dc.PopRenderTarget();


			var offsetX = float2(BLUR_RES.X, 0);
			var offsetY = float2(0, BLUR_RES.Y);
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(Blur);
				dc.Clear(float4(0,0,0,0), 1);
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
					float4 sum : sample(Src.ColorBuffer, uv, samplerState) * 0.204164f;
					sum : prev + sample(Src.ColorBuffer, uv + offsetX * 1.407333f, samplerState) * 0.304005f;
					sum : prev + sample(Src.ColorBuffer, uv - offsetX * 1.407333f, samplerState) * 0.304005f;
					sum : prev + sample(Src.ColorBuffer, uv + offsetX * 3.294215f, samplerState) * 0.093913f;
					PixelColor : sum + sample(Src.ColorBuffer, uv - offsetX * 3.294215f, samplerState) * 0.093913f;
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(Src);
				dc.Clear(float4(0,0,0,0), 1);
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
					float4 sum : sample(Blur.ColorBuffer, uv, samplerState) * 0.204164f;
					sum : prev + sample(Blur.ColorBuffer, uv + offsetY * 1.407333f, samplerState) * 0.304005f;
					sum : prev + sample(Blur.ColorBuffer, uv - offsetY * 1.407333f, samplerState) * 0.304005f;
					sum : prev + sample(Blur.ColorBuffer, uv + offsetY * 3.294215f, samplerState) * 0.093913f;
					PixelColor : sum + sample(Blur.ColorBuffer, uv - offsetY * 3.294215f, samplerState) * 0.093913f;
				};
				dc.PopRenderTarget();
			}


			dc.PushRenderTarget(target);
			dc.Clear(float4(0,0,0,0), 1.0f);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				PixelColor : sample(Src.ColorBuffer, ClipPosition.XY * 0.5f + 0.5f, samplerState);
			};
			dc.PopRenderTarget();

			FramebufferPool.Release(Src);
			FramebufferPool.Release(Blur);

		}
	}
}