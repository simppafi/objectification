using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Fuse.Entities;
using Fuse.Drawing.Primitives;

namespace simppafi
{
	public class EnvShadow// : BaseEnvironment
	{
		public EnvShadow(simppafi.Object.ObjectLight Light)
		{
			this.Light = Light;
		}

		public void Resize(int size)
		{
			shadowMapSize = size;
			if(shadowMap != null) { shadowMap.Dispose(); shadowMap = null; }
			
			shadowMap = new framebuffer(int2(shadowMapSize), Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			BLUR_RES = 1.0f / ((float)shadowMapSize);
		}

		public simppafi.Object.ObjectLight 	Light;

		public int	 						shadowMapSize = 512;
		public float 						shadowAmbient = .1f;
		public float 						lightDepth = 2000.0f;
		public float 						perspective = Math.PIf/1.5f;//1f;//Math.PIf/1.1f;
		public float4x4 					lightMatrix;
		public float 						shadowC = 88f;
		public float2 						shadowArea = float2(1024);
		
		public framebuffer 					shadowMap = new framebuffer(int2(512), Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
		public float 						BLUR_RES = 1.0f / 512f;

		public Uno.Graphics.SamplerState	samplerState = Uno.Graphics.SamplerState.LinearClamp;

		public void Begin(DrawContext dc)
		{

			//lightMatrix = Matrix.Mul(Matrix.LookAtRH(lightPosition, lightTarget, float3(0,1,0)), Matrix.PerspectiveRH(perspective, 1f, 10, lightDepth));
			//lightMatrix = Matrix.Mul(Matrix.LookAtRH(lightPosition, lightTarget, float3(0,1,0)), Matrix.OrthoRH(shadowArea.X, shadowArea.Y, 10, lightDepth));

			dc.PushRenderTarget(shadowMap);
			dc.Clear(float4(0,0,0,0), 1.0f);
		}

		public void End(DrawContext dc)
		{
			dc.PopRenderTarget();
		}

	}
}