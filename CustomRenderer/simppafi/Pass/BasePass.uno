using Uno.Vector;
namespace simppafi
{
	public class BasePass
	{
		public framebuffer				PostFramebuffer;

		public float 					MaskColor;

		public static float4x4 			NearCorners;
		public static float4x4 			FarCorners;

		public static float 			ZNear;
		public static float 			ZFar;

		public static int2 				dcViewportSize;
		public static float 			dcRatio;

		public static float4x4 			InverseProjection;
		public static float4x4 			Projection;
	}
}