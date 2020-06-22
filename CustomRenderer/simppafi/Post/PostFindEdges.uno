using Uno;
using Fuse.Drawing.Primitives;
using Fuse;
using Uno.Vector;
using Uno.Math;

namespace simppafi
{
	public class PostFindEdges : BasePost
	{
		public float Spread { get; set; }

		public float Strength { get; set; }

		public float4 BackgroundColor { get; set; }

		public float4 EdgeColor { get; set; }

		private int2 						size;

		public PostFindEdges(float spread = 1f, float strength = .5f, float4 color = float4(1,1,1,1))
		{
			Spread = spread;
			Strength = strength;
			BackgroundColor = float4(0,0,0,1);
			EdgeColor = color;
		}


		override public void Process(Fuse.DrawContext dc, framebuffer source, framebuffer target)
		{

			dc.PushRenderTarget(target);
			dc.Clear(float4(1,1,1,0), 1.0f);

			draw Quad
			{
				float2 delta: float2(Spread / target.Size.X, Spread / target.Size.Y);
				TexCoord: float2(prev.X, 1.0f - prev.Y);

				float3 s1 : sample(source.ColorBuffer, TexCoord, samplerState).XYZ;
				float3 s2 : sample(source.ColorBuffer, TexCoord + float2(delta.X, 0), samplerState).XYZ;
				float3 s3 : sample(source.ColorBuffer, TexCoord + float2(0, delta.Y), samplerState).XYZ;
				float3 s4 : sample(source.ColorBuffer, TexCoord + float2(-delta.X, 0), samplerState).XYZ;
				float3 s5 : sample(source.ColorBuffer, TexCoord + float2(0, -delta.Y), samplerState).XYZ;

				float d1 : Vector.Length(s2 - s1);
				float d2 : Vector.Length(s3 - s1);
				float d3 : Vector.Length(s4 - s1);
				float d4 : Vector.Length(s5 - s1);

				float xx : Math.Min(1.0f, (d1+d2+d3+d4) * Strength);

				PixelColor: pixel(BackgroundColor * (1.0f - xx) + EdgeColor * xx);

			};

			dc.PopRenderTarget();

		}

	}
}