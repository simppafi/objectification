namespace simppafi
{
	public abstract class BasePost
	{
		public float4x4 			NearCorners;
		public float4x4 			FarCorners;

		public int2 				dcViewportSize;
		public float 				dcRatio;

		public float4x4 			InverseProjection;

		public abstract void Process(Fuse.DrawContext dc, 	framebuffer source, framebuffer target);
		protected Uno.Graphics.SamplerState	samplerState = Uno.Graphics.SamplerState.LinearWrap;//TrilinearClamp;
	}
}