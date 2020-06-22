using Uno.Graphics;
using Uno.Collections;
using OpenGL;
using Fuse.Drawing.Primitives;

namespace simppafi
{
	public class TexturePixelProvider
	{
		public bool IsSetup = false; 

		public static List<byte[]>		ImageBytes;
		public static List<int2>		ImageSizes;

		public static Texture2D 		Perlin1 = import Texture2D("../Assets/perlin1.png");
		public static Texture2D 		Perlin2 = import Texture2D("../Assets/perlin2.png");
		public static Texture2D 		Perlin3 = import Texture2D("../Assets/perlin3.png");
		
		public TexturePixelProvider()
		{
			
		}

		public void Setup(Fuse.DrawContext dc)
		{
			ImageBytes = new List<byte[]>();
			ImageSizes = new List<int2>();
				
			ImageBytes.Add(CreateByteArrayFromImage(Perlin1, dc));
			ImageBytes.Add(CreateByteArrayFromImage(Perlin2, dc));
			ImageBytes.Add(CreateByteArrayFromImage(Perlin3, dc));
			
			IsSetup = true;
		}

		private byte[] CreateByteArrayFromImage(texture2D img, Fuse.DrawContext dc)
		{
			var imageSize = img.Size;
			ImageSizes.Add(imageSize);

			var dummy = Fuse.FramebufferPool.Lock(imageSize, Uno.Graphics.Format.RGBA8888, false);

			dc.PushRenderTarget(dummy);
			dc.Clear(float4(0,0,0,1), 1.0f);

			draw Quad
			{
				float2 px : pixel ClipPosition.XY / ClipPosition.W * 0.5f + 0.5f;
				PixelColor : sample(img, px, Uno.Graphics.SamplerState.LinearClamp);// * .5f;
			};

			var bytes = new byte[imageSize.X*imageSize.Y*4];
			GL.ReadPixels(0, 0, imageSize.X, imageSize.Y, GLPixelFormat.Rgba, GLPixelType.UnsignedByte, bytes);

			dc.PopRenderTarget();

			Fuse.FramebufferPool.Release(dummy);

			return bytes;
		}

	}
}
