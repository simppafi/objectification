using Fuse;

namespace simppafi.Object
{
	public class ObjectLight
	{
		public float3 Position;
		public float3 Target;
		public float3 Color;
		public float Scale;
		public float Power;

		public ObjectLight(float3 Position, float3 Target, float3 Color, float Scale, float Power)
		{
			this.Position = Position;
			this.Target = Target;
			this.Color = Color;
			this.Scale = Scale;
			this.Power = Power;
		}
	}
}