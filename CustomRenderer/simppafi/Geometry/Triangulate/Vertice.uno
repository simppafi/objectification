namespace simppafi.Geometry.Triangulate
{
	public class Vertice
	{
		public double x;
		public double y;
		public double z;

		public float3 color;
		public float power;

		public Vertice(double _x, double _y, double _z, float3 color = float3(0), float power = 0f)
		{
			this.x = _x;
			this.y = _y;
			this.z = _z;
			this.color = color;
			this.power = power;
		}

	}

}