using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Fuse.Entities;
using Fuse.Drawing.Primitives;

namespace simppafi
{
	public static class EnvMirror// : BaseEnvironment
	{
		public static void Resize(int size)
		{
			mirrorMapSize = size;
			if(mirrorMap != null) { mirrorMap.Dispose(); mirrorMap = null; }
			
			mirrorMap = new framebuffer(int2(mirrorMapSize), Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			BLUR_RES = 1.0f / ((float)mirrorMapSize);
		}

		public static int	 					mirrorMapSize = 1024;

		public static float 					mirrorAmbient = .1f;
		public static float3 					Target = float3(0,0,0);
		public static float3 					Position = float3(.0f, -4000f, .0f);
		public static float 					Depth = 10000.0f;
		public static float 					perspective = Math.PIf/4f;//1f;//Math.PIf/1.1f;
		public static float4x4 					mirrorMatrix;
		
		public static framebuffer 				mirrorMap = new framebuffer(int2(mirrorMapSize), Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
		public static float 					BLUR_RES = 1.0f / ((float)mirrorMapSize);

		public static Uno.Graphics.SamplerState	samplerState = Uno.Graphics.SamplerState.LinearClamp;

		public static void Begin(DrawContext dc)
		{
			//if(Position == float3(0)) Position = Vector.Normalize(RenderPipeline.CameraTransform.Position) * 1000.0f * float3(-1f,1f,1f);

			mirrorMatrix = Matrix.Mul(Matrix.LookAtRH(Position, Target, float3(0,0,1)), Matrix.PerspectiveRH(perspective, 1f, 10, Depth));

			//mirrorMatrix = Matrix.Mul(mirrorMatrix, Matrix.Scaling(1,1,1));// = Matrix.Invert(mirrorMatrix);

			dc.PushRenderTarget(mirrorMap);
			dc.Clear(float4(0,0,0,0), 1.0f);
		}

		public static void End(DrawContext dc)
		{
			dc.PopRenderTarget();
		}

	}
}