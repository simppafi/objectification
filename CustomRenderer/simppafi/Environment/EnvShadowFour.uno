using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Fuse.Entities;
using Fuse.Drawing.Primitives;

namespace simppafi
{
	public static class EnvShadowFour
	{
		public static void Resize(int size)
		{
			shadowMapSize = size;
			if(shadowMap != null) { shadowMap.Dispose(); shadowMap = null; }
			
			shadowMap = new framebuffer(int2(shadowMapSize), Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			BLUR_RES = 1.0f / ((float)shadowMapSize);
		}

		public static int	 					shadowMapSize = 512;
		public static float 					lightDepth = 2000.0f;
		public static float 					perspective = Math.PIf/2f;
		public static float 					shadowAmbient = .1f;
		public static float 					shadowC = 88f;
		public static float2 					ShadowArea = float2(1024);

		public static float3[] 					lightTarget = new [] {float3(0),float3(0),float3(0),float3(0)};
		public static float3[] 					lightPosition = new [] {float3(0),float3(0),float3(0),float3(0)};
		public static float4x4[] 				lightMatrix = new [] {	float4x4(0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f),
																		float4x4(0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f),
																		float4x4(0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f),
																		float4x4(0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f)};

		public static framebuffer 				shadowMap = new framebuffer(int2(shadowMapSize), Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
		public static float 					BLUR_RES = 1.0f / ((float)shadowMapSize);

		public static Uno.Graphics.SamplerState	samplerState = Uno.Graphics.SamplerState.LinearClamp;

		public static void Begin(DrawContext dc)
		{
			//lightMatrix = Matrix.Mul(Matrix.LookAtRH(lightPosition, lightTarget, float3(0,1,0)), Matrix.PerspectiveRH(perspective, 1f, 10, lightDepth));
			lightMatrix[0] = Matrix.Mul(Matrix.LookAtRH(lightPosition[0], lightTarget[0], float3(0,1,0)), Matrix.OrthoRH(ShadowArea.X, ShadowArea.Y, 10, lightDepth));
				
			dc.PushRenderTarget(shadowMap);
			dc.Clear(float4(0,0,0,0), 1.0f);
			
		}

		public static void End(DrawContext dc)
		{
			dc.PopRenderTarget();
		}

	}
}