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
	public class VisualBoxesObj : simppafi.BaseVisual
	{
		private Batch				Geom;
		private Batch				Geom2;
		private Random 				rand = new Random(1);

		//private texture2D			NormalTexture = import Texture2D("../Assets/dice_texture_normal.jpg");
		//private texture2D			ColorTexture = import Texture2D("../Assets/dice_texture.jpg");

		public VisualBoxesObj()
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

			

			modelData = FetchModelData(		import Model("../Assets/models/cube_hole_broken.fbx"), 
											modelData, 
											float3(-30f,15f,0f-40f), 
											float3(0,-Math.PIf*.5f,0),
											float3(15f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);

			
			modelData = FetchModelData(		import Model("../Assets/models/cube_hole_2_broken.fbx"), 
											modelData, 
											float3(0f,30f,0f-40f), 
											float3(Math.PIf*.5f,-Math.PIf*.5f,0),
											float3(30f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);


			modelData = FetchModelData(		import Model("../Assets/models/cube_hole_broken.fbx"), 
											modelData, 
											float3(-5f,45f,10f-40f), 
											float3(0,-Math.PIf*.5f,0),
											float3(15f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);

			modelData = FetchModelData(		import Model("../Assets/models/cube_hole_broken.fbx"), 
											modelData, 
											float3(30f,45f,0f-40f), 
											float3(0,-Math.PIf*.5f,0),
											float3(15f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);


			modelData = FetchModelData(		import Model("../Assets/models/cube_hole_3_broken.fbx"), 
											modelData, 
											float3(30f,30f,0f-40f), 
											float3(0,-Math.PIf*.5f,0),
											float3(30f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);
			
			Geom = new Batch( modelData.vertexCount, modelData.vertexCount, true);

			BatchModel(	Geom, 0, modelData);
			//*/

			var _pos = new [] {	float3(-45f,0f,0f-35f) + float3(0,2f,0),
								float3(15f,30f,0f-35f) + float3(0,1.5f,0), 
								float3(-20f,30f,10f-35f) + float3(0,1.5f,0), 
								float3(0f,0f,0f-35f) + float3(0,2f,0), 
								float3(60f,2f,0f-35f) + float3(0,1f,0) 
							};

			var modelData2 = new ModelData();
			modelData2 = FetchModelData(	simppafi.Models.people15, 
											modelData2, 
											_pos[0], 
											float3(0,Math.PIf * 2f * rand.NextFloat(),0),
											float3(10f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);

			modelData2 = FetchModelData(	simppafi.Models.people16, 
											modelData2, 
											_pos[1], 
											float3(0,Math.PIf * 2f * rand.NextFloat(),0),
											float3(10f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);

			modelData2 = FetchModelData(	simppafi.Models.people17, 
											modelData2, 
											_pos[2], 
											float3(0,Math.PIf * 2f * rand.NextFloat(),0),
											float3(10f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);

			modelData2 = FetchModelData(	simppafi.Models.people18, 
											modelData2, 
											_pos[3], 
											float3(0,Math.PIf * 2f * rand.NextFloat(),0),
											float3(10f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);

			modelData2 = FetchModelData(	simppafi.Models.people19, 
											modelData2, 
											_pos[4], 
											float3(0,Math.PIf * 2f * rand.NextFloat(),0),
											float3(10f), 
											false,
											float3(1,1,1)//simppafi.Color.ColorHexToRGB.HexToRGB(0xd9d893)//0x56f1ff););
											);

			Geom2 = new Batch( modelData2.vertexCount, modelData2.vertexCount, true);

			BatchModel(	Geom2, 0, modelData2);
			


			base.Setup();
		}

		private ModelData FetchModelData(Model model, ModelData modelData, float3 pos, float3 rot, float3 sca, bool gotUV = true, float3 color = float3(1f))
		{
			float3 v, n;
			int i,j;

			debug_log "VisualBoxesObj DRAWABLE COUNT "+model.DrawableCount;

				
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
				//debug_log "-------- "+i+" / "+model.DrawableCount;

				debug_log i+" "+mesh.Name;

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
					
					modelData.positions.Add(v * sca + pos);// + avCent);
					
					modelData.normals.Add(n);
					
					if(gotUV)
					{
						modelData.uvs.Add(mesh.TexCoords.GetFloat4(j).XY);
					}else{
						modelData.uvs.Add(uvFromSphere(mesh.Positions.GetFloat4(j).XYZ + float3(0,-0.5f,0)));
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


			debug_log "VisualBoxesObj "+modelData.vertexCount;

			//var sca = float3(20f); //30
			//var pos = float3(0,0f,40f);//15f,0);


			//var indexAdd = 0;
			var _vertices = new float3[modelData.vertexCount];
			var _normals = new float3[modelData.vertexCount];
			var _uvs = new float2[modelData.vertexCount];

			for(i = 0; i < modelData.vertexCount; i++)
			{
				v = modelData.positions[i];

				var n = modelData.normals[i];

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

			CullFace : Uno.Graphics.PolygonFace.None;

			/*
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../Assets/models/lion/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../Assets/models/lion/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../Assets/models/lion/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../Assets/models/lion/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../Assets/models/lion/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
			*/
			

			PixelColor : float4(albedo.XYZ*ao, 1f);
		}

		block ShaderDude
		{
    		apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

			/*
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../Assets/models/lion/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../Assets/models/lion/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../Assets/models/lion/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../Assets/models/lion/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../Assets/models/lion/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
			*/
			

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

    		draw this, Geom, Shader, simppafi.ShaderMaterial.Rust4, MyColor, virtual simppafi.RenderPipeline.PassFront;
    		
    		draw this, Geom2, ShaderDude, simppafi.ShaderMaterial.Rust1, MyColor, virtual simppafi.RenderPipeline.PassFront;
    		
		}

	}
}
