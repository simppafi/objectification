using Uno;
using Fuse.Drawing.Primitives;
using Fuse;
using Uno.Vector;
using Uno.Math;

namespace simppafi
{
	public class PostBilateralGauss : BasePost
	{
		public int Steps { get; set; }

		private int2 						size;
		private float2 						BLUR_RES;

		public PostBilateralGauss(int steps = 1)
		{
			Steps = steps;
		}

		override public void Process(Fuse.DrawContext dc, framebuffer source, framebuffer target)
		{
			var _size = source.Size;
			if(_size != size)
			{
				size = _size;
				BLUR_RES = float2((1.0f/size.X), (1.0f/size.Y));
			}

			var Blur = FramebufferPool.Lock(_size, Uno.Graphics.Format.RGBA8888, false);
			var Src = source;
			
			samplerState = Uno.Graphics.SamplerState.NearestWrap;
			
			
			if(Steps > 0)
			{
				var offsetX = float2(BLUR_RES.X, 0);// * .5f;
				var offsetY = float2(0, BLUR_RES.Y);// * .5f;

				var irisX = new [] {offsetX * 1.407333f, offsetX * -1.407333f, offsetX * 3.294215f, offsetX * -3.294215f};
				var irisY = new [] {offsetY * 1.407333f, offsetY * -1.407333f, offsetY * 3.294215f, offsetY * -3.294215f};

				float limit = 0.003f;

				for(var i = 0; i < Steps; i++)
				{
					dc.PushRenderTarget(Blur);
					dc.Clear(float4(0,0,0,0), 1);
					draw Quad
					{
						DepthTestEnabled: false;
						CullFace: Uno.Graphics.PolygonFace.None;
						float2 uv :	ClipPosition.XY * 0.5f + 0.5f;


						//float myd : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, uv, samplerState).ZW);
						
						float myd : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, uv, samplerState).ZW);
		
						//apply simppafi.RenderLibrary.FXDeferred;
						//float myd : simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

						float4 sum :
						{
							float4 res = sample(Src.ColorBuffer, uv, samplerState);
							
							int div = 1;
							for(var j = 0; j < 4; j++)
							{
								var	pt = uv + irisX[j];
								//var pxd = simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, pt, samplerState).ZW);
								var pxd = simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, pt, samplerState).ZW);
								
								var dst = Math.Abs(myd-pxd);

								if(dst < limit)
								{
									res += sample(Src.ColorBuffer, pt, samplerState);
									div++;
								}
								
								
							}
							return res/div;
						};

						PixelColor : sum;

					};
					dc.PopRenderTarget();

					
					dc.PushRenderTarget(Src);
					dc.Clear(float4(0,0,0,0), 1);
					draw Quad
					{
						DepthTestEnabled: false;
						CullFace: Uno.Graphics.PolygonFace.None;
						float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

						//float myd : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, uv, samplerState).ZW);
						float myd : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, uv, samplerState).ZW);
		
						float4 sum :
						{
							float4 res = sample(Blur.ColorBuffer, uv, samplerState);

							int div = 1;
							for(var j = 0; j < 4; j++)
							{
								var pt = uv + irisY[j];
								//var pxd = simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, pt, samplerState).ZW);
								var pxd = simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, pt, samplerState).ZW);
								var dst = Math.Abs(myd-pxd);

								if(dst < limit)
								{
									res += sample(Blur.ColorBuffer, pt, samplerState);
									div++;
								}
							}
							return res/div;
						};
						
						PixelColor : sum;


					};
					dc.PopRenderTarget();
				}
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
			
			FramebufferPool.Release(Blur);
			
			
		}

		
	}
}