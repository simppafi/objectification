using Fuse;
using Uno;
using Uno.Collections;

namespace simppafi.Utils
{
	public static class BatchHelper
	{
		public static int WriteIndicesNormalsTangents(Fuse.Drawing.Batching.Batch Geom, simppafi.Geometry.GeometryVO geometric, List<float3> newVertexPositions, float2[] uvs, int indiceCount, int indexAdd)
		{
			int i;
			int verticeCount = newVertexPositions.Count;

			var tan1 = new float3[indiceCount];
			var tan2 = new float3[indiceCount];

			float3[] normalSum = new float3[Math.Min(verticeCount, indiceCount)];
			int[] normalSumCount = new int[Math.Min(verticeCount, indiceCount)];

			for(i = 0; i < geometric.indices.Count; i++)
			{
				var A = newVertexPositions[geometric.indices[i].X];
				var B = newVertexPositions[geometric.indices[i].Y];
				var C = newVertexPositions[geometric.indices[i].Z];
				var n = Vector.Cross(B-A, C-A);

				normalSum[geometric.indices[i].X] += n;
				normalSum[geometric.indices[i].Y] += n;
				normalSum[geometric.indices[i].Z] += n;

				normalSumCount[geometric.indices[i].X]++;
				normalSumCount[geometric.indices[i].Y]++;
				normalSumCount[geometric.indices[i].Z]++;				

				Geom.Indices.Write((ushort)(geometric.indices[i].X + indexAdd));
				Geom.Indices.Write((ushort)(geometric.indices[i].Y + indexAdd));
				Geom.Indices.Write((ushort)(geometric.indices[i].Z + indexAdd));

				
				var i1 = geometric.indices[i].X;
		        var i2 = geometric.indices[i].Y;
		        var i3 = geometric.indices[i].Z;

		        var w1 = uvs[i1];
		        var w2 = uvs[i2];
		        var w3 = uvs[i3];
		        
		        float x1 = B.X - A.X;
		        float x2 = C.X - A.X;
		        float y1 = B.Y - A.Y;
		        float y2 = C.Y - A.Y;
		        float z1 = B.Z - A.Z;
		        float z2 = C.Z - A.Z;
		        
		        float s1 = w2.X - w1.X;
		        float s2 = w3.X - w1.X;
		        float t1 = w2.Y - w1.Y;
		        float t2 = w3.Y - w1.Y;
		        
		        float r = 1.0f / (s1 * t2 - s2 * t1);
		        var sdir = float3(	(t2 * x1 - t1 * x2) * r, 
		        					(t2 * y1 - t1 * y2) * r,
		                			(t2 * z1 - t1 * z2) * r);
		        var tdir = float3(	(s1 * x2 - s2 * x1) * r, 
		        					(s1 * y2 - s2 * y1) * r,
		                			(s1 * z2 - s2 * z1) * r);
		        
		        tan1[i1] += sdir;
		        tan1[i2] += sdir;
		        tan1[i3] += sdir;
		        
		        tan2[i1] += tdir;
		        tan2[i2] += tdir;
		        tan2[i3] += tdir;
			}

			var normal = new float3[verticeCount];
			for(i = 0; i < verticeCount; i++)
			{
				var n = normalSum[i] / normalSumCount[i];
				Geom.Normals.Write(Vector.Normalize(n));
				normal[i] = Vector.Normalize(n);
			}


			for(i = 0; i < verticeCount; i++)
			{
		        var n = normal[i];
		        var t = tan1[i];
		        
		        var tangXYZ = Vector.Normalize(t - n * Vector.Dot(n, t));
		        var tangW = (Vector.Dot(Vector.Cross(n, t), tan2[i]) < 0.0f) ? -1.0f : 1.0f;

		        Geom.Tangents.Write(float4(tangXYZ,tangW));

		        var bitangent = Vector.Cross(n, tangXYZ);
				bitangent = Vector.Normalize(bitangent);

		        Geom.Binormals.Write(bitangent);
		    }

			return indexAdd + geometric.vertices.Count;

		}


		public static int WriteTangents(Fuse.Drawing.Batching.Batch Geom, float3[] vertices, float3[] normals, float2[] uvs, int indexAdd)
		{
			int i;
			
			var tan1 = new float3[vertices.Length];
			var tan2 = new float3[vertices.Length];

			for(i = 0; i < vertices.Length; i+=3)
			{
				var i1 = i;
		        var i2 = i+1;
		        var i3 = i+2;

				var A = vertices[i1];
				var B = vertices[i2];
				var C = vertices[i3];

		        var w1 = uvs[i1];
		        var w2 = uvs[i2];
		        var w3 = uvs[i3];
		        
		        float x1 = B.X - A.X;
		        float x2 = C.X - A.X;
		        float y1 = B.Y - A.Y;
		        float y2 = C.Y - A.Y;
		        float z1 = B.Z - A.Z;
		        float z2 = C.Z - A.Z;
		        
		        float s1 = w2.X - w1.X;
		        float s2 = w3.X - w1.X;
		        float t1 = w2.Y - w1.Y;
		        float t2 = w3.Y - w1.Y;
		        
		        float r = 1.0f / (s1 * t2 - s2 * t1);
		        var sdir = float3(	(t2 * x1 - t1 * x2) * r, 
		        					(t2 * y1 - t1 * y2) * r,
		                			(t2 * z1 - t1 * z2) * r);
		        var tdir = float3(	(s1 * x2 - s2 * x1) * r, 
		        					(s1 * y2 - s2 * y1) * r,
		                			(s1 * z2 - s2 * z1) * r);
		        
		        tan1[i1] += sdir;
		        tan1[i2] += sdir;
		        tan1[i3] += sdir;
		        
		        tan2[i1] += tdir;
		        tan2[i2] += tdir;
		        tan2[i3] += tdir;
			}

			for(i = 0; i < vertices.Length; i++)
			{
		        var n = normals[i];
		        var t = tan1[i];
		        
		        var tangXYZ = Vector.Normalize(t - n * Vector.Dot(n, t));
		        var tangW = (Vector.Dot(Vector.Cross(n, t), tan2[i]) < 0.0f) ? -1.0f : 1.0f;

		        Geom.Tangents.Write(float4(tangXYZ,tangW));

		        var bitangent = Vector.Cross(n, tangXYZ);
				bitangent = Vector.Normalize(bitangent);

		        Geom.Binormals.Write(bitangent);
		    }

			return indexAdd + vertices.Length;

		}

		public static float2 UVFromSphere(float3 v)
		{
			var va = Vector.Normalize(v);
			return float2(
				.5f + Math.Atan2(va.Z, va.X) / (Math.PIf*2f),
				.5f - Math.Asin(va.Y) / Math.PIf
			);
		}


	}
}

