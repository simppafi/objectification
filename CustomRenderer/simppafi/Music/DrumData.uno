using Uno;
using Uno.Collections;
using Fuse;

namespace simppafi
{
	public class DrumData
	{
		public int id;
		public float power;
		public double ms;
		public int pos;

		public DrumData(int id, float power, double ms, int pos)
		{
			this.id = id;
			this.power = power;
			this.ms = ms;
			this.pos = pos;
		}

	}
}
