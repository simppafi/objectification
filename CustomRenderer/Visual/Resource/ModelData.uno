using Uno;
using Uno.Collections;
using Fuse;

namespace simppafi
{
	public class ModelData
	{
		public List<float3> positions = new List<float3>();
		public List<float3> normals = new List<float3>();
		public List<float2> uvs = new List<float2>();
		public List<float3> color = new List<float3>();
		public int vertexCount = 0;

		public ModelData()//List<float3> positions, List<float3>normals, List<float2> uvs, int vertexCount)
		{
			/*
			this.positions = positions;
			this.normals = normals;
			this.uvs = uvs;
			this.vertexCount = vertexCount;
			*/
		}

	}
}