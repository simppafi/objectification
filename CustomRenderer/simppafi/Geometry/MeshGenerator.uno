using Uno;
using Uno.Collections;
using Uno.Graphics;

using Uno.Content;
using Uno.Content.Models;


namespace simppafi.Geometry
{
	public static class MeshGenerator
	{
		public static ModelMesh CreateCylinder(float height, float radius, int horizontalTessellation, int verticalTessellation, bool topCap = true, bool bottomCap = true)
        {
            int horizontalVertexCount = horizontalTessellation + 1;
            int verticalVertexCount = verticalTessellation + 1;

            int bodyVertexCount = horizontalVertexCount * verticalVertexCount;
            int bodyIndexCount = horizontalTessellation * verticalTessellation * 6;

            int capVertexCount = horizontalVertexCount + 1;
            int capIndexCount = horizontalVertexCount * 3;

            int vertexCount = bodyVertexCount + (capVertexCount << 1);
            int indexCount = bodyIndexCount + (capIndexCount << 1);

            float halfLength = height * .5f;

            var vertices = new float3[vertexCount];
            var normals = new float3[vertexCount];
            var texCoords = new float2[vertexCount];
            var indices = new ushort[indexCount];

            for (int j = 0; j < verticalVertexCount; j++)
            {
                float v = (float)j / (float)verticalTessellation;

                for (int i = 0; i < horizontalVertexCount; ++i)
                {
                    int k = i + j * horizontalVertexCount;
                    float u = (float)i / (float)horizontalTessellation;

                    texCoords[k] = float2(u, v);

                    u *= 2.f * Math.PIf;

                    vertices[k] = float3(Math.Cos(u) * radius, -halfLength + v * height, Math.Sin(u) * radius);
                    normals[k] = float3(Math.Cos(u), 0.f, Math.Sin(u));
                }
            }

            for (int i = 0; i < horizontalTessellation; ++i)
            {
                for (int j = 0; j < verticalTessellation; ++j)
                {
                    int k = (i + j * horizontalTessellation) * 6;

                    indices[k + 0] = (ushort)((i + j * horizontalVertexCount) + 0);
                    indices[k + 1] = (ushort)((i + (j + 1) * horizontalVertexCount) + 0);
                    indices[k + 2] = (ushort)((i + j * horizontalVertexCount) + 1);

                    indices[k + 3] = (ushort)((i + j * horizontalVertexCount) + 1);
                    indices[k + 4] = (ushort)((i + (j + 1) * horizontalVertexCount) + 0);
                    indices[k + 5] = (ushort)((i + (j + 1) * horizontalVertexCount) + 1);
                }
            }

            vertices[bodyVertexCount] = float3(0.f, -halfLength, 0.f);
            normals[bodyVertexCount] = float3(0.f, -1.f, 0.f);
            texCoords[bodyVertexCount] = float2(.5f, .5f);

            vertices[bodyVertexCount + 1] = float3(0.f, halfLength, 0.f);
            normals[bodyVertexCount + 1] = float3(0.f, 1.f, 0.f);
            texCoords[bodyVertexCount + 1] = float2(.5f, .5f);

            for (int i = 0; i < horizontalVertexCount; i++)
            {
                float u = (float)i / (float)horizontalTessellation;
                u *= 2.f * Math.PIf;

                vertices[bodyVertexCount + 2 + i] = float3(Math.Cos(u) * radius, -halfLength, Math.Sin(u) * radius);
                normals[bodyVertexCount + 2 + i] = float3(0.f, -1.f, 0.f);
                texCoords[bodyVertexCount + 2 + i] = float2(.5f + .5f * Math.Cos(u), .5f + .5f * Math.Sin(u));

                vertices[bodyVertexCount + 2 + horizontalVertexCount + i] = float3(Math.Cos(u) * radius, halfLength, Math.Sin(u) * radius);
                normals[bodyVertexCount + 2 + horizontalVertexCount + i] = float3(0.f, 1.f, 0.f);
                texCoords[bodyVertexCount + 2 + horizontalVertexCount + i] = float2(.5f + .5f * Math.Cos(u), .5f + .5f * Math.Sin(u));
            }
			if(topCap || bottomCap)
			{
	            int n = 0;
	            int topi = bodyIndexCount;
	            int bottomi = bodyIndexCount + capIndexCount;
	            int topv = bodyVertexCount + 2 + horizontalVertexCount;
	            int bottomv = bodyVertexCount + 2;
	            int topCenter = bodyVertexCount + 1;
	            int bottomCenter = bodyVertexCount;

	            for (int i = 0; i < capIndexCount; i += 3)
	            {
	                int left = n;
	                int right = n + 1;

	                if (right == horizontalVertexCount)
	                    right = 0;
					if(topCap)
					{
	                	indices[topi++] = (ushort)topCenter;
	                	indices[topi++] = (ushort)(topv + right);
	                	indices[topi++] = (ushort)(topv + left);
					}
					if(bottomCap)
					{
		                indices[bottomi++] = (ushort)bottomCenter;
		                indices[bottomi++] = (ushort)(bottomv + left);
		                indices[bottomi++] = (ushort)(bottomv + right);
					}
					n++;
	            }
			}
			
            var dict = new Dictionary<string, VertexAttributeArray>();
            dict[VertexAttributeSemantic.Position] = new VertexAttributeArray(vertices);
            dict[VertexAttributeSemantic.Normal] = new VertexAttributeArray(normals);
            dict[VertexAttributeSemantic.TexCoord] = new VertexAttributeArray(texCoords);
            return new ModelMesh("Cylinder", PrimitiveType.Triangles, dict, new IndexArray(indices));
        }
		
		
		
	}
}