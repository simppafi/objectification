using Fuse;

namespace simppafi.Utils
{
	public static class Size
	{
		public static int2 GetSize(float resolution, DrawContext dc)
		{
			return int2((int)( Uno.Math.Max(2, dc.RenderTarget.Size.X * resolution * simppafi.RenderPipeline.Resolution)), (int)( Uno.Math.Max(2, dc.RenderTarget.Size.Y * resolution * simppafi.RenderPipeline.Resolution)));
		}
	}
}