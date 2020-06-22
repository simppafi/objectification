using Uno.Collections;
namespace simppafi.Geometry
{
	public class GeometryVO
	{
		public List<float3> 	vertices;
		public List<float3> 	vertices2;
		public List<int3> 		indices;
		public List<float2> 	texCoords;
		public List<int>		id;
		public GeometryVO(List<float3> vertices, List<int3> indices, List<float2> texCoords)
		{
			this.vertices = vertices;
			this.indices = indices;
			this.texCoords = texCoords;
		}
		public GeometryVO()
		{
			this.vertices = new List<float3>();
			this.indices = new List<int3>();
			this.texCoords = new List<float2>();
			this.vertices2 = new List<float3>();
			this.id = new List<int>();
		}
	}
}