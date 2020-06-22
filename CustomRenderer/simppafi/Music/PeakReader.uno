
using Uno;
using Uno.Collections;
using Fuse;

namespace simppafi
{
	public class PeakReader
	{
		
		private List<simppafi.DrumData> data = new List<simppafi.DrumData>();
		public PeakReader(string text)
		{
			var peaks = text.Split(new [] {(char)'#'});
			
			for(var i = 0; i < peaks.Length-1; i++)
			{
				string str = peaks[i];
				var split = str.Split(new [] {(char)':'});

				var peakpower = Float.Parse(split[1]) / 150f;
				var ms = Double.Parse(split[0]) * 1000.0;
				
				data.Add(new simppafi.DrumData(i, peakpower, ms, i));
			}
		}

		private int dataPos = 0;
		public DrumData GetPeak(double time)
		{
			DrumData res = null;

			if(dataPos < data.Count)
			{

				while(data[Math.Max(0,dataPos-1)].ms > time && dataPos > 0)
				{
					dataPos--;
				}

				while(data[Math.Min(data.Count-1,dataPos+1)].ms < time && dataPos < data.Count-1)
				{
					dataPos++;
				}

				if(time > data[dataPos].ms)
				{
					res = data[dataPos];
					dataPos++;
				}
			}
			
			return res;
		} 

		public void Reset()
		{
			dataPos = 0;
		}


	}
}
