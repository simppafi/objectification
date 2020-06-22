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
using Fuse.Drawing.Batching;
using simppafi.Utils.CachedRandom;
using simppafi.Geometry.Triangulate;
using OpenGL;

namespace simppafi
{
	public class VisualTriangulate : simppafi.BaseVisual
	{
		private framebuffer _orgImage;
		public framebuffer OrgImage {
			get{return _orgImage;}
			set{
				_orgImage = value;
			}
		}

		private framebuffer _heightImage;
		public framebuffer HeightImage {
			get{return _heightImage;}
			set{
				_heightImage = value;
			}
		}

		private int _circlePoints = 16;
		public int CirclePoints {
			get{return _circlePoints;}
			set{_circlePoints = value;
			//if(GotImageData) {RefreshGeometry();}
			}
		}

		private float _supershape = 3f;
		public float SuperShape {
			get{return _supershape;}
			set{_supershape = Math.Round(value);
			//if(GotImageData) {RefreshGeometry();}
			}
		}

		private float4 _clearColor = float4(0,0,0,1);
		public float4 ClearColor {
			get{return _clearColor;}
			set{_clearColor = value;}
		}


		private Batch				Geom;
		private Random 				rand = new Random(1);
		private simppafi.Geometry.Triangulate.ProviderTriangle triProvider = new simppafi.Geometry.Triangulate.ProviderTriangle();


		private Buffer 				poisson_data 	= import Buffer("../Assets/poisson2.bin");
		private float2[]			points;
		private float2[]			pointCloud;

		private float2[] CreateFloat2Array(Buffer data)
		{
			var l = data.SizeInBytes/8;
			var arr = new float2[l];
			for(var i = 0; i < l; i++)
			{
				arr[i] = data.GetFloat2(i*8, true);
			}
			return arr;
		}


		public VisualTriangulate()
		{
			CastShadow = true;
			AddShadow = true;//false;
			UVCoordID = 3;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{
			base.Setup();
		}

		private void CreateTriangles()
		{
			pointCloud = CreateFloat2Array(poisson_data);
			points = new float2[pointCloud.Length];
			Uno.Array.Copy(pointCloud, points, pointCloud.Length);

			debug_log "points.Length "+points.Length;

			int verticeCount, indiceCount;
			float3 center, _center;
			int j;
			float3 pA, pB, pC;
			float3 nA, nB, nC;
			float2 tA, tB, tC;
			float3 cA, cB, cC;
			float  powA, powB, powC;
			float3 colA, colB, colC;


			List<Vertice> vertices = new List<simppafi.Geometry.Triangulate.Vertice>();
			/*for(var i = 0; i < 2048; i++)
			{
				vertices.Add(new Vertice(-5120.0 + (double)NextFloat() * 10240.0, -5120.0 + (double)NextFloat() * 10240.0, 0));
			}*/

			//65535

			CirclePoints = 32;
			SuperShape = 1f;

			for(var i = 0; i < CirclePoints; i++)
			{
				var angle = Math.PI * 2.0 * ( (double)i / (double)CirclePoints);
				var rad = 4900.0;//(double)(4900f * rand.NextFloat());//5800.0 - 300.0 + 400.0 * Math.Sin(-Math.PI*.5 + angle*SuperShape);
				var _x = rad * Math.Sin(angle);
				var _y = rad * Math.Cos(angle);

				vertices.Add(new simppafi.Geometry.Triangulate.Vertice(_x, _y, 0, _clearColor.XYZ));



			}


			float PolyScale = 1344f;

			var addVerticeCount = 0;
			var skipCount = 0;
			for(var i = 0; i < points.Length; i++)
			{
				
				var _x = (double)points[i].X * (double)PolyScale;
				var _y = (double)points[i].Y * (double)PolyScale;

				if( Vector.Length(float2((float)_x, (float)_y)) > 5000f)
				{
					continue;
				}
				
				var ux = (_x + 5000.0) / 10000.0;
				var uy = (_y + 5000.0) / 10000.0;

				
				var px = (int)(ux * ImageSizes[0].X * .999f);
				var py = (int)(uy * ImageSizes[0].Y * .999f);

				var BPP = 4;
				var stride = ImageSizes[0].X * 4;
				var ImageBytePos = px * BPP + py * stride;
				
				var val = (float)ImageBytes[0][ImageBytePos] / (float)255f;


				/*var doadd = false;
				if(!DarkRender)
				{
					if(val > LightLimit)
					{
						doadd = true;
					}
				}
				else
				{
					if(val < DarkLimit)
					{
						doadd = true;
					}
				}

				if(doadd)
				{*/

					if(val < .02f)
					{
						continue;
					}

					var color = float3( (float)ImageBytes[0][ImageBytePos] / (float)255f,
										(float)ImageBytes[0][ImageBytePos+1] / (float)255f,
										(float)ImageBytes[0][ImageBytePos+2] / (float)255f );
			
					vertices.Add(new simppafi.Geometry.Triangulate.Vertice(_x, _y, 0, color, val));

					addVerticeCount++;
				//}
			}

			debug_log "addVerticeCount "+addVerticeCount;



			triProvider.vertices = vertices;
			triProvider.calculate();

			verticeCount = triProvider.indicesCount * 2;// * 2;
			indiceCount = triProvider.indicesCount * 8;// * 2;

			debug_log 65535-verticeCount;

			Geom = new Batch(verticeCount, indiceCount, true);

			debug_log "Triangulate "+verticeCount;

			var indices = triProvider.indices;
			int id0, id1, id2;
			ushort a, b, c, d, e, f;

			float3 scale = float3(100f,100f,100f);

			ushort vertexCount = 0;

			_center = float3(0,-15,0);//-100f + 175f * o,0);
			for(var i = 0; i < triProvider.indicesCount; i+=3)
			{
				id0 = indices[ i ];
				id1 = indices[ i + 1 ];
				id2 = indices[ i + 2 ];

				pA = float3((float)vertices[id0].x, (float)vertices[id0].z, (float)vertices[id0].y) / 5000f;
				pB = float3((float)vertices[id1].x, (float)vertices[id1].z, (float)vertices[id1].y) / 5000f;
				pC = float3((float)vertices[id2].x, (float)vertices[id2].z, (float)vertices[id2].y) / 5000f;

				//var pCenter = (pA+pB+pC) / 3f;
				//pA = pA + (pCenter - pA) * .05f;
				//pB = pB + (pCenter - pB) * .05f;
				//pC = pC + (pCenter - pC) * .05f;

				tA = float2(pA.X+1f, pA.Z+1f) * .5f;
				tB = float2(pB.X+1f, pB.Z+1f) * .5f;
				tC = float2(pC.X+1f, pC.Z+1f) * .5f;
				
				//float3 cA, cB, cC;
				powA = vertices[id0].power;
				powB = vertices[id1].power;
				powC = vertices[id2].power;

				colA = vertices[id0].color;
				colB = vertices[id1].color;
				colC = vertices[id2].color;


				var powAv = (powA+powB+powC) / 3f;
				//center = _center + float3(0,-20f + 40f * rand.NextFloat(),0);
				center = _center;// + float3(0,powAv*30f,0);//50f * rand.NextFloat(),0);

				/*var avCenter = (pA+pB+pC) / 3f;
				var len = Vector.Length(avCenter);
				if( len > .5f)
				{
					//var lena = 1f+(len-.5f) * 2f;
					//pA*=float3(lena,1f,lena);
					//pB*=float3(lena,1f,lena);
					//pC*=float3(lena,1f,lena);

					var lena = ((len-.5f) * 2f);
					center = float3(0,-15,0) + float3(0f,-lena*15f,0f);
					//center += float3(0f,-lena*10f,0f);
					//center += float3(0f,-lena*10f,0f);
				}*/

				nA = float3(pA.X,1f,pA.Z);//pA;//Vector.Normalize(pA)*.5f +.5f;
				nB = float3(pB.X,1f,pB.Z);//pB;//Vector.Normalize(pB)*.5f +.5f;
				nC = float3(pC.X,1f,pC.Z);//pC;//Vector.Normalize(pC)*.5f +.5f;

				pA *= scale;
				pB *= scale;
				pC *= scale;


				Geom.Positions.Write(pA+center);
				Geom.Positions.Write(pB+center);
				Geom.Positions.Write(pC+center);

				Geom.Normals.Write(Vector.Normalize(nA));
				Geom.Normals.Write(Vector.Normalize(nB));
				Geom.Normals.Write(Vector.Normalize(nC));

				Geom.TexCoord0s.Write(tA);
				Geom.TexCoord0s.Write(tB);
				Geom.TexCoord0s.Write(tC);

				Geom.Attrib0Buffer.Write(float4(colA, 0));
				Geom.Attrib0Buffer.Write(float4(colB, 0));
				Geom.Attrib0Buffer.Write(float4(colC, 0));

				// SECOND TRIANGLE
				//var adde = 0f;
				//if(rand.NextFloat() > .99f)
				//{
				//	adde = 60f * rand.NextFloat();
				//}
				//var tr = 10f + adde;
				//var powAv = (powA+powB+powC) / 3f;
				//if(powAv > .8f)
				//{
				//	powAv *= 2f;
				//}

				pA += float3(0,5f+powAv*50f,0);
				pB += float3(0,5f+powAv*50f,0);
				pC += float3(0,5f+powAv*50f,0);

				//pA += float3(0,5f,0);
				//pB += float3(0,5f,0);
				//pC += float3(0,5f,0);

				Geom.Positions.Write(pA+center);
				Geom.Positions.Write(pB+center);
				Geom.Positions.Write(pC+center);

				Geom.Normals.Write(nA);
				Geom.Normals.Write(nB);
				Geom.Normals.Write(nC);

				Geom.TexCoord0s.Write(tA);
				Geom.TexCoord0s.Write(tB);
				Geom.TexCoord0s.Write(tC);

				Geom.Attrib0Buffer.Write(float4(colA, 0));
				Geom.Attrib0Buffer.Write(float4(colB, 0));
				Geom.Attrib0Buffer.Write(float4(colC, 0));


				a = vertexCount++;
				b = vertexCount++;
				c = vertexCount++;

				d = vertexCount++;
				e = vertexCount++;
				f = vertexCount++;


				Geom.Indices.Write(a);
				Geom.Indices.Write(b);
				Geom.Indices.Write(c);

				Geom.Indices.Write(d);
				Geom.Indices.Write(f);
				Geom.Indices.Write(e);

				Geom.Indices.Write(b);
				Geom.Indices.Write(a);
				Geom.Indices.Write(d);

				Geom.Indices.Write(b);
				Geom.Indices.Write(d);
				Geom.Indices.Write(e);

				Geom.Indices.Write(c);
				Geom.Indices.Write(b);
				Geom.Indices.Write(f);

				Geom.Indices.Write(b);
				Geom.Indices.Write(e);
				Geom.Indices.Write(f);

				Geom.Indices.Write(c);
				Geom.Indices.Write(f);
				Geom.Indices.Write(a);

				Geom.Indices.Write(d);
				Geom.Indices.Write(a);
				Geom.Indices.Write(f);

			}
		}

		private float2 uvFromSphere(float3 v)
		{
			var va = Vector.Normalize(v);
			return float2(
				.5f + Math.Atan2(va.Z, va.X) / (Math.PIf*2f),
				.5f - Math.Asin(va.Y) / Math.PIf
			);
		}

		override public void OnOff() {}



		block Shader
		{
			apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;


			float4 rot : Uno.Quaternion.RotationAxis(float3(1f,0f,0f), (float)Time*.2f);

			VertexPosition : 
				Uno.Vector.Transform(prev, rot);


			float3 _bump : 
				req(OrgImage as framebuffer)
					sample(OrgImage.ColorBuffer, TexCoord, Uno.Graphics.SamplerState.TrilinearWrap).XYZ;
			//sample(import Texture2D("../Assets/dice_texture_normal.jpg"), TexCoord, Uno.Graphics.SamplerState.TrilinearWrap).XYZ;

			Normal : Uno.Vector.Normalize(prev + _bump);

			//Normal:
	        //    Vector.Transform(TangentNormal, Tangent3x3);

	        float4 Metal :
				req(ReflectedViewDirection as float3)
					sample(import TextureCube("../Assets/cubemap3_burn.jpg"), ReflectedViewDirection, Uno.Graphics.SamplerState.LinearClamp);// * simppafi.Color.ColorHexToRGB.HexToRGBA(0x643744);
					
			//PixelColor : sample(import Texture2D("../Assets/dice_texture.jpg"), TexCoord, Uno.Graphics.SamplerState.TrilinearWrap) + Metal;
			
			PixelColor :
				//req(Attrib0 as float4)
				//	float4(Attrib0.XYZ, 1f);
				req(OrgImage as framebuffer)
					sample(OrgImage.ColorBuffer, TexCoord, Uno.Graphics.SamplerState.TrilinearWrap);// + Metal;

		}


		override public void OnUpdate()
		{

		}

		protected override void OnDraw(DrawContext dc)
    	{

	       if(!GotImageData && OrgImage != null)
	       {
	       	
	       	 	SetupSourceImages(dc, HeightImage);

	       		CreateTriangles();
	       		
	       		return;
	       }

    		draw this, Geom, Shader, virtual simppafi.RenderPipeline.PassFront;

		}




		private List<byte[]>		ImageBytes = new List<byte[]>();
		private List<int2>			ImageSizes = new List<int2>();
		private bool 				GotImageData = false;

		public void SetupSourceImages(Fuse.DrawContext dc, framebuffer frame)
		{
			ImageBytes.Add(CreateByteArrayFromFramebuffer(frame, dc));

			GotImageData = true;
		}

		private byte[] CreateByteArrayFromFramebuffer(framebuffer img, Fuse.DrawContext dc)
		{
			var imageSize = img.Size;
			ImageSizes.Add(imageSize);

			var dummy = Fuse.FramebufferPool.Lock(imageSize, Uno.Graphics.Format.RGBA8888, false);

			dc.PushRenderTarget(dummy);
			dc.Clear(float4(0,0,0,1), 1.0f);

			draw Quad
			{
				float2 px : pixel ClipPosition.XY / ClipPosition.W * 0.5f + 0.5f;
				PixelColor : sample(img.ColorBuffer, px, Uno.Graphics.SamplerState.LinearClamp);
			};

			var bytes = new byte[imageSize.X*imageSize.Y*4];
			GL.ReadPixels(0, 0, imageSize.X, imageSize.Y, GLPixelFormat.Rgba, GLPixelType.UnsignedByte, bytes);

			dc.PopRenderTarget();

			Fuse.FramebufferPool.Release(dummy);

			return bytes;
		}



	}
}
