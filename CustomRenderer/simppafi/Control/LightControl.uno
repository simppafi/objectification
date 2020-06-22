using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Entities;

namespace simppafi
{
	public static class LightControl
	{
		private static Random rand = new Random(1);

		public static float LightScaleHalf = 40f;

		private static float[] 	_Power = new [] {0f,0f,0f,0f,0f};
		private static float[] 	_PowerGoto = new [] {0f,0f,0f,0f,0f};
		private static float[] 	_dimm = new [] {0.99f,0.9f,0.9f,0.9f,0.9f};

		public static void Hit(float val) {

			if(val == 3f) //piano
			{
				_Power[0] = 3f;
			}

			if(val == 0f || val == 4f) //tom
			{
				if(rand.NextFloat() > .5f)
				{
					if(_Power[1] < 2f)
					{
						_Power[1] += .25f;
					}
				}else{
					if(_Power[2] < 2f)
					{	
						_Power[2] += .25f;
					}
				}
			}
			if(val == 1f) //snare
			{
				_Power[3] = 2f;
			}
			if(val == 2f) //kick
			{
				_Power[4] = 1f;
			}
			
		}
		public static void OnUpdate()
		{
			var ease = Math.Min(.75f, (float)Fuse.Time.FrameInterval * 20f);
			
			for(var i = 0; i < 5; i++)
			{
				_PowerGoto[i] = _PowerGoto[i] + (_Power[i]-_PowerGoto[i]) * ease;
				
				simppafi.RenderPipeline.Lights[i].Power = _PowerGoto[i];
				simppafi.RenderPipeline.Lights[i].Scale = LightScaleHalf + Math.Min(LightScaleHalf, LightScaleHalf * _PowerGoto[i]);
				
				_Power[i] *= _dimm[i];
			}

		}
	}

}
	