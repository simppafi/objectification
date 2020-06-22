using Uno;
using Uno.Collections;
using Uno.Graphics;

namespace simppafi.Geometry
{
	public class MarchingData
	{
		public List<float3> vertices = new List<float3>();
		//public List<float3> normals = new List<float3>();
		public List<int>  	faces = new List<int>();
	}

	public class MarchingVolume
	{
		public float[] 		data;
		public int[] 		dims;
	}

	public static class MarchingCubes
	{

		

		public static void Reset()
		{
			volume = new MarchingVolume();
			result = new MarchingData();
		}

		private static Random rand = new Random(1);
		private static float4 p1;
		private static float4 p2;
		private static float4 p3;

		private static float4[] ps;

		public static MarchingData GetTorus()
		{
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f}
					 				};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Torus));
		}

		public static MarchingData GetTorus88()
		{
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f}
					 				};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Torus88));
		}

		public static MarchingData GetTorus82()
		{
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f}
					 				};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Torus82));
		}

		public static MarchingData GetTry(float4 _p1, float4 _p2, float4 _p3)
		{
			p1 = _p1;
			p2 = _p2;
			p3 = _p3;
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.095f},
					    				new []{-2.0f, 2.0f, 0.095f},
					    				new []{-2.0f, 2.0f, 0.095f}
					 				};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Try));
		}

		public static MarchingData Get16balls(float4[] _ps)
		{
			ps = _ps;
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.065f},//.95
					    				new []{-2.0f, 2.0f, 0.065f},
					    				new []{-2.0f, 2.0f, 0.065f}
					 				};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, balls16));
		}


		public static MarchingData GetRoundBox()
		{
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f}
					 				};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, RoundBox));
		}

		public static MarchingData GetSphere()
		{
		    float[][] dims = new []{	new []{-2.0f, 2.0f, 0.25f},
					    				new []{-2.0f, 2.0f, 0.25f},
					    				new []{-2.0f, 2.0f, 0.25f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Sphere));
		}

		public static MarchingData GetHyperelliptic()
		{
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.05f},
					    				new []{-2.0f, 2.0f, 0.05f},
					    				new []{-2.0f, 2.0f, 0.05f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Hyperelliptic));
		}

		public static MarchingData GetNodalCubic()
		{
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.15f},
					    				new []{-2.0f, 2.0f, 0.15f},
					    				new []{-2.0f, 2.0f, 0.15f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, NodalCubic));
		}

		public static MarchingData GetGoursat()
		{
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Goursat));
		}

		public static MarchingData GetHeart()
		{
			float[][] dims = new []{	new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f},
					    				new []{-2.0f, 2.0f, 0.1f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Heart));
		}

		public static MarchingData GetNordstrand()
		{
			float[][] dims = new []{	new []{-2f, 2f, 0.05f},
					    				new []{-2f, 2f, 0.05f},
					    				new []{-2f, 2f, 0.05f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Nordstrand));
		}

		public static MarchingData GetSine()
		{
			float[][] dims = new []{	new []{-2f, 2f, Math.PIf/8f},
					    				new []{-2f, 2f, Math.PIf/8f},
					    				new []{-2f, 2f, Math.PIf/8f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Sine));
		}

		public static MarchingData GetPerlinNoise()
		{
			float[][] dims = new []{	new []{-2f, 2f, 0.5f},
					    				new []{-2f, 2f, 0.5f},
					    				new []{-2f, 2f, 0.5f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, PerlinNoise));
		}

		public static MarchingData GetAsteroid()
		{
			float[][] dims = new []{	new []{-2f, 2f, 0.08f},
					    				new []{-2f, 2f, 0.08f},
					    				new []{-2f, 2f, 0.08f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Asteroid));
		}

		public static MarchingData GetTerrain()
		{
			float[][] dims = new []{	new []{-2f, 2f, 0.05f},
					    				new []{-2f, 2f, 0.05f},
					    				new []{-2f, 2f, 0.05f}
					    			};
			return simppafi.Geometry.MarchingCubes.GetData(simppafi.Geometry.MarchingCubes.makeVolume(dims, Terrain));
		}
		

		private static float lengthN(float2 p, float n)
		{
			 return Math.Pow( (Math.Pow(p.X, n)+Math.Pow(p.Y, n)) , (1f/n) );
		}


		private static float Torus(float3 p)
		{
			//return Math.Pow(1.0f - Math.Sqrt(x*x + y*y), 2f) + z*z - 0.25f;
			float2 t = float2(.66f,.35f);
			float2 q = float2(Vector.Length(p.XZ)-t.X,p.Y);
  			return Vector.Length(q)-t.Y;
		}

		private static float Torus88(float3 p)
		{
			float2 t = float2(.66f,.35f);
			
  			float2 q = float2(lengthN(p.XZ, 8f)-t.X,p.Y);
  			return lengthN(q, 8f)-t.Y;
		}

		private static float Torus82(float3 p)
		{
			float2 t = float2(.66f,.35f);
			
  			var q = float2(lengthN(p.XZ, 2f)-t.X,p.Y);
  			return lengthN(q,8f)-t.Y;
		}

		private static float RoundBox(float3 p)
		{
			float3 b = float3(0.5f,0.5f,0.5f);
  			float r = .2f;

  			return Vector.Length(Math.Max(Math.Abs(p)-b,0.0f))-r;
		}

		private static float Try(float3 p)
		{
			
			var dx1 = p.X-p1.X;
			var dy1 = p.Y-p1.Y;
			var dz1 = p.Z-p1.Z;

			var s1 = ( dx1*dx1 + dy1*dy1 + dz1*dz1 ) * p1.W;

			var dx2 = p.X-p2.X;
			var dy2 = p.Y-p2.Y;
			var dz2 = p.Z-p2.Z;

			var s2 = ( dx2*dx2 + dy2*dy2 + dz2*dz2 ) * p2.W;

			var dx3 = p.X-p3.X;
			var dy3 = p.Y-p3.Y;
			var dz3 = p.Z-p3.Z;

			var s3 = ( dx3*dx3 + dy3*dy3 + dz3*dz3 ) * p3.W;

			
			var res = sminPol(s3, sminPol(s1,s2, .5f), .5f);
			
			
			var time = (float)Fuse.Time.FrameTime*2f;
			//var move = time - Math.Floor(time);

			//var dist = Vector.Length(float2(x,y)) ;// * .75f;//Math.Sin(time); 
			//var dist2 = Vector.Length(float2(y,z)) ;
			var dist = Vector.Length(p);

			if(dist < 1.85f && dist > 1.25f)// && dist2 < 1.85f && dist2 > 1.25f)
			{
				res *= 1f + 2f*Math.Sin(p.Y*Math.PIf - time) + .5f; //Math.Clamp(10f + 10f*Math.Sin(y*10f), 0f, 15f) * 10f + 1f;

				res *= 1f + Math.Sin(p.X*Math.PIf*2f + time) + .5f;

				res *= 1f + Math.Sin(p.Z*Math.PIf*2f) + .5f;

				res = sminPol(res, sminPol(s3, sminPol(s1,s2, .5f), .5f), .5f);
			}
			else{
				 
				res *= 1f-(dist-1.85f);
			}

			return res-1f;
		}

		private static float balls16(float3 p)
		{

			var dist = Vector.Length(p);
			
			//p = p * Math.Sin(p.Y);//(.75f + rand.NextFloat3() * .5f);
			//p *= dist;
			if(dist < .7f)
			{
				p *= .5f;//float3(0f,0f,0f);
			}
			
			//var dist2 = Vector.Length(p.XZ);
			//if(dist2 < .5f)
			//{
			//	p = float3(0f);
			//}

			var _s = new float[ps.Length];
			for(var i = 0; i < ps.Length; i++)
			{
				var dx1 = p.X-ps[i].X;
				var dy1 = p.Y-ps[i].Y;
				var dz1 = p.Z-ps[i].Z;
				_s[i] = ( dx1*dx1 + dy1*dy1 + dz1*dz1 ) * ps[i].W;
			}

			var res = 	
						sminPol(_s[15], 
						sminPol(_s[14], 
						sminPol(_s[13], 
						sminPol(_s[12], 
						sminPol(_s[11], 
						sminPol(_s[10], 
						sminPol(_s[9], 
						sminPol(_s[8], 
						sminPol(_s[7], 
						sminPol(_s[6], 
						sminPol(_s[5], 
						sminPol(_s[4], 
						sminPol(_s[3], 
						sminPol(_s[2], 
						sminPol(_s[0],_s[1], .5f), 
						.5f), 
						.5f), 
						.5f), 
						.5f),
						.5f),
						.5f),
						.5f), 
						.5f), 
						.5f), 
						.5f), 
						.5f), 
						.5f), 
						.5f), 
						.5f);


			return res-1f;
		}
		
		// power smooth min (k = 8);
		private static float sminPow( float a, float b, float k )
		{
		    a = Math.Pow( a, k ); 
		    b = Math.Pow( b, k );
		    return Math.Pow( (a*b)/(a+b), 1.0f/k );
		}

		// polynomial smooth min (k = 0.1);
		private static float sminPol( float a, float b, float k )
		{
		    float h = Math.Clamp( 0.5f+0.5f*(b-a)/k, 0.0f, 1.0f );
		    return Math.Lerp( b, a, h ) - k*h*(1.0f-h);
		}

		// polynomial smooth min (k = 0.1);
		private static float sminExp( float a, float b, float k )
		{
		    float res = Math.Exp( -k*a ) + Math.Exp( -k*b );
    		return -Math.Log( res )/k;
		}


		private static float Sphere(float3 p)
		{
			return p.X*p.X + p.Y*p.Y + p.Z*p.Z - 1.0f;
		}

		private static float Hyperelliptic(float3 p)
		{
			return Math.Pow( Math.Pow(p.X, 6f) + Math.Pow(p.Y, 6f) + Math.Pow(p.Z, 6f), 1.0f/6.0f ) - 1.0f;
		}

		private static float NodalCubic(float3 p)
		{
			 return p.X*p.Y + p.Y*p.Z + p.Z*p.X + p.X*p.Y*p.Z;
		}

		private static float Goursat(float3 p)
		{
			 return Math.Pow(p.X,4f) + Math.Pow(p.Y,4f) + Math.Pow(p.Z,4f) - 1.5f * (p.X*p.X  + p.Y*p.Y + p.Z*p.Z) + 1f;
		}

		private static float Heart(float3 p)
		{
		 	p.Y *= 1.5f;
	      	p.Z *= 1.5f;
	      	return Math.Pow(2f*p.X*p.X+p.Y*p.Y+2f*p.Z*p.Z-1f, 3f) - 0.1f * p.Z*p.Z*p.Y*p.Y*p.Y - p.Y*p.Y*p.Y*p.X*p.X;
  		}

  		private static float Nordstrand(float3 p)
		{
		    return 25f * (Math.Pow(p.X,3f)*(p.Y+p.Z) + Math.Pow(p.Y,3f)*(p.X+p.Z) + Math.Pow(p.Z,3f)*(p.X+p.Y)) +
		        50f * (p.X*p.X*p.Y*p.Y + p.X*p.X*p.Z*p.Z + p.Y*p.Y*p.Z*p.Z) -
		        125f * (p.X*p.X*p.Y*p.Z + p.Y*p.Y*p.X*p.Z+p.Z*p.Z*p.X*p.Y) +
		        60f*p.X*p.Y*p.Z -
		        4f*(p.X*p.Y+p.X*p.Z+p.Y*p.Z);
		}

		private static float Sine(float3 p)
		{
			return Math.Sin(p.X) + Math.Sin(p.Y) + Math.Sin(p.Z);
		}
		
		private static float PerlinNoise(float3 p)
		{
			return noise(p) - 0.5f;
		}

		private static float Asteroid(float3 p)
		{
			 return (p.X*p.X + p.Y*p.Y + p.Z*p.Z) - noise(p*2f);
		}

		private static float Terrain(float3 p)
		{
			 return  p.Y + noise(float3(p.X*2f+5f,p.Y*2f+3f,p.Z*2f+0.6f));
		}
		

		
		private static float noise(float3 p) 
		{

		   var z = new int[512];//new Array(512)
		   var permutation = new [] { 151,160,137,91,90,15,
		   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
		   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
		   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
		   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
		   102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
		   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
		   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
		   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
		   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
		   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
		   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
		   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
		   };

		   for (var i=0; i < 256 ; i++) 
		   {
			 	z[256+i] = z[i] = permutation[i]; 
			}

			var X = (int)Math.Floor(p.X) & 255;                  // FIND UNIT CUBE THAT
			var Y = (int)Math.Floor(p.Y) & 255;                  // CONTAINS POINT.
			var Z = (int)Math.Floor(p.Z) & 255;
			p.X -= Math.Floor(p.X);                                // FIND RELATIVE X,Y,Z
			p.Y -= Math.Floor(p.Y);                                // OF POINT IN CUBE.
			p.Z -= Math.Floor(p.Z);
			
			var u = fade(p.X);                                // COMPUTE FADE CURVES
			var v = fade(p.Y);                                // FOR EACH OF X,Y,Z.
			var w = fade(p.Z);

			var A = z[X]+Y;
			var AA = z[A]+Z;
			var AB = z[A+1]+Z;      // HASH COORDINATES OF

			var B = z[X+1]+Y;
			var BA = z[B]+Z;
			var BB = z[B+1]+Z;      // THE 8 CUBE CORNERS,

			return scale(lerp(w, lerp(v, lerp(u, grad(z[AA  ], p.X  , p.Y  , p.Z   ),  // AND ADD
			                             grad(z[BA  ], p.X-1f, p.Y  , p.Z   )), // BLENDED
			                     lerp(u, grad(z[AB  ], p.X  , p.Y-1f, p.Z   ),  // RESULTS
			                             grad(z[BB  ], p.X-1f, p.Y-1f, p.Z   ))),// FROM  8
			             lerp(v, lerp(u, grad(z[AA+1], p.X  , p.Y  , p.Z-1f ),  // CORNERS
			                             grad(z[BA+1], p.X-1f, p.Y  , p.Z-1f )), // OF CUBE
			                     lerp(u, grad(z[AB+1], p.X  , p.Y-1f, p.Z-1f ),
			                             grad(z[BB+1], p.X-1f, p.Y-1f, p.Z-1f )))));
		}



		private static float fade(float t) { return t * t * t * (t * (t * 6f - 15f) + 10f); }
	   	private static float lerp(float t, float a, float b) { return a + t * (b - a); }
	   	private static float grad(int hash, float x, float y, float z) {
	      int h = hash & 15;                      // CONVERT LO 4 BITS OF HASH CODE
	      float u = h<8 ? x : y,                 // INTO 12 GRADIENT DIRECTIONS.
	             v = h<4 ? y : h==12||h==14 ? x : z;
	      return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
	   } 
	   private static float scale(float n) { return (1f + n)/2f; }

		


		private static int[] edgeTable = new [] {
		      0x0  , 0x109, 0x203, 0x30a, 0x406, 0x50f, 0x605, 0x70c,
		      0x80c, 0x905, 0xa0f, 0xb06, 0xc0a, 0xd03, 0xe09, 0xf00,
		      0x190, 0x99 , 0x393, 0x29a, 0x596, 0x49f, 0x795, 0x69c,
		      0x99c, 0x895, 0xb9f, 0xa96, 0xd9a, 0xc93, 0xf99, 0xe90,
		      0x230, 0x339, 0x33 , 0x13a, 0x636, 0x73f, 0x435, 0x53c,
		      0xa3c, 0xb35, 0x83f, 0x936, 0xe3a, 0xf33, 0xc39, 0xd30,
		      0x3a0, 0x2a9, 0x1a3, 0xaa , 0x7a6, 0x6af, 0x5a5, 0x4ac,
		      0xbac, 0xaa5, 0x9af, 0x8a6, 0xfaa, 0xea3, 0xda9, 0xca0,
		      0x460, 0x569, 0x663, 0x76a, 0x66 , 0x16f, 0x265, 0x36c,
		      0xc6c, 0xd65, 0xe6f, 0xf66, 0x86a, 0x963, 0xa69, 0xb60,
		      0x5f0, 0x4f9, 0x7f3, 0x6fa, 0x1f6, 0xff , 0x3f5, 0x2fc,
		      0xdfc, 0xcf5, 0xfff, 0xef6, 0x9fa, 0x8f3, 0xbf9, 0xaf0,
		      0x650, 0x759, 0x453, 0x55a, 0x256, 0x35f, 0x55 , 0x15c,
		      0xe5c, 0xf55, 0xc5f, 0xd56, 0xa5a, 0xb53, 0x859, 0x950,
		      0x7c0, 0x6c9, 0x5c3, 0x4ca, 0x3c6, 0x2cf, 0x1c5, 0xcc ,
		      0xfcc, 0xec5, 0xdcf, 0xcc6, 0xbca, 0xac3, 0x9c9, 0x8c0,
		      0x8c0, 0x9c9, 0xac3, 0xbca, 0xcc6, 0xdcf, 0xec5, 0xfcc,
		      0xcc , 0x1c5, 0x2cf, 0x3c6, 0x4ca, 0x5c3, 0x6c9, 0x7c0,
		      0x950, 0x859, 0xb53, 0xa5a, 0xd56, 0xc5f, 0xf55, 0xe5c,
		      0x15c, 0x55 , 0x35f, 0x256, 0x55a, 0x453, 0x759, 0x650,
		      0xaf0, 0xbf9, 0x8f3, 0x9fa, 0xef6, 0xfff, 0xcf5, 0xdfc,
		      0x2fc, 0x3f5, 0xff , 0x1f6, 0x6fa, 0x7f3, 0x4f9, 0x5f0,
		      0xb60, 0xa69, 0x963, 0x86a, 0xf66, 0xe6f, 0xd65, 0xc6c,
		      0x36c, 0x265, 0x16f, 0x66 , 0x76a, 0x663, 0x569, 0x460,
		      0xca0, 0xda9, 0xea3, 0xfaa, 0x8a6, 0x9af, 0xaa5, 0xbac,
		      0x4ac, 0x5a5, 0x6af, 0x7a6, 0xaa , 0x1a3, 0x2a9, 0x3a0,
		      0xd30, 0xc39, 0xf33, 0xe3a, 0x936, 0x83f, 0xb35, 0xa3c,
		      0x53c, 0x435, 0x73f, 0x636, 0x13a, 0x33 , 0x339, 0x230,
		      0xe90, 0xf99, 0xc93, 0xd9a, 0xa96, 0xb9f, 0x895, 0x99c,
		      0x69c, 0x795, 0x49f, 0x596, 0x29a, 0x393, 0x99 , 0x190,
		      0xf00, 0xe09, 0xd03, 0xc0a, 0xb06, 0xa0f, 0x905, 0x80c,
		      0x70c, 0x605, 0x50f, 0x406, 0x30a, 0x203, 0x109, 0x0  	};

		private static int[][] triTable = new [] {
		      new int[0],
		      new [] {0, 8, 3},
		      new [] {0, 1, 9},
		      new [] {1, 8, 3, 9, 8, 1},
		      new [] {1, 2, 10},
		      new [] {0, 8, 3, 1, 2, 10},
		      new [] {9, 2, 10, 0, 2, 9},
		      new [] {2, 8, 3, 2, 10, 8, 10, 9, 8},
		      new [] {3, 11, 2},
		      new [] {0, 11, 2, 8, 11, 0},
		      new [] {1, 9, 0, 2, 3, 11},
		      new [] {1, 11, 2, 1, 9, 11, 9, 8, 11},
		      new [] {3, 10, 1, 11, 10, 3},
		      new [] {0, 10, 1, 0, 8, 10, 8, 11, 10},
		      new [] {3, 9, 0, 3, 11, 9, 11, 10, 9},
		      new [] {9, 8, 10, 10, 8, 11},
		      new [] {4, 7, 8},
		      new [] {4, 3, 0, 7, 3, 4},
		      new [] {0, 1, 9, 8, 4, 7},
		      new [] {4, 1, 9, 4, 7, 1, 7, 3, 1},
		      new [] {1, 2, 10, 8, 4, 7},
		      new [] {3, 4, 7, 3, 0, 4, 1, 2, 10},
		      new [] {9, 2, 10, 9, 0, 2, 8, 4, 7},
		      new [] {2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4},
		      new [] {8, 4, 7, 3, 11, 2},
		      new [] {11, 4, 7, 11, 2, 4, 2, 0, 4},
		      new [] {9, 0, 1, 8, 4, 7, 2, 3, 11},
		      new [] {4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1},
		      new [] {3, 10, 1, 3, 11, 10, 7, 8, 4},
		      new [] {1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4},
		      new [] {4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3},
		      new [] {4, 7, 11, 4, 11, 9, 9, 11, 10},
		      new [] {9, 5, 4},
		      new [] {9, 5, 4, 0, 8, 3},
		      new [] {0, 5, 4, 1, 5, 0},
		      new [] {8, 5, 4, 8, 3, 5, 3, 1, 5},
		      new [] {1, 2, 10, 9, 5, 4},
		      new [] {3, 0, 8, 1, 2, 10, 4, 9, 5},
		      new [] {5, 2, 10, 5, 4, 2, 4, 0, 2},
		      new [] {2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8},
		      new [] {9, 5, 4, 2, 3, 11},
		      new [] {0, 11, 2, 0, 8, 11, 4, 9, 5},
		      new [] {0, 5, 4, 0, 1, 5, 2, 3, 11},
		      new [] {2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5},
		      new [] {10, 3, 11, 10, 1, 3, 9, 5, 4},
		      new [] {4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10},
		      new [] {5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3},
		      new [] {5, 4, 8, 5, 8, 10, 10, 8, 11},
		      new [] {9, 7, 8, 5, 7, 9},
		      new [] {9, 3, 0, 9, 5, 3, 5, 7, 3},
		      new [] {0, 7, 8, 0, 1, 7, 1, 5, 7},
		      new [] {1, 5, 3, 3, 5, 7},
		      new [] {9, 7, 8, 9, 5, 7, 10, 1, 2},
		      new [] {10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3},
		      new [] {8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2},
		      new [] {2, 10, 5, 2, 5, 3, 3, 5, 7},
		      new [] {7, 9, 5, 7, 8, 9, 3, 11, 2},
		      new [] {9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11},
		      new [] {2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7},
		      new [] {11, 2, 1, 11, 1, 7, 7, 1, 5},
		      new [] {9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11},
		      new [] {5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0},
		      new [] {11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0},
		      new [] {11, 10, 5, 7, 11, 5},
		      new [] {10, 6, 5},
		      new [] {0, 8, 3, 5, 10, 6},
		      new [] {9, 0, 1, 5, 10, 6},
		      new [] {1, 8, 3, 1, 9, 8, 5, 10, 6},
		      new [] {1, 6, 5, 2, 6, 1},
		      new [] {1, 6, 5, 1, 2, 6, 3, 0, 8},
		      new [] {9, 6, 5, 9, 0, 6, 0, 2, 6},
		      new [] {5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8},
		      new [] {2, 3, 11, 10, 6, 5},
		      new [] {11, 0, 8, 11, 2, 0, 10, 6, 5},
		      new [] {0, 1, 9, 2, 3, 11, 5, 10, 6},
		      new [] {5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11},
		      new [] {6, 3, 11, 6, 5, 3, 5, 1, 3},
		      new [] {0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6},
		      new [] {3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9},
		      new [] {6, 5, 9, 6, 9, 11, 11, 9, 8},
		      new [] {5, 10, 6, 4, 7, 8},
		      new [] {4, 3, 0, 4, 7, 3, 6, 5, 10},
		      new [] {1, 9, 0, 5, 10, 6, 8, 4, 7},
		      new [] {10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4},
		      new [] {6, 1, 2, 6, 5, 1, 4, 7, 8},
		      new [] {1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7},
		      new [] {8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6},
		      new [] {7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9},
		      new [] {3, 11, 2, 7, 8, 4, 10, 6, 5},
		      new [] {5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11},
		      new [] {0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6},
		      new [] {9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6},
		      new [] {8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6},
		      new [] {5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11},
		      new [] {0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7},
		      new [] {6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9},
		      new [] {10, 4, 9, 6, 4, 10},
		      new [] {4, 10, 6, 4, 9, 10, 0, 8, 3},
		      new [] {10, 0, 1, 10, 6, 0, 6, 4, 0},
		      new [] {8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10},
		      new [] {1, 4, 9, 1, 2, 4, 2, 6, 4},
		      new [] {3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4},
		      new [] {0, 2, 4, 4, 2, 6},
		      new [] {8, 3, 2, 8, 2, 4, 4, 2, 6},
		      new [] {10, 4, 9, 10, 6, 4, 11, 2, 3},
		      new [] {0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6},
		      new [] {3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10},
		      new [] {6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1},
		      new [] {9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3},
		      new [] {8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1},
		      new [] {3, 11, 6, 3, 6, 0, 0, 6, 4},
		      new [] {6, 4, 8, 11, 6, 8},
		      new [] {7, 10, 6, 7, 8, 10, 8, 9, 10},
		      new [] {0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10},
		      new [] {10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0},
		      new [] {10, 6, 7, 10, 7, 1, 1, 7, 3},
		      new [] {1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7},
		      new [] {2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9},
		      new [] {7, 8, 0, 7, 0, 6, 6, 0, 2},
		      new [] {7, 3, 2, 6, 7, 2},
		      new [] {2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7},
		      new [] {2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7},
		      new [] {1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11},
		      new [] {11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1},
		      new [] {8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6},
		      new [] {0, 9, 1, 11, 6, 7},
		      new [] {7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0},
		      new [] {7, 11, 6},
		      new [] {7, 6, 11},
		      new [] {3, 0, 8, 11, 7, 6},
		      new [] {0, 1, 9, 11, 7, 6},
		      new [] {8, 1, 9, 8, 3, 1, 11, 7, 6},
		      new [] {10, 1, 2, 6, 11, 7},
		      new [] {1, 2, 10, 3, 0, 8, 6, 11, 7},
		      new [] {2, 9, 0, 2, 10, 9, 6, 11, 7},
		      new [] {6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8},
		      new [] {7, 2, 3, 6, 2, 7},
		      new [] {7, 0, 8, 7, 6, 0, 6, 2, 0},
		      new [] {2, 7, 6, 2, 3, 7, 0, 1, 9},
		      new [] {1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6},
		      new [] {10, 7, 6, 10, 1, 7, 1, 3, 7},
		      new [] {10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8},
		      new [] {0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7},
		      new [] {7, 6, 10, 7, 10, 8, 8, 10, 9},
		      new [] {6, 8, 4, 11, 8, 6},
		      new [] {3, 6, 11, 3, 0, 6, 0, 4, 6},
		      new [] {8, 6, 11, 8, 4, 6, 9, 0, 1},
		      new [] {9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6},
		      new [] {6, 8, 4, 6, 11, 8, 2, 10, 1},
		      new [] {1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6},
		      new [] {4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9},
		      new [] {10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3},
		      new [] {8, 2, 3, 8, 4, 2, 4, 6, 2},
		      new [] {0, 4, 2, 4, 6, 2},
		      new [] {1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8},
		      new [] {1, 9, 4, 1, 4, 2, 2, 4, 6},
		      new [] {8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1},
		      new [] {10, 1, 0, 10, 0, 6, 6, 0, 4},
		      new [] {4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3},
		      new [] {10, 9, 4, 6, 10, 4},
		      new [] {4, 9, 5, 7, 6, 11},
		      new [] {0, 8, 3, 4, 9, 5, 11, 7, 6},
		      new [] {5, 0, 1, 5, 4, 0, 7, 6, 11},
		      new [] {11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5},
		      new [] {9, 5, 4, 10, 1, 2, 7, 6, 11},
		      new [] {6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5},
		      new [] {7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2},
		      new [] {3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6},
		      new [] {7, 2, 3, 7, 6, 2, 5, 4, 9},
		      new [] {9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7},
		      new [] {3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0},
		      new [] {6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8},
		      new [] {9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7},
		      new [] {1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4},
		      new [] {4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10},
		      new [] {7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10},
		      new [] {6, 9, 5, 6, 11, 9, 11, 8, 9},
		      new [] {3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5},
		      new [] {0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11},
		      new [] {6, 11, 3, 6, 3, 5, 5, 3, 1},
		      new [] {1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6},
		      new [] {0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10},
		      new [] {11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5},
		      new [] {6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3},
		      new [] {5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2},
		      new [] {9, 5, 6, 9, 6, 0, 0, 6, 2},
		      new [] {1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8},
		      new [] {1, 5, 6, 2, 1, 6},
		      new [] {1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6},
		      new [] {10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0},
		      new [] {0, 3, 8, 5, 6, 10},
		      new [] {10, 5, 6},
		      new [] {11, 5, 10, 7, 5, 11},
		      new [] {11, 5, 10, 11, 7, 5, 8, 3, 0},
		      new [] {5, 11, 7, 5, 10, 11, 1, 9, 0},
		      new [] {10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1},
		      new [] {11, 1, 2, 11, 7, 1, 7, 5, 1},
		      new [] {0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11},
		      new [] {9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7},
		      new [] {7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2},
		      new [] {2, 5, 10, 2, 3, 5, 3, 7, 5},
		      new [] {8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5},
		      new [] {9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2},
		      new [] {9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2},
		      new [] {1, 3, 5, 3, 7, 5},
		      new [] {0, 8, 7, 0, 7, 1, 1, 7, 5},
		      new [] {9, 0, 3, 9, 3, 5, 5, 3, 7},
		      new [] {9, 8, 7, 5, 9, 7},
		      new [] {5, 8, 4, 5, 10, 8, 10, 11, 8},
		      new [] {5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0},
		      new [] {0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5},
		      new [] {10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4},
		      new [] {2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8},
		      new [] {0, 4, 11, 0, 11, 3, 4, 5, 11, 2, 11, 1, 5, 1, 11},
		      new [] {0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5},
		      new [] {9, 4, 5, 2, 11, 3},
		      new [] {2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4},
		      new [] {5, 10, 2, 5, 2, 4, 4, 2, 0},
		      new [] {3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9},
		      new [] {5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2},
		      new [] {8, 4, 5, 8, 5, 3, 3, 5, 1},
		      new [] {0, 4, 5, 1, 0, 5},
		      new [] {8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5},
		      new [] {9, 4, 5},
		      new [] {4, 11, 7, 4, 9, 11, 9, 10, 11},
		      new [] {0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11},
		      new [] {1, 10, 11, 1, 11, 4, 1, 4, 0, 7, 4, 11},
		      new [] {3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4},
		      new [] {4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2},
		      new [] {9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3},
		      new [] {11, 7, 4, 11, 4, 2, 2, 4, 0},
		      new [] {11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4},
		      new [] {2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9},
		      new [] {9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7},
		      new [] {3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10},
		      new [] {1, 10, 2, 8, 7, 4},
		      new [] {4, 9, 1, 4, 1, 7, 7, 1, 3},
		      new [] {4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1},
		      new [] {4, 0, 3, 7, 4, 3},
		      new [] {4, 8, 7},
		      new [] {9, 10, 8, 10, 11, 8},
		      new [] {3, 0, 9, 3, 9, 11, 11, 9, 10},
		      new [] {0, 1, 10, 0, 10, 8, 8, 10, 11},
		      new [] {3, 1, 10, 11, 3, 10},
		      new [] {1, 2, 11, 1, 11, 9, 9, 11, 8},
		      new [] {3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9},
		      new [] {0, 2, 11, 8, 0, 11},
		      new [] {3, 2, 11},
		      new [] {2, 3, 8, 2, 8, 10, 10, 8, 9},
		      new [] {9, 10, 2, 0, 9, 2},
		      new [] {2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8},
		      new [] {1, 10, 2},
		      new [] {1, 3, 8, 9, 1, 8},
		      new [] {0, 9, 1},
		      new [] {0, 3, 8},
		      new int[0]
		  };
		
		
		private static int[][] cubeVerts = new [] {
		    new [] {0,0,0},
		    new [] {1,0,0},
		    new [] {1,1,0},
		    new [] {0,1,0},
		    new [] {0,0,1},
		    new [] {1,0,1},
		    new [] {1,1,1},
		    new [] {0,1,1}
		};

		private static int[][] edgeIndex = new [] { 
			new [] {0,1},
			new [] {1,2},
			new [] {2,3},
			new [] {3,0},
			new [] {4,5},
			new [] {5,6},
			new [] {6,7},
			new [] {7,4},
			new [] {0,4},
			new [] {1,5},
			new [] {2,6},
			new [] {3,7}
		};
		
		private static MarchingVolume volume = new MarchingVolume();
		
		private static simppafi.Geometry.MarchingVolume makeVolume(float[][] dims, Func<float3, float> f) 
		{
			if(volume.data == null)
			{
				var res = new int[3];
			    for(var i=0; i<3; ++i) {
			        res[i] = 2 + (int)Math.Ceil((dims[i][1] - dims[i][0]) / dims[i][2]);
			    }

				volume.data = new float[res[0] * res[1] * res[2]];
				volume.dims = res;
			}

			var n = 0;

			var z=dims[2][0]-dims[2][2];
			for(var k=0; k<volume.dims[2]; ++k)
			{
				var y=dims[1][0]-dims[1][2];
				for(var j=0; j<volume.dims[1]; ++j)
				{
					var x=dims[0][0]-dims[0][2];
					for(var i=0; i<volume.dims[0]; ++i) 
					{
						volume.data[n] = f( float3(x,y,z) );
						x+=dims[0][2];
						n++;
					}
					y+=dims[1][2];
				}
				z+=dims[2][2];
			}
		    
		    return volume;
		}

		private static MarchingData result = new MarchingData();
		
		private static simppafi.Geometry.MarchingData GetData(MarchingVolume volume)
		{
		  
			var data = volume.data;
			var dims = volume.dims;

			var n = 0;
			var grid = new float[8];
			var edges = new int[12];
			var x = new int[3];

			result.vertices.Clear();
			//result.normals.Clear();
			result.faces.Clear();

			//March over the volume
			for(x[2]=0; x[2]<dims[2]-1; ++x[2])
			{
				
				for(x[1]=0; x[1]<dims[1]-1; ++x[1])
				{
					
				  
					for(x[0]=0; x[0]<dims[0]-1; ++x[0]) 
					{
						n++;
						
						//For each cell, compute cube mask
						var cube_index = 0;
						for(var i=0; i<8; ++i) {
							var v = cubeVerts[i];
							
							var a = n + v[0] + dims[0] * (v[1] + dims[1] * v[2]);
							if(a < data.Length)
							{
								var s = data[a];
								grid[i] = s;
								cube_index |= (s > 0) ? 1 << i : 0;
							}else{
								cube_index = 0;
								break;
							}
						}

						//debug_log "cube_index "+cube_index;
						//Compute vertices
						var edge_mask = edgeTable[cube_index];
						if(edge_mask == 0) {
						  continue;
						}
						for(var i=0; i<12; ++i) 
						{
						  if((edge_mask & (1<<i)) == 0) {
						    continue;
						  }
						  edges[i] = result.vertices.Count;
						  var e = edgeIndex[i];
						  var p0 = cubeVerts[e[0]];
						  var p1 = cubeVerts[e[1]];
						  var a = grid[e[0]];
						  var b = grid[e[1]];
						  var d = a - b;
						  var t = 0f;
						  if(Math.Abs(d) > 1e-6) {
						    t = a / d;
						  }
						  var v = float3(
									  (x[0] + p0[0]) + t * (p1[0] - p0[0]),
									  (x[1] + p0[1]) + t * (p1[1] - p0[1]),
									  (x[2] + p0[2]) + t * (p1[2] - p0[2])
						  );

						  result.vertices.Add(v);

						  //result.normals.Add(v);//Vector.Normalize(v));

						}

						//Add faces
						var f = triTable[cube_index];
						for(var i=0; i<f.Length; i += 3) 
						{
						  //res.faces.Add(
						  		//new [] {
						  			result.faces.Add(edges[f[i]]);
						  			result.faces.Add(edges[f[i+1]]); 
						  			result.faces.Add(edges[f[i+2]]);
						  		//}
						  	//);
						}
						
					}

					n++;
				}

				n+=dims[0];
				
			}
			  

			  return result;

		}

		//if(exports) {
		//  exports.mesher = MarchingCubes;
		//}
		//*/

	}
}