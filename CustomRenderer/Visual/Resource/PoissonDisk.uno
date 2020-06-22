using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Uno.Content;
using Uno.Content.Models;
using Fuse.Entities.Designer;
using Fuse.Drawing;
using Fuse.Drawing.Primitives;
using Fuse.Entities;
using OpenGL;

namespace simppafi
{
	public static class PoissonDisk
	{
		private static float2[]		points;

		public static float2[] getPoints()
		{
			if(points == null)
			{
				var pointCloud = CreateFloat2Array(import Buffer("../../Assets/poisson2.bin"));
				points = new float2[pointCloud.Length];
				Uno.Array.Copy(pointCloud, points, pointCloud.Length);
			}
			return points;
		}

		private static float2[] CreateFloat2Array(Buffer data)
		{
			var l = data.SizeInBytes/8;
			var arr = new float2[l];
			for(var i = 0; i < l; i++)
			{
				arr[i] = data.GetFloat2(i*8, true);
			}
			return arr;
		}

	}

}