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

namespace simppafi
{
	public class VisualRoomStatic : simppafi.BaseVisual
	{
		private Batch				Geom;
		private Random 				rand = new Random(1);

		public VisualRoomStatic()
		{
			CastShadow = true;//true;
			AddShadow = true;//false;
			UVCoordID = 3;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{


			/*
			var model = simppafi.Models.cube_rounded;//head1;

			float3 v;
			int i,j;
			int vertexcount = 0;
			int indicecount = 0;
			ushort vcount = 0;

			var positions = new List<float3>();
			var normals = new List<float3>();
			var uvs = new List<float2>();

			debug_log "MODEL VisualRoomStatic DRAWABLE COUNT "+model.DrawableCount;

			ModelMesh mesh;
			for(i = 0; i < model.DrawableCount; i++)
			{
				mesh = model.GetDrawable(i).Mesh;

				for(j = 0; j < mesh.VertexCount; j++)
				{
					positions.Add(mesh.Positions.GetFloat4(j).XYZ);// + float3(0,0,-.5f));
					normals.Add(mesh.Normals.GetFloat4(j).XYZ);
					//normals.Add(mesh.Positions.GetFloat4(j).XYZ);
					
					uvs.Add(mesh.TexCoords.GetFloat4(j).XY);//mesh.TexCoords.GetFloat4(j).XY);

					//debug_log mesh.Positions.GetFloat4(j).XY;

					//uvs.Add(uvFromSphere(mesh.Positions.GetFloat4(j).XYZ));
					vertexcount++;
				}
			}
			var modelverticecount = vertexcount;
			indicecount = vertexcount;


			Geom = new Batch( vertexcount, indicecount, true);

			debug_log "VisualRoomStatic "+vertexcount;

			var sca = float3(250f, 180f, 250f); //30
			var pos = float3(0,0,0);//Math.Abs(sca.Y)-15f,0);//15f,0);

			for(i = 0; i < modelverticecount; i++)
			{
				v = positions[i];

				//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(Math.PIf*.5f));
				
				v = v  * sca + pos;

				var n = normals[i];

				//n = Uno.Vector.Transform(n, Uno.Quaternion.RotationX(Math.PIf*.5f));

				Geom.TexCoord0s.Write(uvs[i]);

				Geom.Positions.Write(v);
				
				

				Geom.Normals.Write(n);//*-1f);
				

				//var n = Vector.Normalize(v);
				//Geom.Normals.Write(n);

				Geom.Indices.Write((ushort)vcount++);
			}

			base.Setup();
			//*/



			///*
			var geometric = simppafi.Geometry.VerticeGenerator.CreateCubeSphereHalf(48, false);//CreateCube();

			var verticeCount = geometric.vertices.Count;// * 2;
			var indiceCount =  geometric.indices.Count * 3;// * 2;

			Geom = new Batch(verticeCount, indiceCount, true);

			debug_log "Static Room Vertices "+verticeCount;

			float3 v, av;
			float2 uv;
			int i, indexAdd = 0;
			
			var newVertexPositions = new List<float3>();
			var uvs = new float2[verticeCount];

			for(i = 0; i < geometric.vertices.Count; i++)
			{
				v = geometric.vertices[i];//
				uv = geometric.texCoords[i];

				var limit = 0.75f;//0.75f;

				v = float3(
						Math.Clamp(v.X, -limit, limit),
						Math.Clamp(v.Y, -limit, limit),
						Math.Clamp(v.Z, -limit, limit)
						);

				v *= 1f/limit;
				
				if(v.Y < 0f)
				{
					var spherePos = uv;

					var _x = (int)(spherePos.X * TexturePixelProvider.ImageSizes[0].X * .99f);
					var _y = (int)(spherePos.Y * TexturePixelProvider.ImageSizes[0].Y * .99f);

					var BPP = 4;
					var stride = TexturePixelProvider.ImageSizes[0].X * 4;
					var ImageBytePos = _x * BPP + _y * stride;

					var val = (float)TexturePixelProvider.ImageBytes[0][ImageBytePos] / (float)255f;

					var smooth = 1f-Vector.Length((uv+float2(-.5f)) * 2f);

					v *= 1f - val*.4f * smooth;

					if(smooth > .75f)
					{
						var msh = 1f + (smooth-.75f) * 4f;
						v *= msh*msh;//*2.5f;
					}
				
				}

				//Geom.Positions.Write(v * float3(-250f));//,-200f,-500f) + float3(0,200f-15f,0));

				av = v * float3(-75f,-75f,-75f);//float3(-250f, -180f, -250f);
				Geom.Positions.Write(av);// * spike);
				newVertexPositions.Add(av);

				//Geom.Normals.Write(v);//Vector.Normalize(v));

				//Geom.TexCoord0s.Write((Vector.Normalize(v).XZ + 1f) * .5f);

				//Geom.TexCoord0s.Write(geometric.texCoords[i]);

				
				//uv = uvFromSphere(v);
				Geom.TexCoord0s.Write(uv);
				uvs[i] = uv;
				

			}

			indexAdd = simppafi.Utils.BatchHelper.WriteIndicesNormalsTangents(Geom, geometric, newVertexPositions, uvs, indiceCount, indexAdd);

			/*
			for(i = 0; i < geometric.indices.Count; i++)
			{
				Geom.Indices.Write((ushort)(geometric.indices[i].X + indexAdd));
				Geom.Indices.Write((ushort)(geometric.indices[i].Y + indexAdd));
				Geom.Indices.Write((ushort)(geometric.indices[i].Z + indexAdd));
			}*/

			//indexAdd += geometric.vertices.Count;
			

			base.Setup();
			//*/
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
    		
			//CullFace : Uno.Graphics.PolygonFace.Back;

			TexCoord : prev * 2f;

			PixelColor : float4(albedo.XYZ*ao, 1f);
		}


		override public void OnUpdate()
		{
			
		}

		protected override void OnDraw(DrawContext dc)
    	{
    		//if(simppafi.RenderPipeline.IsWeight)
    		//{
    		//	draw this, Geom, Shader, simppafi.ShaderMaterial.Rust4, virtual simppafi.RenderPipeline.PassFront, {CullFace : Uno.Graphics.PolygonFace.Back;};
			//}else{
				draw this, Geom, Shader, simppafi.ShaderMaterial.Rust4, virtual simppafi.RenderPipeline.PassFront;
			//}
    		
    		//draw this, Geom, Shader, simppafi.ShaderMaterial.Plastic, virtual simppafi.RenderPipeline.PassFront;
		}


	}
}
