using Uno;
using Uno.Math;

namespace simppafi
{
	public class Gaussian
	{
		private double amplitude;
		private double expScale;

		public Gaussian(double variance)
		{
			amplitude = 1.0 / Sqrt(2.0 * variance * PI);
    		expScale = -1.0 / (2.0 * variance);
		}

		public float ValueAt(float x)
		{
			return (float)ValueAt((double)x);
		}

		public double ValueAt(double x)
		{
			return amplitude * Exp(x*x*expScale);
		}

		static public Gaussian FromRadius(float radius, float epsilon = .01f)
		{		
			return Gaussian.FromRadius((double)radius, (double)epsilon);
		}

		static public Gaussian FromRadius(double radius, double epsilon = .01)
		{
		    var standardDeviation = radius / Sqrt(-2.0 * Log(epsilon)/Log(E));
		    return new Gaussian(standardDeviation*standardDeviation);
		}
	}
}