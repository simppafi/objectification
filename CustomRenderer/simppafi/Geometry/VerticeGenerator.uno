using Uno;
using Uno.Collections;
using Uno.Graphics;

using Uno.Content;
using Uno.Content.Models;

namespace simppafi.Geometry
{
	public static class VerticeGenerator
	{
		public static GeometryVO CreateDodecahedron()
		{
			if(!GeometryCache.cache.ContainsKey(Dodecahedron.PREFIX))
			{
				GeometryCache.cache.Add(Dodecahedron.PREFIX, Dodecahedron.create());
			}
			return GeometryCache.cache[Dodecahedron.PREFIX];
		}

		public static GeometryVO CreateIcoSphere(int recursionLevel)
		{
			if(!GeometryCache.cache.ContainsKey(IcoSphere.PREFIX+recursionLevel.ToString()))
			{
				GeometryCache.cache.Add(IcoSphere.PREFIX+recursionLevel.ToString(), IcoSphere.create(recursionLevel));
			}
			return GeometryCache.cache[IcoSphere.PREFIX+recursionLevel.ToString()];
		}

		public static GeometryVO CreateCubeSphere(int recursionLevel)
		{
			if(!GeometryCache.cache.ContainsKey(CubeSphere.PREFIX+recursionLevel.ToString()))
			{
				GeometryCache.cache.Add(CubeSphere.PREFIX+recursionLevel.ToString(), CubeSphere.create(recursionLevel));
			}
			return GeometryCache.cache[CubeSphere.PREFIX+recursionLevel.ToString()];
		}

		public static GeometryVO CreateCubeSphereHalf(int recursionLevel, bool top = true)
		{
			if(!GeometryCache.cache.ContainsKey(CubeSphereHalf.PREFIX+recursionLevel.ToString()))
			{
				GeometryCache.cache.Add(CubeSphereHalf.PREFIX+recursionLevel.ToString(), CubeSphereHalf.create(recursionLevel, top));
			}
			return GeometryCache.cache[CubeSphereHalf.PREFIX+recursionLevel.ToString()];
		}

		public static GeometryVO CreateCubeTunnel(int recursionLevel)
		{
			if(!GeometryCache.cache.ContainsKey(CubeTunnel.PREFIX+recursionLevel.ToString()))
			{
				GeometryCache.cache.Add(CubeTunnel.PREFIX+recursionLevel.ToString(), CubeTunnel.create(recursionLevel));
			}
			return GeometryCache.cache[CubeTunnel.PREFIX+recursionLevel.ToString()];
		}

		public static GeometryVO CreateCubeEight()
		{
			if(!GeometryCache.cache.ContainsKey(CubeEight.PREFIX))
			{
				GeometryCache.cache.Add(CubeEight.PREFIX, CubeEight.create());
			}
			return GeometryCache.cache[CubeEight.PREFIX];
		}

		public static GeometryVO CreateCube()
		{
			if(!GeometryCache.cache.ContainsKey(Cube.PREFIX))
			{
				GeometryCache.cache.Add(Cube.PREFIX, Cube.create());
			}
			return GeometryCache.cache[Cube.PREFIX];
		}

		public static GeometryVO CreateHexcon(float up = 1f, float bottom = 1f)
		{
			//if(!GeometryCache.cache.ContainsKey(Hexacon.PREFIX))
			//{
				//GeometryCache.cache.Add(Hexacon.PREFIX, Hexacon.create(up, bottom));
			//}
			return Hexacon.create(up, bottom);//GeometryCache.cache[Hexacon.PREFIX];
		}


		public static GeometryVO CreateTetrahedron()
		{
			if(!GeometryCache.cache.ContainsKey(Tetrahedron.PREFIX))
			{
				GeometryCache.cache.Add(Tetrahedron.PREFIX, Tetrahedron.create());
			}
			return GeometryCache.cache[Tetrahedron.PREFIX];
		}

		public static GeometryVO CreateTetrahedronTruncate(int seed, float range)
		{
			return TetrahedronTruncate.create(seed, range);
		}

		public static GeometryVO CreateTunnelPath(int parallels, int meridians, float4[] path)
		{
			return TunnelPath.create(parallels, meridians, path);
		}

		public static GeometryVO CreateTunnelPath2(int parallels, float4[] path)
		{
			return TunnelPath2.create(parallels, path);
		}


		public static GeometryVO CreateTunnelCubes(int reso)
		{
			return TunnelCubes.create(reso);
		}

		public static GeometryVO CreateDisk(int reso, float depth, float inner, float outer, bool flat = false)
		{
			return Disk.create(reso, depth, inner, outer, flat);
		}

		public static GeometryVO CreateDiskSuper(int reso, float depth, float inner, float outer, float curves, float curveFrom, float curveTo)
		{
			return DiskSuper.create(reso, depth, inner, outer, curves, curveFrom, curveTo);
		}

		public static GeometryVO CreateFlower(int reso0, int reso1, float depth)
		{
			return Flower.create(reso0, reso1, depth);
		}

		public static GeometryVO CreatePlane(int reso, int rotation = 2)
		{
			return Plane.create(reso, rotation);
		}

		public static GeometryVO CreateCircle(int reso, float depth, bool flat = false)
		{
			return Circle.create(reso, depth, flat);
		}

		public static GeometryVO CreateTriangle()
		{
			return Triangle.create();
		}

		public static void Clear()
		{
			GeometryCache.Clear();
		}
	}


	public static class Plane
	{
		public static string 			PREFIX = "plane_";

		private static GeometryVO 		vo;

		public static GeometryVO create(int recursionLevel, int rotation = 2)
		{
			vo = new GeometryVO();

			int a, b, c, d;
			float4 q;

			var pitches = new[] { 0, Math.DegreesToRadians(90.0f), Math.DegreesToRadians(180.0f), Math.DegreesToRadians(270.0f), 0, 0 };
           	var yaws = new[]    { 0, 0, 0, 0, Math.DegreesToRadians(90.0f), Math.DegreesToRadians(-90.0f) };

			int addIndex = 0;
			int i;

            q = Uno.Quaternion.FromEulerAngle(pitches[rotation], yaws[rotation], 0);

			float x, y;
			int parallels = recursionLevel;
			int meridians = recursionLevel;
			int pstop = parallels-1;
			int mstop = meridians-1;

			for (i = 0; i < parallels; i++)
			{
				x = ((float)i / (float)(parallels-1) - 0.5f) * 2.0f;

				for (int j = 0; j < meridians; j++)
				{
					y = ((float)j / (float)(meridians-1) - 0.5f) * 2.0f;

					float z = 0f;

					float3 vert = Uno.Vector.Transform(float3(	x,y,z), q);

					vo.vertices.Add(vert);
				}
			}

			i = 0;
			for (int k = 0; k < pstop; k++) {
				for (int j = 0; j < mstop; j++)
				{
					a = i + addIndex;
					b = i+1 + addIndex;
					c = i+meridians+1 + addIndex;
					d = i+meridians + addIndex;

					vo.indices.Add(int3(a,b,c));
					vo.indices.Add(int3(c,d,a));
					i++;
				}
				i++;
			}

			addIndex = vo.vertices.Count;



			return vo;
		}
	}


	public static class Triangle
	{
		public static string 			PREFIX = "triangle_";

		private static GeometryVO 		vo;

		public static GeometryVO create()
		{
			vo = new GeometryVO();

			var angle = (Math.PIf * 2f) / 3f;
			vo.vertices.Add(float3(Math.Sin(angle),		Math.Cos(angle),0));
			vo.vertices.Add(float3(Math.Sin(angle*2),	Math.Cos(angle*2),0));
			vo.vertices.Add(float3(Math.Sin(angle*3),	Math.Cos(angle*3),0));

			vo.indices.Add(int3(0,1,2));

			return vo;
		}
	}


	public static class CubeSphere
	{
		public static string 			PREFIX = "cubesphere_";

		private static GeometryVO 		vo;

		public static GeometryVO create(int recursionLevel)
		{
			vo = new GeometryVO();

			int a, b, c, d;
			float4 q;

			var pitches = new[] { 0, Math.DegreesToRadians(90.0f), Math.DegreesToRadians(180.0f), Math.DegreesToRadians(270.0f), 0, 0 };
           	var yaws = new[]    { 0, 0, 0, 0, Math.DegreesToRadians(90.0f), Math.DegreesToRadians(-90.0f) };

			int addIndex = 0;
			int i;
			for (int l = 0; l < 6; l++)
            {
                q = Uno.Quaternion.FromEulerAngle(pitches[l], yaws[l], 0);

				float x, y;
				int parallels = recursionLevel;
				int meridians = recursionLevel;
				int pstop = parallels-1;
				int mstop = meridians-1;

				for (i = 0; i < parallels; i++)
				{
					x = ((float)i / (float)(parallels-1) - 0.5f) * 2.0f;

					for (int j = 0; j < meridians; j++)
					{
						y = ((float)j / (float)(meridians-1) - 0.5f) * 2.0f;

						vo.texCoords.Add((float2(x,y)+float2(1f)) * .5f);

						float z = -1.0f;

						float3 vert = Uno.Vector.Transform(float3(	x,y,z), q);

						float x1 = vert.X * Math.Sqrt(1.0f - ((vert.Y*vert.Y)/2.0f) - ((vert.Z*vert.Z)/2.0f) + ((vert.Y*vert.Y)*(vert.Z*vert.Z)/3.0f));
						float y1 = vert.Y * Math.Sqrt(1.0f - ((vert.Z*vert.Z)/2.0f) - ((vert.X*vert.X)/2.0f) + ((vert.Z*vert.Z)*(vert.X*vert.X)/3.0f));
						float z1 = vert.Z * Math.Sqrt(1.0f - ((vert.X*vert.X)/2.0f) - ((vert.Y*vert.Y)/2.0f) + ((vert.X*vert.X)*(vert.Y*vert.Y)/3.0f));

						vo.vertices.Add(float3(x1,y1,z1));

					}
				}

				i = 0;
				for (int k = 0; k < pstop; k++) {
					for (int j = 0; j < mstop; j++)
					{
						a = i + addIndex;
						b = i+1 + addIndex;
						c = i+meridians+1 + addIndex;
						d = i+meridians + addIndex;

						vo.indices.Add(int3(a,b,c));
						vo.indices.Add(int3(c,d,a));
						i++;
					}
					i++;
				}

				addIndex = vo.vertices.Count;

			}

			return vo;
		}
	}


	public static class TunnelCubes
	{
		public static string 			PREFIX = "tunnelcubes_";

		private static GeometryVO 		vo;

		public static GeometryVO create(int reso)
		{
			vo = new GeometryVO();

			int a, b, c, d;
			float4 q;

			int addIndex = 0;
			int i;

            q = Uno.Quaternion.FromEulerAngle(Math.DegreesToRadians(90.0f), 0, 0);

			float x, y;
			int parallels = 2;//recursionLevel;
			int meridians = reso;
			int pstop = parallels-1;
			int mstop = meridians-1;

			for (i = 0; i < parallels; i++)
			{
				x = ((float)i / (float)(parallels-1) - 0.5f) * 2.0f;

				for (int j = 0; j < meridians; j++)
				{
					y = ((float)j / (float)(meridians-1) - 0.5f) * 2.0f;

					float z = 1.0f;

					vo.vertices.Add(Uno.Vector.Transform(float3(x,y,z), q));
				}
			}

			i = 0;
			for (int k = 0; k < pstop; k++) {
				for (int j = 0; j < mstop; j++)
				{
					a = i + addIndex;
					b = i+1 + addIndex;
					c = i+meridians+1 + addIndex;
					d = i+meridians + addIndex;

					vo.indices.Add(int3(a,b,c));
					vo.indices.Add(int3(c,d,a));
					i++;
				}
				i++;
			}

			addIndex = vo.vertices.Count;


			return vo;

		}


	}



	public static class TunnelPath2
	{
		public static string 			PREFIX = "tunnelpath2_";

		private static GeometryVO 		vo;

		public static GeometryVO create(int parallels, float4[] path)
		{
			vo = new GeometryVO();

			int i,j;
			float a,_x,_z;
			float3 pt, ring;
			float3 prevPath = path[0].XYZ;

			float rx = 0f;
			float rotx = 0f;
			float prevRotx = 0f;

			float rz = 0f;
			float rotz = 0f;
			float prevRotz = 0f;

			float dv;

			int meridians = path.Length;

			for(j = 0; j < meridians; j++)
			{

				// FACE TO PREV POINT
				rx = Math.Atan2( path[j].X-prevPath.X, path[j].Y-prevPath.Y );
				rotx += prevRotx-rx;

				rz = Math.Atan2( path[j].Z-prevPath.Z, path[j].Y-prevPath.Y );
				rotz += rz-prevRotz;

				for(i = 0; i < parallels; i++)
				{
					dv = ((float)i/(float)parallels);
					a = Math.PIf * 2.0f * dv;
					_x = Math.Sin(a);
					_z = Math.Cos(a);
					
					ring = float3(_x, 0, _z);

					ring = Vector.Transform(ring, Uno.Quaternion.RotationAxis(float3(0,0,1), rotx));
					ring = Vector.Transform(ring, Uno.Quaternion.RotationAxis(float3(1,0,0), rotz));

					pt = path[j].XYZ + ring * path[j].W;

					vo.vertices.Add(pt);

					vo.texCoords.Add(float2(dv, Math.Abs(path[j].Y)/Math.Abs(path[path.Length-1].Y) ));

				}
				prevRotx = rx;
				prevPath = path[j].XYZ;

				prevRotz = rz;

				if(j > 0)
				{
					var jip = (j-1) * parallels;
					for(i = 0; i < parallels; i++)
					{
						var a1 = i;
						var a2 = (i+1) % parallels;
						
						var b1 = parallels+i;
						var b2 = parallels+i;
						
						var c1 = a2;
						var c2 = parallels+a2;

						vo.indices.Add(int3(jip+b1,	jip+a1,	jip+c1));
						vo.indices.Add(int3(jip+b2,	jip+a2,	jip+c2));
					}
				}
			}

			return vo;
		}
	}



	public static class TunnelPath
	{
		public static string 			PREFIX = "tunnelpath_";

		private static GeometryVO 		vo;

		public static GeometryVO create(int parallels, int meridians, float4[] path)
		{
			vo = new GeometryVO();

			float pi = Uno.Math.PIf;

			float x, y;
			int pstop = parallels-1;
			int mstop = meridians-1;

			int addIndex = 0;

			float dx, dz;
			float _dx, _dy, _dz;

			float ax, ay, az, aw, bx, by, bz, bw;
			float factor;
			int step_from, step_to;
			float4 _a, _b;
			float val, mv;

			float4 stepPosition = float4(0.0f);
			int lengthPath = path.Length-2;

			for (int i = 0; i < parallels; i++)
			{
				x = (float)i / (parallels-1) * 2.0f;

				for (int j = 0; j < meridians; j++)
				{
					y = (float)((float)j / (meridians-1) - 0.5f);

					dx = Uno.Math.Cos(-x*pi);
					dz = Uno.Math.Sin(-x*pi);

					factor = ((float)j) / ((float)(meridians-1));
					step_from = (int)Uno.Math.Floor((float)lengthPath * factor);
					step_from = (step_from < lengthPath) ? step_from : lengthPath;
					step_to = step_from+1;

					_a = path[step_from];
					_b = path[step_to];

					ax = _a.X; ay = _a.Y; az = _a.Z; aw = _a.W;
					bx = _b.X; by = _b.Y; bz = _b.Z; bw = _b.W;

					val = factor * lengthPath;
					mv = val - Uno.Math.Floor(val);

					stepPosition.X = ax + (bx - ax) * mv;
					stepPosition.Y = ay + (by - ay) * mv;
					stepPosition.Z = az + (bz - az) * mv;
					stepPosition.W = aw + (bw - aw) * mv;

					float radius = stepPosition.W;

					_dx = radius * dx + stepPosition.X;
					_dy = stepPosition.Y;
					_dz = radius * dz + stepPosition.Z;
					
					var pt = float3(_dx,_dy,_dz);

					vo.vertices.Add(pt);

					vo.texCoords.Add(float2(x, y));
				}
			}

			int _i = addIndex;
			for (int k = 0; k < pstop; k++) {
				for (int h = 0; h < mstop; h++)
				{
					vo.indices.Add(int3(_i, _i+meridians+1, _i+1));
					vo.indices.Add(int3(_i+meridians, _i+meridians+1, _i++));
				}
				_i++;
			}

			return vo;
		}
	}



	public static class CubeSphereHalf
	{
		public static string 			PREFIX = "cubespherehalf_";

		private static GeometryVO 		vo;

		public static GeometryVO create(int recursionLevel, bool top)
		{
			vo = new GeometryVO();

			int a, b, c, d;
			float4 q;

			var pitches = new[] { 0, Math.DegreesToRadians(90.0f), Math.DegreesToRadians(180.0f), Math.DegreesToRadians(270.0f), 0, 0 };
           	var yaws = new[]    { 0, 0, 0, 0, Math.DegreesToRadians(90.0f), Math.DegreesToRadians(-90.0f) };

			int addIndex = 0;
			int i;
			for (int l = 0; l < 6; l++)
            {
                q = Uno.Quaternion.FromEulerAngle(pitches[l], yaws[l], 0);

				float x, y;
				int parallels = recursionLevel;
				int meridians = recursionLevel;
				int pstop = parallels-1;
				int mstop = meridians-1;

				for (i = 0; i < parallels; i++)
				{
					x = ((float)i / (float)(parallels-1) - 0.5f) * 2.0f;

					for (int j = 0; j < meridians; j++)
					{
						y = ((float)j / (float)(meridians-1) - 0.5f) * 2.0f;

						vo.texCoords.Add((float2(x,y)+float2(1f)) * .5f);

						float z = -1.0f;

						float3 vert = Uno.Vector.Transform(float3(	x,y,z), q);

						float x1 = vert.X * Math.Sqrt(1.0f - ((vert.Y*vert.Y)/2.0f) - ((vert.Z*vert.Z)/2.0f) + ((vert.Y*vert.Y)*(vert.Z*vert.Z)/3.0f));
						float y1 = vert.Y * Math.Sqrt(1.0f - ((vert.Z*vert.Z)/2.0f) - ((vert.X*vert.X)/2.0f) + ((vert.Z*vert.Z)*(vert.X*vert.X)/3.0f));
						float z1 = vert.Z * Math.Sqrt(1.0f - ((vert.X*vert.X)/2.0f) - ((vert.Y*vert.Y)/2.0f) + ((vert.X*vert.X)*(vert.Y*vert.Y)/3.0f));

						if(top)
						{
							if(y1 < 0f) y1 = 0f;
						}else{
							if(y1 > 0f) y1 = 0f;
						}

						vo.vertices.Add(float3(x1,y1,z1));

					}
				}

				i = 0;
				for (int k = 0; k < pstop; k++) {
					for (int j = 0; j < mstop; j++)
					{
						a = i + addIndex;
						b = i+1 + addIndex;
						c = i+meridians+1 + addIndex;
						d = i+meridians + addIndex;

						vo.indices.Add(int3(a,b,c));
						vo.indices.Add(int3(c,d,a));
						i++;
					}
					i++;
				}

				addIndex = vo.vertices.Count;

			}

			return vo;
		}
	}


	public static class IcoSphere
	{
		public static string 			PREFIX = "icosphere_";

		private static GeometryVO 		vo;
		private static Dictionary<int, int> cache;
		private static int index;

		private static int addVertex(float3 p)
	    {
			float3 pt = Uno.Vector.Normalize(p);
			vo.vertices.Insert(index, pt);
			return index++;
	    }

		// return index of point in the middle of p1 and p2
	    private static int getMiddlePoint(int p1, int p2)
	    {
	        // first check if we have it already
	        bool firstIsSmaller = p1 < p2;
	        int smallerIndex = firstIsSmaller ? p1 : p2;
	        int greaterIndex = firstIsSmaller ? p2 : p1;
	        int key = (smallerIndex << 16) + greaterIndex;

			if (cache.ContainsKey(key))
			{
				return cache[key];
      		}
			else
			{
				float3 point1 = vo.vertices[p1];
		        float3 point2 = vo.vertices[p2];
		        float3 middle = float3(	(point1.X + point2.X) / 2.0f,
										(point1.Y + point2.Y) / 2.0f,
										(point1.Z + point2.Z) / 2.0f);

		        // add vertex makes sure point is on unit sphere
		        int index = addVertex(middle);

				// store it, return index
		        cache[key] = index;

		        return index;
			}
	    }

		public static GeometryVO create(int recursionLevel)
		{
			vo = new GeometryVO();

			cache = new Dictionary<int, int>();
			index = 0;

			// create 12 vertices of a icosahedron
	        float t = (1.0f + Uno.Math.Sqrt(5.0f)) / 2.0f;

	        addVertex(float3(-1.0f,  t,  0.0f));
	        addVertex(float3( 1.0f,  t,  0.0f));
	        addVertex(float3(-1.0f, -t,  0.0f));
	        addVertex(float3( 1.0f, -t,  0.0f));

	        addVertex(float3( 0.0f, -1.0f,  t));
	        addVertex(float3( 0.0f,  1.0f,  t));
	        addVertex(float3( 0.0f, -1.0f, -t));
	        addVertex(float3( 0.0f,  1.0f, -t));

	        addVertex(float3( t,  0.0f, -1.0f));
	        addVertex(float3( t,  0.0f,  1.0f));
	        addVertex(float3(-t,  0.0f, -1.0f));
	        addVertex(float3(-t,  0.0f,  1.0f));

	        // create 20 triangles of the icosahedron
	        var faces = new List<int3>();

	        // 5 faces around point 0
	        faces.Add(int3(0, 11, 5));
	        faces.Add(int3(0, 5, 1));
	        faces.Add(int3(0, 1, 7));
	        faces.Add(int3(0, 7, 10));
	        faces.Add(int3(0, 10, 11));

	        // 5 adjacent faces
	        faces.Add(int3(1, 5, 9));
	        faces.Add(int3(5, 11, 4));
	        faces.Add(int3(11, 10, 2));
	        faces.Add(int3(10, 7, 6));
	        faces.Add(int3(7, 1, 8));

	        // 5 faces around point 3
	        faces.Add(int3(3, 9, 4));
	        faces.Add(int3(3, 4, 2));
	        faces.Add(int3(3, 2, 6));
	        faces.Add(int3(3, 6, 8));
	        faces.Add(int3(3, 8, 9));

	        // 5 adjacent faces
	        faces.Add(int3(4, 9, 5));
	        faces.Add(int3(2, 4, 11));
	        faces.Add(int3(6, 2, 10));
	        faces.Add(int3(8, 6, 7));
	        faces.Add(int3(9, 8, 1));

			// refine triangles
	        for (int i = 0; i < recursionLevel; i++)
	        {
				var faces2 = new List<int3>();

				for (int j = 0; j < faces.Count; j++)
	            {
					var tri = faces[j];

					// replace triangle by 4 triangles
	                int a = getMiddlePoint(tri.X, tri.Y);
	                int b = getMiddlePoint(tri.Y, tri.Z);
	                int c = getMiddlePoint(tri.Z, tri.X);

	                faces2.Add(int3(tri.X, a, c));
	                faces2.Add(int3(tri.Y, b, a));
	                faces2.Add(int3(tri.Z, c, b));
	                faces2.Add(int3(a, b, c));
	            }
	            faces = faces2;
	        }

			for (int i = 0; i < faces.Count; i++)
	        {
				vo.indices.Add(faces[i]);
	        }

			return vo;

	    }
	}



	public static class CubeTunnel
	{
		public static string 			PREFIX = "cubetunnel_";

		private static GeometryVO 		vo;

		public static GeometryVO create(int recursionLevel)
		{
			vo = new GeometryVO();

			int a, b, c, d;
			float4 q;

			var pitches = new[] { Math.DegreesToRadians(90.0f), Math.DegreesToRadians(270.0f), 	0, 								0 };
           	var yaws = new[]    { 0, 															0, 								Math.DegreesToRadians(90.0f), 	Math.DegreesToRadians(-90.0f) };

			int addIndex = 0;
			int i;
			for (int l = 0; l < 4; l++)
            {
                q = Uno.Quaternion.FromEulerAngle(pitches[l], yaws[l], 0);

				float x, y;
				int parallels = 2;//recursionLevel;
				int meridians = recursionLevel;
				int pstop = parallels-1;
				int mstop = meridians-1;

				for (i = 0; i < parallels; i++)
				{
					x = ((float)i / (float)(parallels-1) - 0.5f) * 2.0f;

					for (int j = 0; j < meridians; j++)
					{
						y = ((float)j / (float)(meridians-1) - 0.5f) * 2.0f;

						float z = -1.0f;

						vo.vertices.Add(Uno.Vector.Transform(float3(x,y,z), q));
					}
				}

				i = 0;
				for (int k = 0; k < pstop; k++) {
					for (int j = 0; j < mstop; j++)
					{
						a = i + addIndex;
						b = i+1 + addIndex;
						c = i+meridians+1 + addIndex;
						d = i+meridians + addIndex;

						vo.indices.Add(int3(a,b,c));
						vo.indices.Add(int3(c,d,a));
						i++;
					}
					i++;
				}

				addIndex = vo.vertices.Count;

			}

			return vo;
		}
	}



	public static class CubeEight
	{
		public static string 			PREFIX = "cubeeight_";

		public static GeometryVO create()
		{
			var vo = new GeometryVO();

			var p = new [] { float3(-1,-1,1), float3(1,-1,1), float3(1,1,1), float3(-1,1,1) };

			int i;
			for(i = 0; i < 8; i++)
			{
				vo.vertices.Add(p[i%4] * (i > 3 ? float3(1f) : float3(1,1,-1)));
			}

			vo.indices.Add(int3(0,2,1));
            vo.indices.Add(int3(0,3,2));
            vo.indices.Add(int3(1,2,6));
            vo.indices.Add(int3(6,5,1));
            vo.indices.Add(int3(4,5,6));
            vo.indices.Add(int3(6,7,4));
            vo.indices.Add(int3(2,3,6));
            vo.indices.Add(int3(6,3,7));
            vo.indices.Add(int3(0,7,3));
            vo.indices.Add(int3(0,4,7));
            vo.indices.Add(int3(0,1,5));
            vo.indices.Add(int3(0,5,4));

			return vo;
		}
	}

	

	public static class Cube
	{
		public static string 			PREFIX = "cube_";

		public static GeometryVO create()
		{
			var vo = new GeometryVO();
			
			  // Front face
			vo.vertices.Add(float3(-1, -1,  1));
			vo.vertices.Add(float3( 1, -1,  1));
			vo.vertices.Add(float3( 1,  1,  1));
			vo.vertices.Add(float3(-1,  1,  1));

			vo.texCoords.Add(float2(0,0));
			vo.texCoords.Add(float2(1,0));
			vo.texCoords.Add(float2(1,1));
			vo.texCoords.Add(float2(0,1));
			
			  
			  // Back face
			vo.vertices.Add(float3(-1, -1, -1));
			vo.vertices.Add(float3(-1,  1, -1));
			vo.vertices.Add(float3( 1,  1, -1));
			vo.vertices.Add(float3( 1, -1, -1));
			
			vo.texCoords.Add(float2(0,0));
			vo.texCoords.Add(float2(1,0));
			vo.texCoords.Add(float2(1,1));
			vo.texCoords.Add(float2(0,1));
			

			  // Top face
			vo.vertices.Add(float3(-1,  1, -1));
			vo.vertices.Add(float3(-1,  1,  1));
			vo.vertices.Add(float3( 1,  1,  1));
			vo.vertices.Add(float3( 1,  1, -1));
			
			vo.texCoords.Add(float2(0,0));
			vo.texCoords.Add(float2(1,0));
			vo.texCoords.Add(float2(1,1));
			vo.texCoords.Add(float2(0,1));
			

			  // Bottom face
			vo.vertices.Add(float3(-1, -1, -1));
			vo.vertices.Add(float3( 1, -1, -1));
			vo.vertices.Add(float3( 1, -1,  1));
			vo.vertices.Add(float3(-1, -1,  1));
			
			vo.texCoords.Add(float2(0,0));
			vo.texCoords.Add(float2(1,0));
			vo.texCoords.Add(float2(1,1));
			vo.texCoords.Add(float2(0,1));
			

			  // Right face
			vo.vertices.Add(float3( 1, -1, -1));
			vo.vertices.Add(float3( 1,  1, -1));
			vo.vertices.Add(float3( 1,  1,  1));
			vo.vertices.Add(float3( 1, -1,  1));
			
			vo.texCoords.Add(float2(0,0));
			vo.texCoords.Add(float2(1,0));
			vo.texCoords.Add(float2(1,1));
			vo.texCoords.Add(float2(0,1));
			

			  // Left face
			vo.vertices.Add(float3(-1, -1, -1));
			vo.vertices.Add(float3(-1, -1,  1));
			vo.vertices.Add(float3(-1,  1,  1));
			vo.vertices.Add(float3(-1,  1, -1));
			
			vo.texCoords.Add(float2(0,0));
			vo.texCoords.Add(float2(1,0));
			vo.texCoords.Add(float2(1,1));
			vo.texCoords.Add(float2(0,1));
			
			
			vo.indices.Add(int3(0,  1,  2));      vo.indices.Add(int3(0,  2,  3));    // front
			vo.indices.Add(int3(4,  5,  6));      vo.indices.Add(int3(4,  6,  7));    // back
			vo.indices.Add(int3(8,  9,  10));     vo.indices.Add(int3(8,  10, 11));   // top
			vo.indices.Add(int3(12, 13, 14));     vo.indices.Add(int3(12, 14, 15));   // bottom
			vo.indices.Add(int3(16, 17, 18));     vo.indices.Add(int3(16, 18, 19));   // right
			vo.indices.Add(int3(20, 21, 22));     vo.indices.Add(int3(20, 22, 23));    // left

			return vo;
		}
	}



	public static class Dodecahedron
	{
		public static string 			PREFIX = "dodecahedron_";

		public static GeometryVO create()
		{
			var vo = new GeometryVO();

			var gr = (1f + Math.Sqrt(5f)) / 2.0f; //golden ratio
			var hgr = 1f/gr;

			float3 _va,_vb,_vc,_vd,_ve,_vf,_vg,_vh,_vi,_vj,_vk,_vl,_vm,_vn,_vo,_vp,_vq,_vr,_vs,_vt;

			vo.vertices.Add(_va = float3( 	gr,		0,		hgr		)); // a 0
			vo.vertices.Add(_vb = float3( 	-gr,	0,		hgr		)); // b 1
			vo.vertices.Add(_vc = float3( 	-gr,	0,		-hgr	)); // c 2
			vo.vertices.Add(_vd = float3( 	gr,		0,		-hgr	)); // d 3

			vo.vertices.Add(_ve = float3( 	hgr,	gr,		0		)); // e 4
			vo.vertices.Add(_vf = float3( 	hgr,	-gr,	0		)); // f 5
			vo.vertices.Add(_vg = float3( 	-hgr,	-gr,	0		)); // g 6
			vo.vertices.Add(_vh = float3( 	-hgr,	gr,		0		)); // h 7

			vo.vertices.Add(_vi = float3( 	0,		hgr,	gr		)); // i 8
			vo.vertices.Add(_vj = float3( 	0,		hgr,	-gr		)); // j 9
			vo.vertices.Add(_vk = float3( 	0,		-hgr,	-gr		)); // k 10
			vo.vertices.Add(_vl = float3( 	0,		-hgr,	gr		)); // l 11

			vo.vertices.Add(_vm = float3( 	1,		1,		1		)); // m 12
			vo.vertices.Add(_vn = float3( 	1,		-1,		1		)); // n 13
			vo.vertices.Add(_vo = float3( 	-1,		-1,		1		)); // o 14
			vo.vertices.Add(_vp = float3( 	-1,		1,		1		)); // p 15

			vo.vertices.Add(_vq = float3( 	-1,		1,		-1		)); // q 16
			vo.vertices.Add(_vr = float3( 	1,		1,		-1		)); // r 17
			vo.vertices.Add(_vs = float3( 	1,		-1,		-1		)); // s 18
			vo.vertices.Add(_vt = float3( 	-1,		-1,		-1		)); // t 19

			var a=0; var b=1; var c=2; var d=3; var e=4; var f=5; var g=6; var h=7; var i=8; var j=9; var k=10;
			var l=11; var m=12; var n=13; var o=14; var p=15; var q=16; var r=17; var s=18; var t=19;
			
			var center0 = (_va+_vm+_ve+_vr+_vd) / 5;
			var center1 = (_vm+_vi+_vp+_vh+_ve) / 5;
			var center2 = (_va+_vn+_vl+_vi+_vm) / 5;
			var center3 = (_vf+_vn+_va+_vd+_vs) / 5;
			var center4 = (_vk+_vs+_vd+_vr+_vj) / 5;
			var center5 = (_vr+_ve+_vh+_vq+_vj) / 5;
			var center6 = (_vb+_vc+_vt+_vg+_vo) / 5; // back
			var center7 = (_vo+_vl+_vi+_vp+_vb) / 5; 
			var center8 = (_vb+_vp+_vh+_vq+_vc) / 5; 
			var center9 = (_vc+_vq+_vj+_vk+_vt) / 5; 
			var center10 = (_vt+_vk+_vs+_vf+_vg) / 5; 
			var center11 = (_vg+_vf+_vn+_vl+_vo) / 5;

			vo.vertices.Add(center0); // 20
			vo.vertices.Add(center1); // 21
			vo.vertices.Add(center2); // 22
			vo.vertices.Add(center3); // 23
			vo.vertices.Add(center4); // 24
			vo.vertices.Add(center5); // 25
			vo.vertices.Add(center6); // 26
			vo.vertices.Add(center7); // 27
			vo.vertices.Add(center8); // 28
			vo.vertices.Add(center9); // 29
			vo.vertices.Add(center10); // 30
			vo.vertices.Add(center11); // 31

			/*// UV
			var angle = (Math.PIf*2f)/5f;
			var uv1 = float2(Math.Sin(angle * 0f), Math.Cos(angle * 0f));
			var uv2 = float2(Math.Sin(angle * 1f), Math.Cos(angle * 1f));
			var uv3 = float2(Math.Sin(angle * 2f), Math.Cos(angle * 2f));
			var uv4 = float2(Math.Sin(angle * 3f), Math.Cos(angle * 3f));
			var uv5 = float2(Math.Sin(angle * 4f), Math.Cos(angle * 4f));
			
			var uvs = new float2[20];
			//var center0 = (_va+_vm+_ve+_vr+_vd) / 5;
			uvs[a] = uv1;
			uvs[m] = uv2;
			uvs[e] = uv3;
			uvs[r] = uv4;
			uvs[d] = uv5;
			//var center1 = (_vm+_vi+_vp+_vh+_ve) / 5;
			uvs[m] = uv1;
			uvs[i] = uv2;
			uvs[p] = uv3;
			uvs[h] = uv4;
			uvs[e] = uv5;
			//var center2 = (_va+_vn+_vl+_vi+_vm) / 5;
			uvs[a] = uv1;
			uvs[n] = uv2;
			uvs[l] = uv3;
			uvs[i] = uv4;
			uvs[m] = uv5;
			//var center3 = (_vf+_vn+_va+_vd+_vs) / 5;
			uvs[f] = uv1;
			uvs[n] = uv2;
			uvs[a] = uv3;
			uvs[d] = uv4;
			uvs[s] = uv5;
			//var center4 = (_vk+_vs+_vd+_vr+_vj) / 5;
			//var center5 = (_vr+_ve+_vh+_vq+_vj) / 5;
			//var center6 = (_vb+_vc+_vt+_vg+_vo) / 5; // back
			//var center7 = (_vo+_vl+_vi+_vp+_vb) / 5; 
			//var center8 = (_vb+_vp+_vh+_vq+_vc) / 5; 
			//var center9 = (_vc+_vq+_vj+_vk+_vt) / 5; 
			//var center10 = (_vt+_vk+_vs+_vf+_vg) / 5; 
			//var center11 = (_vg+_vf+_vn+_vl+_vo) / 5;
			
			//vo.texCoords.Add(uv1);
			*/


			//0
			vo.indices.Add(int3( 20,	e, m ));
			vo.indices.Add(int3( 20,	r, e ));
			vo.indices.Add(int3( 20,	d, r ));
			vo.indices.Add(int3( 20,	a, d ));
			vo.indices.Add(int3( 20,	m, a ));
			
			//1
			vo.indices.Add(int3( 21,	p, i ));
			vo.indices.Add(int3( 21,	h, p ));
			vo.indices.Add(int3( 21,	e, h ));
			vo.indices.Add(int3( 21,	m, e ));
			vo.indices.Add(int3( 21,	i, m ));
			//2
			vo.indices.Add(int3( 22,	n, a ));
			vo.indices.Add(int3( 22,	l, n ));
			vo.indices.Add(int3( 22,	i, l ));
			vo.indices.Add(int3( 22,	m, i ));
			vo.indices.Add(int3( 22,	a, m ));
			//3
			vo.indices.Add(int3( 23,	d, a ));
			vo.indices.Add(int3( 23,	s, d ));
			vo.indices.Add(int3( 23,	f, s ));
			vo.indices.Add(int3( 23,	n, f ));
			vo.indices.Add(int3( 23,	a, n ));
			//4
			vo.indices.Add(int3( 24,	r, d ));
			vo.indices.Add(int3( 24,	j, r ));
			vo.indices.Add(int3( 24,	k, j ));
			vo.indices.Add(int3( 24,	s, k ));
			vo.indices.Add(int3( 24,	d, s ));
			//5
			vo.indices.Add(int3( 25,	e, r ));
			vo.indices.Add(int3( 25,	h, e ));
			vo.indices.Add(int3( 25,	q, h ));
			vo.indices.Add(int3( 25,	j, q ));
			vo.indices.Add(int3( 25,	r, j ));
			
			//6 // back
			vo.indices.Add(int3( 26,	g,	o ));
			vo.indices.Add(int3( 26,	o,	b ));
			vo.indices.Add(int3( 26,	b,	c ));
			vo.indices.Add(int3( 26,	c,	t ));
			vo.indices.Add(int3( 26,	t,	g ));
			//7 
			vo.indices.Add(int3( 27,	l,	i ));
			vo.indices.Add(int3( 27,	i,	p ));
			vo.indices.Add(int3( 27,	p,	b ));
			vo.indices.Add(int3( 27,	b,	o ));
			vo.indices.Add(int3( 27,	o,	l ));
			//8
			vo.indices.Add(int3( 28,	b,	p ));
			vo.indices.Add(int3( 28,	p,	h ));
			vo.indices.Add(int3( 28,	h,	q ));
			vo.indices.Add(int3( 28,	q,	c ));
			vo.indices.Add(int3( 28,	c,	b ));
			//9
			vo.indices.Add(int3( 29,	c,	q ));
			vo.indices.Add(int3( 29,	q,	j ));
			vo.indices.Add(int3( 29,	j,	k ));
			vo.indices.Add(int3( 29,	k,	t ));
			vo.indices.Add(int3( 29,	t,	c ));
			//10
			vo.indices.Add(int3( 30,	t,	k ));
			vo.indices.Add(int3( 30,	k,	s ));
			vo.indices.Add(int3( 30,	s,	f ));
			vo.indices.Add(int3( 30,	f,	g ));
			vo.indices.Add(int3( 30,	g,	t ));
			//11
			vo.indices.Add(int3( 31,	g,	f ));
			vo.indices.Add(int3( 31,	f,	n ));
			vo.indices.Add(int3( 31,	n,	l ));
			vo.indices.Add(int3( 31,	l,	o ));
			vo.indices.Add(int3( 31,	o,	g ));

			//*/


			return vo;

		}
	}



	public static class Disk
	{
		public static string 			PREFIX = "disk_";

		public static GeometryVO create(int reso, float depth, float inner, float outer, bool flat = false)
		{
			var vo = new GeometryVO();

			float res = (float)reso;

			int i;
			float a;
			for(i = 0; i < reso; i++)
			{
				a = Math.PIf * 2.0f * ((float)i/res);
				vo.vertices.Add(float3(Math.Sin(a) * outer, Math.Cos(a) * outer, -depth));
				vo.vertices.Add(float3(Math.Sin(a) * inner, Math.Cos(a) * inner, -depth));
				if(i < reso-1)
				{
					vo.indices.Add(int3(i*2,i*2+2,i*2+1));
					vo.indices.Add(int3(i*2+1,i*2+2,i*2+3));
				}
			}
			vo.indices.Add(int3((reso-1) * 2, 0, (reso-1) * 2 + 1));
			vo.indices.Add(int3((reso-1) * 2 + 1, 0, 1));

			if(!flat)
			{
				var last = reso*2;
				for(i = 0; i < reso; i++)
				{
					a = Math.PIf * 2.0f * ((float)i/res);
					vo.vertices.Add(float3(Math.Sin(a) * inner, Math.Cos(a) * inner, depth));
					vo.vertices.Add(float3(Math.Sin(a) * outer, Math.Cos(a) * outer, depth));
					if(i < reso-1)
					{
						vo.indices.Add(int3(last+i*2, 	last+i*2+2, last+i*2+1));
						vo.indices.Add(int3(last+i*2+1, last+i*2+2, last+i*2+3));
					}
				}
				vo.indices.Add(int3(last+(reso-1) * 2, last, last+(reso-1) * 2 + 1));
				vo.indices.Add(int3(last+(reso-1) * 2 + 1, last, last+1));

				for(i = 0; i < reso-1; i++)
				{
					vo.indices.Add(int3(i*2, 			last+1+i*2,		i*2+2 ));
					vo.indices.Add(int3(last+1+i*2, 	last+3+i*2,		i*2+2 ));
					vo.indices.Add(int3(i*2+1, 			i*2+3,		last+2+i*2 ));
					vo.indices.Add(int3(last+i*2,	 	i*2+1,		last+2+i*2 ));
				}
				vo.indices.Add(int3((reso-1) * 2,  last+(reso-1) * 2 + 1, 0));
				vo.indices.Add(int3(last+(reso-1) * 2 + 1,  last+1, 0));
				vo.indices.Add(int3(last-1, 1, last));
				vo.indices.Add(int3(last+(reso-1) * 2,  last-1,	last));
			}

			return vo;
		}
	}


	public static class DiskSuper
	{
		public static string 			PREFIX = "disksuper_";

		public static GeometryVO create(int reso, float depth, float inner, float outer, float curves, float curveFrom, float curveTo)
		{
			var vo = new GeometryVO();

			float res = (float)reso;

			int i;
			float a, r, div;
			for(i = 0; i < reso; i++)
			{
				a = Math.PIf * 2.0f * ((float)i/res);
				div = (float)i/(float)reso;
				r = curveFrom + Math.Sin(div * Math.PIf * 2f * curves) * curveTo;
				vo.vertices.Add(float3(r*Math.Sin(a) * outer, r*Math.Cos(a) * outer, -depth));
				vo.vertices.Add(float3(r*Math.Sin(a) * inner, r*Math.Cos(a) * inner, -depth));
				if(i < reso-1)
				{
					vo.indices.Add(int3(i*2,i*2+2,i*2+1));
					vo.indices.Add(int3(i*2+1,i*2+2,i*2+3));
				}
			}
			vo.indices.Add(int3((reso-1) * 2, 0, (reso-1) * 2 + 1));
			vo.indices.Add(int3((reso-1) * 2 + 1, 0, 1));

			var last = reso*2;
			for(i = 0; i < reso; i++)
			{
				a = Math.PIf * 2.0f * ((float)i/res);
				div = (float)i/(float)reso;
				r = curveFrom + Math.Sin(div * Math.PIf * 2f * curves) * curveTo;
				vo.vertices.Add(float3(r*Math.Sin(a) * inner, r*Math.Cos(a) * inner, depth));
				vo.vertices.Add(float3(r*Math.Sin(a) * outer, r*Math.Cos(a) * outer, depth));
				if(i < reso-1)
				{
					vo.indices.Add(int3(last+i*2, 	last+i*2+2, last+i*2+1));
					vo.indices.Add(int3(last+i*2+1, last+i*2+2, last+i*2+3));
				}
			}
			vo.indices.Add(int3(last+(reso-1) * 2, last, last+(reso-1) * 2 + 1));
			vo.indices.Add(int3(last+(reso-1) * 2 + 1, last, last+1));

			for(i = 0; i < reso-1; i++)
			{
				vo.indices.Add(int3(i*2, 			last+1+i*2,		i*2+2 ));
				vo.indices.Add(int3(last+1+i*2, 	last+3+i*2,		i*2+2 ));
				vo.indices.Add(int3(i*2+1, 			i*2+3,		last+2+i*2 ));
				vo.indices.Add(int3(last+i*2,	 	i*2+1,		last+2+i*2 ));
			}
			vo.indices.Add(int3((reso-1) * 2,  last+(reso-1) * 2 + 1, 0));
			vo.indices.Add(int3(last+(reso-1) * 2 + 1,  last+1, 0));
			vo.indices.Add(int3(last-1, 1, last));
			vo.indices.Add(int3(last+(reso-1) * 2,  last-1,	last));

			return vo;
		}
	}


	public static class Flower
	{
		public static string 			PREFIX = "flower_";

		public static GeometryVO create(int reso0, int reso1, float depth)
		{
			var vo = new GeometryVO();

			var sphereClosed = IcoSphere.create(reso0);
			var sphereOpen = IcoSphere.create(reso0);
			var sphereMiddleClosed = IcoSphere.create(reso1);
			var sphereMiddleOpen = IcoSphere.create(reso1);

			float3 v;
			float curve;
			int addIndex = 0;
			for(var i = 0; i < sphereClosed.vertices.Count; i++)
			{
				v = sphereClosed.vertices[i];

				curve = 0.5f + Math.Sin((v.X+1f) * .5f * Math.PIf) * .5f;

				sphereClosed.vertices[i] *= float3(1f, .1f, .5f);
				sphereClosed.vertices[i] += float3(1f, -curve + .5f, 0);

				sphereClosed.vertices[i] = Vector.Transform(sphereClosed.vertices[i], Quaternion.RotationAxis(float3(0,0,1), Math.PIf*.45f)); // up
			}

			for(var i = 0; i < sphereOpen.vertices.Count; i++)
			{
				v = sphereOpen.vertices[i];

				curve = 0.5f + Math.Sin((v.X+1f) * .5f * Math.PIf) * .25f;

				sphereOpen.vertices[i] *= float3(1f, .1f, .5f);
				sphereOpen.vertices[i] += float3(1f, -curve + .5f, 0);

				sphereOpen.vertices[i] = Vector.Transform(sphereOpen.vertices[i], Quaternion.RotationAxis(float3(0,0,1), Math.PIf*.05f)); // up
			}




			for(var i = 0; i < sphereMiddleClosed.vertices.Count; i++)
			{
				v = sphereMiddleClosed.vertices[i];

				curve = 0.5f + Math.Sin((v.X+1f) * .5f * Math.PIf) * .5f;

				sphereMiddleClosed.vertices[i] *= float3(.75f, .05f, .25f);
				sphereMiddleClosed.vertices[i] += float3(.75f, -curve + .5f, 0);

				sphereMiddleClosed.vertices[i] = Vector.Transform(sphereMiddleClosed.vertices[i], Quaternion.RotationAxis(float3(0,0,1), Math.PIf*.5f)); // up
			}

			for(var i = 0; i < sphereMiddleOpen.vertices.Count; i++)
			{
				v = sphereMiddleOpen.vertices[i];

				curve = 0.5f + Math.Sin((v.X+1f) * .75f * Math.PIf) * .25f;

				sphereMiddleOpen.vertices[i] *= float3(.75f, .05f, .25f);
				sphereMiddleOpen.vertices[i] += float3(.75f, -curve + .5f, 0);

				sphereMiddleOpen.vertices[i] = Vector.Transform(sphereMiddleOpen.vertices[i], Quaternion.RotationAxis(float3(0,0,1), Math.PIf*.25f)); // up
			}




			var ang = 1f/5f;
			for(var j = 0; j < 5; j++)
			{
				for(var i = 0; i < sphereOpen.vertices.Count; i++)
				{
					sphereOpen.vertices[i] = Vector.Transform(sphereOpen.vertices[i], Quaternion.RotationAxis(float3(0,1,0), ang*Math.PIf*2f)); // rotation

					sphereClosed.vertices[i] = Vector.Transform(sphereClosed.vertices[i], Quaternion.RotationAxis(float3(0,1,0), ang*Math.PIf*2f)); // rotation

					vo.vertices.Add(sphereClosed.vertices[i]);

					vo.vertices2.Add(sphereOpen.vertices[i]);

					vo.id.Add(0);
				}

				for(var i = 0; i < sphereOpen.indices.Count; i++)
				{
					vo.indices.Add(int3(sphereOpen.indices[i].X+addIndex, sphereOpen.indices[i].Y+addIndex, sphereOpen.indices[i].Z+addIndex));
				}
				addIndex += sphereOpen.vertices.Count;
			}



			ang = 1f/3f;
			for(var j = 0; j < 3; j++)
			{
				for(var i = 0; i < sphereMiddleOpen.vertices.Count; i++)
				{
					sphereMiddleOpen.vertices[i] = Vector.Transform(sphereMiddleOpen.vertices[i], Quaternion.RotationAxis(float3(0,1,0), ang*Math.PIf*2f)); // rotation

					sphereMiddleClosed.vertices[i] = Vector.Transform(sphereMiddleClosed.vertices[i], Quaternion.RotationAxis(float3(0,1,0), ang*Math.PIf*2f)); // rotation

					vo.vertices.Add(sphereMiddleClosed.vertices[i]);

					vo.vertices2.Add(sphereMiddleOpen.vertices[i]);

					vo.id.Add(1);
				}

				for(var i = 0; i < sphereMiddleOpen.indices.Count; i++)
				{
					vo.indices.Add(int3(sphereMiddleOpen.indices[i].X+addIndex, sphereMiddleOpen.indices[i].Y+addIndex, sphereMiddleOpen.indices[i].Z+addIndex));
				}
				addIndex += sphereMiddleOpen.vertices.Count;
			}

			return vo;
		}
	}


	public static class Circle
	{
		public static string 			PREFIX = "circle_";

		public static GeometryVO create(int reso, float depth, bool flat = false)
		{
			var vo = new GeometryVO();

			float res = (float)reso;

			int i;
			float a, _x, _y;

			vo.vertices.Add(float3(0, 0, -depth));
			for(i = 0; i < reso; i++)
			{
				a = Math.PIf * 2.0f * ((float)i/res);
				_x = Math.Sin(a);
				_y = Math.Cos(a);
				vo.vertices.Add(float3(_x, _y, -depth));
				if(i < reso-1)
				{
					vo.indices.Add(int3(i+1,i+2,0));
				}
			}
			vo.indices.Add(int3(reso,1,0));

			if(!flat)
			{
				vo.vertices.Add(float3(0, 0, depth));
				var last = reso+1;
				for(i = 0; i < reso; i++)
				{
					a = Math.PIf * 2.0f * ((float)i/res);
					_x = Math.Sin(a);
					_y = Math.Cos(a);
					vo.vertices.Add(float3(_x, _y, depth));
					if(i < reso-1)
					{
						vo.indices.Add(int3(last+i+1, last, last+i+2));
					}
				}
				vo.indices.Add(int3(last+reso, last, last+1));


				for(i = 0; i < reso-1; i++)
				{
					vo.indices.Add(int3(i+1, last+i+2, i+2));
					vo.indices.Add(int3(last+1+i, last+i+2, i+1));
				}
				vo.indices.Add(int3(reso, last+1, 1));
				vo.indices.Add(int3(last+reso, last+1, reso));

			}

			return vo;
		}
	}


	public static class Hexacon
	{
		public static string 			PREFIX = "hexacon_";

		public static GeometryVO create(float up = 1f, float bottom = 1f)
		{
			var vo = new GeometryVO();

			int i;
			float a;
			for(i = 0; i < 6; i++)
			{
				a = Math.PIf * 2.0f * ((float)i/6f);
				vo.vertices.Add(float3(Math.Sin(a)*bottom,Math.Cos(a)*bottom,-1));
				vo.indices.Add(int3(i,i+1,6));
			}
			vo.vertices.Add(float3(0,0,-1)); // 6
			vo.indices.Add(int3(5,0,6));

			for(i = 0; i < 6; i++)
			{
				a = Math.PIf * 2.0f * ((float)i/6f);
				vo.vertices.Add(float3(Math.Sin(a)*up,Math.Cos(a)*up,1));
				vo.indices.Add(int3(i+7+1,i+7,13));
			}
			vo.vertices.Add(float3(0,0,1)); // 13
			vo.indices.Add(int3(7,12,13));

			for(i = 0; i < 7; i++)
			{
				vo.indices.Add(int3((i+1)%6,i%6, (7+i)%13));
				var ia = i+7;
				var ib = i+7+1;
				ia = ia < 13 ? ia : 7;
				ib = ib < 13 ? ib : 7;
				vo.indices.Add(int3(ia,ib,(i+1)%6));
			}

			return vo;
		}
	}


	public static class Tetrahedron
	{
		public static string 			PREFIX = "tetrahedron_";

		public static GeometryVO create()
		{
			var vo = new GeometryVO();


			var p = new [] { float3(-1,-1,1), float3(1,-1,-1), float3(1,1,1), float3(-1,1,-1) };

			for(var i = 0; i < 4; i++)
			{
				vo.vertices.Add(p[i]);
			}

			vo.indices.Add(int3(0,1,2));
            vo.indices.Add(int3(0,2,3));
            vo.indices.Add(int3(0,3,1));
          	vo.indices.Add(int3(2,1,3));


			return vo;
		}
	}


	public static class TetrahedronTruncate
	{
		public static string 			PREFIX = "tetrahedrontruncate_";

		private static Random rand = new Random(0);
		public static GeometryVO create(int seed, float range)
		{
			var vo = new GeometryVO();
			rand.SetSeed(seed);
			float cornerSize;
			var p = new [] { float3(-1,-1,1), float3(1,-1,-1), float3(1,1,1), float3(-1,1,-1) };

			float3 pA, pB, pC;
			cornerSize = .1f + range * rand.NextFloat();
			pA = p[0] + (p[1] - p[0]) * (cornerSize - .05f + .1f * rand.NextFloat());
			pB = p[0] + (p[2] - p[0]) * (cornerSize - .05f + .1f * rand.NextFloat());
			pC = p[0] + (p[3] - p[0]) * (cornerSize - .05f + .1f * rand.NextFloat());
			vo.vertices.Add(pA); vo.vertices.Add(pB); vo.vertices.Add(pC);
			vo.indices.Add(int3(0,1,2));

			cornerSize = .1f + range * rand.NextFloat();
			pA = p[1] + (p[3] - p[1]) * (cornerSize - .05f + .1f * rand.NextFloat());
			pB = p[1] + (p[2] - p[1]) * (cornerSize - .05f + .1f * rand.NextFloat());
			pC = p[1] + (p[0] - p[1]) * (cornerSize - .05f + .1f * rand.NextFloat());
			vo.vertices.Add(pA); vo.vertices.Add(pB); vo.vertices.Add(pC);
			vo.indices.Add(int3(3,4,5));

			cornerSize = .1f + range * rand.NextFloat();
			pA = p[2] + (p[0] - p[2]) * (cornerSize - .05f + .1f * rand.NextFloat());
			pB = p[2] + (p[1] - p[2]) * (cornerSize - .05f + .1f * rand.NextFloat());
			pC = p[2] + (p[3] - p[2]) * (cornerSize - .05f + .1f * rand.NextFloat());
			vo.vertices.Add(pA); vo.vertices.Add(pB); vo.vertices.Add(pC);
			vo.indices.Add(int3(6,7,8));

			cornerSize = .1f + range * rand.NextFloat();
			pA = p[3] + (p[2] - p[3]) * (cornerSize - .05f + .1f * rand.NextFloat());
			pB = p[3] + (p[1] - p[3]) * (cornerSize - .05f + .1f * rand.NextFloat());
			pC = p[3] + (p[0] - p[3]) * (cornerSize - .05f + .1f * rand.NextFloat());
			vo.vertices.Add(pA); vo.vertices.Add(pB); vo.vertices.Add(pC);
			vo.indices.Add(int3(9,10,11));

            var middle = (p[0] + p[1] + p[2]) / 3f;
			vo.vertices.Add(middle); //12
			vo.indices.Add(int3(1,0,12));
            vo.indices.Add(int3(6,1,12));
            vo.indices.Add(int3(7,6,12));
            vo.indices.Add(int3(4,7,12));
            vo.indices.Add(int3(5,4,12));
            vo.indices.Add(int3(0,5,12));
            middle = (p[0] + p[2] + p[3]) / 3f;
			vo.vertices.Add(middle); //13
			vo.indices.Add(int3(2,1,13));
            vo.indices.Add(int3(11,2,13));
            vo.indices.Add(int3(9,11,13));
            vo.indices.Add(int3(8,9,13));
            vo.indices.Add(int3(6,8,13));
            vo.indices.Add(int3(1,6,13));
            middle = (p[0] + p[1] + p[3]) / 3f;
			vo.vertices.Add(middle); //14
			vo.indices.Add(int3(0,2,14));
           	vo.indices.Add(int3(5,0,14));
            vo.indices.Add(int3(3,5,14));
            vo.indices.Add(int3(10,3,14));
            vo.indices.Add(int3(11,10,14));
			vo.indices.Add(int3(2,11,14));
			middle = (p[1] + p[2] + p[3]) / 3f;
			vo.vertices.Add(middle); //15
			vo.indices.Add(int3(4,3,15));
            vo.indices.Add(int3(7,4,15));
            vo.indices.Add(int3(8,7,15));
			vo.indices.Add(int3(9,8,15));
			vo.indices.Add(int3(10,9,15));
			vo.indices.Add(int3(3,10,15));

			return vo;
		}
	}


}