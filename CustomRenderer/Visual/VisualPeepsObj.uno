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
	public class VisualPeepsObj : simppafi.BaseVisual
	{
		private Batch				Geom;
		private Batch				Geom2;
		private Random 				rand = new Random(1);

		//private texture2D			NormalTexture = import Texture2D("../Assets/dice_texture_normal.jpg");
		//private texture2D			ColorTexture = import Texture2D("../Assets/dice_texture.jpg");

		public VisualPeepsObj()
		{
			CastShadow = true;
			AddShadow = true;//false;
			UVCoordID = 2;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{
			var indexAdd = 0;

			var modelData = new ModelData();

			var radius = 15f;
			var angle = Math.PIf*2f / 14f;
			var curAngle = 0f;

			var dudeList1 = new [] {simppafi.Models.people1,simppafi.Models.people2,simppafi.Models.people3,simppafi.Models.people4,
									simppafi.Models.people5,simppafi.Models.people6,simppafi.Models.people7};

			var dudeList2 = new [] {simppafi.Models.people8,simppafi.Models.people9,simppafi.Models.people10,simppafi.Models.people11,
									simppafi.Models.people12,simppafi.Models.people13,simppafi.Models.people14};

			var points = PoissonDisk.getPoints();
			float3 center;
			for(var i = 0; i < dudeList1.Length; i++)
			{
				//radius = 5f + rand.NextFloat() * 10f;
				//curAngle += angle;

				center = float3(points[i + 2].X * 220f, 0, points[i + 2].Y * 220f);

				modelData = FetchModelData(	dudeList1[i], 
											modelData, 
											center, 
											float3(0,Math.PIf * 2f * rand.NextFloat(),0f),
											float3(8f), 
											false);
			}
			

			var modelData2 = new ModelData();
			
			for(var i = 0; i < dudeList2.Length; i++)
			{
				//radius = 5f * rand.NextFloat() * 10f;
				//curAngle += angle;
				
				center = float3(points[dudeList1.Length + i + 3].X * 220f, 0, points[dudeList1.Length + i + 3].Y * 220f);

				modelData2 = FetchModelData(	dudeList2[i], 
												modelData2, 
												center, 
												float3(0,Math.PIf * 2f * rand.NextFloat(),0f),
												float3(8f), 
												false);
			}


			Geom = new Batch( modelData.vertexCount, modelData.vertexCount, true);

			BatchModel(	Geom, 0, modelData);

			Geom2 = new Batch( modelData2.vertexCount, modelData2.vertexCount, true);
			
			BatchModel(	Geom2, 0, modelData2);

			base.Setup();
		}

		private ModelData FetchModelData(Model model, ModelData modelData, float3 pos, float3 rot, float3 sca, bool gotUV = true)
		{
			float3 v, n;
			int i,j;

			debug_log "MODEL DRAWABLE COUNT "+model.DrawableCount;
			//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893);//0x56f1ff); //
			var color = float3(	.5f+rand.NextFloat()*.5f,
								.5f+rand.NextFloat()*.5f,
								.5f+rand.NextFloat()*.5f);
				
			ModelMesh mesh;
			for(i = 0; i < model.DrawableCount; i++)
			{
				mesh = model.GetDrawable(i).Mesh;
				/*
				var avCent = float3(0);
				for(j = 0; j < mesh.VertexCount; j++)
				{
					avCent += mesh.Positions.GetFloat4(j).XYZ;
				}
				avCent /= mesh.VertexCount;
				var avCentMv = avCent * rand.NextFloat3()*1f;
				*/
				//debug_log avCent;
				for(j = 0; j < mesh.VertexCount; j++)
				{
					v = mesh.Positions.GetFloat4(j).XYZ;
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(rot.X));
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationY(rot.Y));
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationZ(rot.Z));
					
					n = mesh.Normals.GetFloat4(j).XYZ;
					n = Uno.Vector.Transform(n, Uno.Quaternion.RotationX(rot.X));
					n = Uno.Vector.Transform(n, Uno.Quaternion.RotationY(rot.Y));
					n = Uno.Vector.Transform(n, Uno.Quaternion.RotationZ(rot.Z));

					modelData.positions.Add(v * sca + pos);
					
					modelData.normals.Add(n);

					if(gotUV)
					{
						modelData.uvs.Add(mesh.TexCoords.GetFloat4(j).XY);
					}else{
						modelData.uvs.Add(uvFromSphere(mesh.Positions.GetFloat4(j).XYZ + float3(0,-0.875f,0)));
					}
					//uvs.Add(mesh.TexCoords.GetFloat4(j).XY);

					modelData.color.Add(color);

					//vertexcount++;
				}
			}

			modelData.vertexCount = modelData.positions.Count;
			return modelData;
		}

		private int BatchModel(Batch Geom, int indexAdd, ModelData modelData)
		{
			
			float3 v;
			int i,j;
			ushort vcount = 0;


			debug_log "TestModel "+modelData.vertexCount;

			//var sca = float3(20f); //30
			//var pos = float3(0,0f,40f);//15f,0);


			//var indexAdd = 0;
			var _vertices = new float3[modelData.vertexCount];
			var _normals = new float3[modelData.vertexCount];
			var _uvs = new float2[modelData.vertexCount];

			for(i = 0; i < modelData.vertexCount; i++)
			{
				v = modelData.positions[i];

				//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(-Math.PIf*.5f));
				
				//v = v  * sca + pos;

				var n = modelData.normals[i];

				//n = Uno.Vector.Transform(n, Uno.Quaternion.RotationX(-Math.PIf*.5f));

				var uv = modelData.uvs[i];


				Geom.Positions.Write(v);
				_vertices[i] = v;
				
				Geom.TexCoord0s.Write(uv);
				_uvs[i] = uv;
				
				Geom.Normals.Write(n);
				_normals[i] = n;

				Geom.Attrib0Buffer.Write(float4(modelData.color[i], 0));
				
				Geom.Indices.Write((ushort)vcount++);
			}

			indexAdd = simppafi.Utils.BatchHelper.WriteTangents(Geom, _vertices, _normals, _uvs, indexAdd);
			
			return indexAdd;
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

		block MyColor
		{
			float3 albedo : 
				req(Attrib0 as float4)
					prev * Attrib0.XYZ;
		}

		override public void OnUpdate()
		{


		}


		protected override void OnDraw(DrawContext dc)
    	{
    		//draw this, Geom, Shader, Material, virtual simppafi.RenderPipeline.PassFront;
    		//MyColor
    		//Rust1
    		draw this, Geom, Shader, simppafi.ShaderMaterial.Rust1, virtual simppafi.RenderPipeline.PassFront;
    		draw this, Geom2, Shader, simppafi.ShaderMaterial.Rust1, virtual simppafi.RenderPipeline.PassFront;
    		
		}

	}
}
