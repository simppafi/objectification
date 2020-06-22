namespace simppafi.Utils
{
	public static class TimeRandom
	{
		private static Uno.Random rand;

		private static float[] 		randomFloat;
		private static int 			randPos = 0;
		private static int			cacheSize = 4096;

		public static Uno.Random GetRandom(bool cache = false)
		{
			if(rand == null)
			{
				int seed = 1;
				var arr = Uno.Diagnostics.Clock.GetSeconds().ToString().Split(new [] {(char)('.')});
				if(arr.Length == 1)
				{
					arr = Uno.Diagnostics.Clock.GetSeconds().ToString().Split(new [] {(char)(',')});
					if(arr.Length == 0)
					{
						arr = new [] {"0","1"};
					}
				}
				if( arr[1] != null)
				{
					var arr2 = arr[1].Split(new [] {(char)('E')});
					seed = Uno.Int.Parse(arr2[0]);
				}
				rand = new Uno.Random(seed);

				if(cache)
				{
					randomFloat = new float[cacheSize];
					for(var i = 0; i < cacheSize; i++)
					{
						randomFloat[i] = rand.NextFloat();
					}
				}

			}
			return rand;
		}

		public static float NextFloat()
		{
			randPos++;
			if(randPos == (cacheSize-1)) randPos = 0;
			if(randomFloat != null)
			{
				return randomFloat[randPos];
			}else{
				return rand.NextFloat();
			}
		}
	}
}