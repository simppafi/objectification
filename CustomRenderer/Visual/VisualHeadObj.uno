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

namespace simppafi
{
	public class VisualHeadObj : simppafi.BaseVisual
	{
		private Batch				Geom;
		private Random 				rand = new Random(1);

		//private texture2D			NormalTexture = import Texture2D("../Assets/dice_texture_normal.jpg");
		//private texture2D			ColorTexture = import Texture2D("../Assets/dice_texture.jpg");

		public VisualHeadObj()
		{
			CastShadow = true;
			AddShadow = true;//false;
			UVCoordID = 2;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{
			var model = simppafi.Models.female_head;//head1;

			float3 v;
			int i,j;
			int vertexcount = 0;
			int indicecount = 0;
			ushort vcount = 0;

			var positions = new List<float3>();
			var normals = new List<float3>();
			var uvs = new List<float2>();
			//var tangents = new List<float4>();

			debug_log "MODEL TESTMODEL DRAWABLE COUNT "+model.DrawableCount;

			ModelMesh mesh;

			var highVert = 0f;
			for(i = 0; i < model.DrawableCount; i++)
			{
				mesh = model.GetDrawable(i).Mesh;

				var avCent = float3(0);
				for(j = 0; j < mesh.VertexCount; j++)
				{
					avCent += mesh.Positions.GetFloat4(j).XYZ;
				}
				avCent /= mesh.VertexCount;
				var avCentMv = avCent * rand.NextFloat3()*1f;

				//debug_log avCent;


				for(j = 0; j < mesh.VertexCount; j++)
				{
					if(avCent.Z > 0.6f)
					{
						//positions.Add(mesh.Positions.GetFloat4(j).XYZ + float3(avCentMv.X,-Math.Abs(avCentMv.Z),0) );
						//break;
						var pef = avCent.Z-0.6f;
						positions.Add(mesh.Positions.GetFloat4(j).XYZ + float3(0,0, (1f+pef)*(1f+pef)*pef*.5f) );
					}else{
						positions.Add(mesh.Positions.GetFloat4(j).XYZ);// + avCent);
					}
					//positions.Add(mesh.Positions.GetFloat4(j).XYZ);
					normals.Add(mesh.Normals.GetFloat4(j).XYZ);
					uvs.Add(uvFromSphere(mesh.Positions.GetFloat4(j).XYZ + float3(0,-0.125f,0)));

					if(mesh.Positions.GetFloat4(j).Y > highVert)
					{
						highVert = mesh.Positions.GetFloat4(j).Y;
					}
					//uvs.Add(mesh.TexCoords.GetFloat4(j).XY);

					vertexcount++;
				}
			}
			debug_log "highVert "+highVert;
			var modelverticecount = vertexcount;
			indicecount = vertexcount;


			Geom = new Batch( vertexcount, indicecount, true);

			debug_log "TestModel "+vertexcount;

			var sca = float3(75f); //30
			var pos = float3(0,-3f,0);//15f,0);


			var indexAdd = 0;
			var _vertices = new float3[vertexcount];
			var _normals = new float3[vertexcount];
			var _uvs = new float2[vertexcount];

			for(i = 0; i < modelverticecount; i++)
			{
				v = positions[i];

				v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(-Math.PIf*.5f));
				
				//float4 red = Vector.Length(v.XZ) < .15f ? float4(1f,0,0,1) : float4(1f);
				
				//Geom.Attrib0Buffer.Write(red);

				v = v  * sca + pos;

				var n = normals[i];

				n = Uno.Vector.Transform(n, Uno.Quaternion.RotationX(-Math.PIf*.5f));

				var uv = uvs[i];


				Geom.Positions.Write(v);
				_vertices[i] = v;
				
				Geom.TexCoord0s.Write(uv);
				_uvs[i] = uv;
				
				Geom.Normals.Write(n);
				_normals[i] = n;
				
				Geom.Indices.Write((ushort)vcount++);
			}

			indexAdd = simppafi.Utils.BatchHelper.WriteTangents(Geom, _vertices, _normals, _uvs, 0);
			

			base.Setup();
		}

		override public void OnOff() {}

		private float2 uvFromSphere(float3 v)
		{
			var va = Vector.Normalize(v);
			return float2(
				.5f + Math.Atan2(va.Z, va.X) / (Math.PIf*2f),
				.5f - Math.Asin(va.Y) / Math.PIf
			);
		}

		private float PerlinNoise(float2 xy)
		{
			int n;
			n = (int)(xy.X + xy.Y * 57);
			n = (n << 13) ^ n;
			return 1f + (1.0f - ( (n * ((n * n * 15731) + 789221) +  1376312589) & 0x7fffffff) / 1073741824.0f);
		}

		block Shader
		{
    		apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

			PixelColor : float4(albedo.XYZ*ao, 1f);
		}


		override public void OnUpdate()
		{


		}


		protected override void OnDraw(DrawContext dc)
    	{
    		//draw this, Geom, Shader, Material, virtual simppafi.RenderPipeline.PassFront;

    		draw this, Geom, Shader, simppafi.ShaderMaterial.Aluminum, virtual simppafi.RenderPipeline.PassFront;

		}

	}
}
