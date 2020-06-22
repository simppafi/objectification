using Uno.Collections;
namespace simppafi.Geometry
{
	public static class GeometryCache
	{
		public static Dictionary<string, GeometryVO> cache = new Dictionary<string, GeometryVO>();
		public static void Clear()
		{
			cache = null;
			cache = new Dictionary<string, GeometryVO>();
		}
	}
}