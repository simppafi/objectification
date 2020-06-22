using Uno;
using Uno.Collections;
using Fuse;

namespace simppafi
{
	public class DrumReader
	{
		private List<DrumData> data;
		private int id;

		public DrumReader(string text_data, int id)
		{
			this.id = id;
			var drum_data = text_data;
			var nodes = drum_data.Split(new [] {(char)';'});
			
			data = new List<DrumData>();

			var c = 0;
			for(var i = 0; i < nodes.Length; i++)
			{
				//0:00.744;
				var strip_min = nodes[i].Split(new [] {(char)':'});
				var strip_sec = strip_min[1].Split(new [] {(char)'.'});

				var mins = Double.Parse(strip_min[0]) * 60000.0;
				var secs = Double.Parse(strip_sec[0]) * 1000.0;
				var ms = Double.Parse(strip_sec[1]);
				//if(id == 1)
				//{
				//	debug_log i+" "+(mins+secs+ms);
				//}
				data.Add(new DrumData(id, 1f, (mins+secs+ms), c ));
				c++;
			}
		}

		private int dataPos = 0;
		public DrumData GetDrum(double time)
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
