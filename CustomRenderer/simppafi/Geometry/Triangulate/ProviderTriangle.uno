using Uno;
using Uno.Collections;

namespace simppafi.Geometry.Triangulate
{
	public class ProviderTriangle
	{
		public ProviderTriangle() {}

		public List<Vertice> vertices;
		public int[] indices;
		public int indicesCount = 0;

		private const double EPSILON = 0.0000001;
		private const double SUPER_TRIANGLE_RADIUS = 100000000.0;
		private Vertice SUPER_A = new Vertice( 0, -SUPER_TRIANGLE_RADIUS, 0 );
		private Vertice SUPER_B = new Vertice( SUPER_TRIANGLE_RADIUS, SUPER_TRIANGLE_RADIUS, 0 );
		private Vertice SUPER_C = new Vertice( -SUPER_TRIANGLE_RADIUS, SUPER_TRIANGLE_RADIUS, 0 );

		private int sortCheck(Vertice a, Vertice b)
		{
			return a.y > b.y ? 1 : -1;
		}

		public void calculate()
		{
			int l = vertices.Count;

			vertices.Sort(sortCheck);

			vertices.Add(SUPER_A);
			vertices.Add(SUPER_B);
			vertices.Add(SUPER_C);

			var circles = new double[l*6+6];
			int circlesCount = 0;

			indices = new int[l*6+6];
			indicesCount = 0;

			var edgeIds = new int[128];
			int edgeCount = 0;

			var off0 = indices[indicesCount++] = l;
			var off1 = indices[indicesCount++] = l+1;
			var off2 = indices[indicesCount++] = l+2;

			circles[circlesCount++] = 0;
			circles[circlesCount++] = 0;
			circles[circlesCount++] = SUPER_TRIANGLE_RADIUS;

			int a,b,c,i,j,k,r;
			for ( i = 0; i < l; i++)
			{
				for ( j = 0; j < indicesCount; j+=3 )
				{
					if (circles[ j + 2 ] > EPSILON)
					{
						var dx = circles[ j ] - vertices[ i ].x;
						var dy = circles[ j + 1 ] - vertices[ i ].y;
						if(circles[ j + 2 ] > (dx * dx + dy * dy))
						{
							a = indices[ j ];
							b = indices[ j + 1 ];
							c = indices[ j + 2 ];
							edgeIds[edgeCount++] = a;
							edgeIds[edgeCount++] = b;
							edgeIds[edgeCount++] = b;
							edgeIds[edgeCount++] = c;
							edgeIds[edgeCount++] = c;
							edgeIds[edgeCount++] = a;
							for (r = j; r < indicesCount - 1; r++)
              				{
								indices[r] = indices[r + 3];
							}
							indicesCount -= 3;

							for (r = j; r < circlesCount - 1; r++)
              				{
								circles[r] = circles[r + 3];
							}
							circlesCount -= 3;
							j -= 3;
						}
					}
				}
				for ( j = 0; j < edgeCount; j+=2 )
				{
					for ( k = j + 2; k < edgeCount; k+=2 )
					{
						if(	(	edgeIds[ j ] == edgeIds[ k ] && edgeIds[ j + 1 ] == edgeIds[ k + 1 ]	)
						||	(	edgeIds[ j + 1 ] == edgeIds[ k ] && edgeIds[ j ] == edgeIds[ k + 1 ]	)	)
						{
							for (r = k; r < edgeCount - 1; r++)
              				{
								edgeIds[r] = edgeIds[r + 2];
							}
							for (r = j; r < edgeCount - 1; r++)
              				{
								edgeIds[r] = edgeIds[r + 2];
							}
							edgeCount-=4;
							j -= 2;
							k -= 2;
							if ( j < 0 ) break;
							if ( k < 0 ) break;
						}
					}
				}

				for ( j = 0; j < edgeCount; j+=2 )
				{
					a = edgeIds[ j ];
					b = edgeIds[ j + 1 ];
					c = i;
					indices[indicesCount++] = a;
					indices[indicesCount++] = b;
					indices[indicesCount++] = c;
					var p0 = vertices[ a ];
					var p1 = vertices[ b ];
					var p2 = vertices[ c ];
					var A = p1.x - p0.x;
					var B = p1.y - p0.y;
					var C = p2.x - p0.x;
					var D = p2.y - p0.y;
					var E = A * (p0.x + p1.x) + B * (p0.y + p1.y);
					var F = C * (p0.x + p2.x) + D * (p0.y + p2.y);
					var G = 2.0 * (A * (p2.y - p1.y) - B * (p2.x - p1.x));
					var x = (D * E - B * F) / G;
					circles[circlesCount++] = x;
					var y = (A * F - C * E) / G;
					circles[circlesCount++] = y;
					x -= p0.x;
					y -= p0.y;
					circles[circlesCount++] = x * x + y * y;

				}

				edgeCount = 0;
			}

			for ( i = 0; i < indicesCount; i+= 3 )
			{
				if ( indices[ i ] == off0 || indices[ i ] == off1 || indices[ i ] == off2
				||	 indices[ i + 1 ] == off0 || indices[ i + 1 ] == off1 || indices[ i + 1 ] == off2
				||	 indices[ i + 2 ] == off0 || indices[ i + 2 ] == off1 || indices[ i + 2 ] == off2 )
				{
					for (r = i; r < indicesCount - 1; r++)
      				{
						indices[r] = indices[r + 3];
					}
					indicesCount -= 3;

					i-=3;
					continue;
				}
			}
			vertices.RemoveAt(vertices.Count-1);
			vertices.RemoveAt(vertices.Count-1);
			vertices.RemoveAt(vertices.Count-1);
		}

	}
}

/*
using Uno;
using Uno.Collections;

namespace simppafi.Geometry.Triangulate
{
	public class ProviderTriangle
	{
		public ProviderTriangle() {}

		public List<Vertice> vertices;
		public int[] indices;
		public int indicesCount = 0;

		private const double EPSILON = 0.0000001;
		private const double SUPER_TRIANGLE_RADIUS = 100000000.0;
		private Vertice SUPER_A = new Vertice( 0, -SUPER_TRIANGLE_RADIUS, 0 );
		private Vertice SUPER_B = new Vertice( SUPER_TRIANGLE_RADIUS, SUPER_TRIANGLE_RADIUS, 0 );
		private Vertice SUPER_C = new Vertice( -SUPER_TRIANGLE_RADIUS, SUPER_TRIANGLE_RADIUS, 0 );

		private int sortCheck(Vertice a, Vertice b)
		{
			return a.y > b.y ? 1 : -1;
		}

		public void calculate()
		{
			int l = vertices.Count;

			vertices.Sort(sortCheck);

			vertices.Add(SUPER_A);
			vertices.Add(SUPER_B);
			vertices.Add(SUPER_C);

			var circles = new double[l*6+6];
			int circlesCount = 0;

			indices = new int[l*6+6];
			indicesCount = 0;

			var edgeIds = new int[128];
			int edgeCount = 0;

			var off0 = indices[indicesCount++] = l;
			var off1 = indices[indicesCount++] = l+1;
			var off2 = indices[indicesCount++] = l+2;

			circles[circlesCount++] = 0;
			circles[circlesCount++] = 0;
			circles[circlesCount++] = SUPER_TRIANGLE_RADIUS;

			int a,b,c,i,j,k,r;
			for ( i = 0; i < l; i++)
			{
				for ( j = 0; j < indicesCount; j+=3 )
				{
					if (circles[ j + 2 ] > EPSILON)
					{
						var dx = circles[ j ] - vertices[ i ].x;
						var dy = circles[ j + 1 ] - vertices[ i ].y;
						if(circles[ j + 2 ] > (dx * dx + dy * dy))
						{
							a = indices[ j ];
							b = indices[ j + 1 ];
							c = indices[ j + 2 ];
							edgeIds[edgeCount++] = a;
							edgeIds[edgeCount++] = b;
							edgeIds[edgeCount++] = b;
							edgeIds[edgeCount++] = c;
							edgeIds[edgeCount++] = c;
							edgeIds[edgeCount++] = a;
							for (r = j; r < indicesCount - 1; r++)
              				{
								indices[r] = indices[r + 3];
							}
							indicesCount -= 3;

							for (r = j; r < circlesCount - 1; r++)
              				{
								circles[r] = circles[r + 3];
							}
							circlesCount -= 3;
							j -= 3;
						}
					}
				}
				for ( j = 0; j < edgeCount; j+=2 )
				{
					for ( k = j + 2; k < edgeCount; k+=2 )
					{
						if(	(	edgeIds[ j ] == edgeIds[ k ] && edgeIds[ j + 1 ] == edgeIds[ k + 1 ]	)
						||	(	edgeIds[ j + 1 ] == edgeIds[ k ] && edgeIds[ j ] == edgeIds[ k + 1 ]	)	)
						{
							for (r = k; r < edgeCount - 1; r++)
              				{
								edgeIds[r] = edgeIds[r + 2];
							}
							for (r = j; r < edgeCount - 1; r++)
              				{
								edgeIds[r] = edgeIds[r + 2];
							}
							edgeCount-=4;
							j -= 2;
							k -= 2;
							if ( j < 0 ) break;
							if ( k < 0 ) break;
						}
					}
				}

				for ( j = 0; j < edgeCount; j+=2 )
				{
					a = edgeIds[ j ];
					b = edgeIds[ j + 1 ];
					c = i;
					indices[indicesCount++] = a;
					indices[indicesCount++] = b;
					indices[indicesCount++] = c;
					var p0 = vertices[ a ];
					var p1 = vertices[ b ];
					var p2 = vertices[ c ];
					var A = p1.x - p0.x;
					var B = p1.y - p0.y;
					var C = p2.x - p0.x;
					var D = p2.y - p0.y;
					var E = A * (p0.x + p1.x) + B * (p0.y + p1.y);
					var F = C * (p0.x + p2.x) + D * (p0.y + p2.y);
					var G = 2.0 * (A * (p2.y - p1.y) - B * (p2.x - p1.x));
					var x = (D * E - B * F) / G;
					circles[circlesCount++] = x;
					var y = (A * F - C * E) / G;
					circles[circlesCount++] = y;
					x -= p0.x;
					y -= p0.y;
					circles[circlesCount++] = x * x + y * y;

				}

				edgeCount = 0;
			}

			for ( i = 0; i < indicesCount; i+= 3 )
			{
				if ( indices[ i ] == off0 || indices[ i ] == off1 || indices[ i ] == off2
				||	 indices[ i + 1 ] == off0 || indices[ i + 1 ] == off1 || indices[ i + 1 ] == off2
				||	 indices[ i + 2 ] == off0 || indices[ i + 2 ] == off1 || indices[ i + 2 ] == off2 )
				{
					for (r = i; r < indicesCount - 1; r++)
      				{
						indices[r] = indices[r + 3];
					}
					indicesCount -= 3;

					i-=3;
					continue;
				}
			}
			vertices.RemoveAt(vertices.Count-1);
			vertices.RemoveAt(vertices.Count-1);
			vertices.RemoveAt(vertices.Count-1);
		}

	}
}
*/