namespace simppafi.Utils
{
	public static class CachedRandom
	{
		private static bool 		isInitialized = false;
		private static float[] 		randomFloat;
		private static float3[] 	randomFloat3;
		private static int 			randPos = 0;
		private static int			cacheSize = 4096;

		public static void Initialize(int seed)
		{
			if(!isInitialized)
			{
				var rand = new Uno.Random(seed);
				randomFloat = new float[cacheSize];
				randomFloat3 = new float3[cacheSize];
				for(var i = 0; i < cacheSize; i++)
				{
					randomFloat[i] = rand.NextFloat();
					randomFloat3[i] = rand.NextFloat3();
				}
				isInitialized = true;
			}
		}

		public static float NextFloat()
		{
			randPos++;
			if(randPos == (cacheSize-1)) randPos = 0;
			return randomFloat[randPos];
		}

		public static float3 NextFloat3()
		{
			randPos++;
			if(randPos == (cacheSize-1)) randPos = 0;
			return randomFloat3[randPos];
		}
	}
}