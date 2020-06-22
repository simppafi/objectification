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
	public class VisualTrees : simppafi.BaseVisual
	{
		private Batch				GeomTrees;
		private Batch				GeomRock1;
		private Batch				GeomRock2;
		private Batch				GeomRock5;
		private Batch				GeomRock6;
		private Random 				rand = new Random(1);

		//private texture2D			NormalTexture = import Texture2D("../Assets/dice_texture_normal.jpg");
		//private texture2D			ColorTexture = import Texture2D("../Assets/dice_texture.jpg");

		public VisualTrees()
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

			
			var radius = 15f;
			var angle = Math.PIf*2f / 14f;
			var curAngle = 0f;

			/*
			var dudeList1 = new [] {simppafi.Models.people1,simppafi.Models.people2,simppafi.Models.people3,simppafi.Models.people4,
									simppafi.Models.people5,simppafi.Models.people6,simppafi.Models.people7};

			var dudeList2 = new [] {simppafi.Models.people8,simppafi.Models.people9,simppafi.Models.people10,simppafi.Models.people11,
									simppafi.Models.people12,simppafi.Models.people13,simppafi.Models.people14};

			for(var i = 0; i < dudeList1.Length; i++)
			{
				radius = 5f + rand.NextFloat() * 10f;
				curAngle += angle;
				modelData = FetchModelData(	dudeList1[i], 
											modelData, 
											float3(radius*Math.Sin(curAngle),0f,radius*Math.Cos(curAngle)), 
											float3(8f), 
											false);
			}
			

			var modelData2 = new ModelData();
			
			for(var i = 0; i < dudeList2.Length; i++)
			{
				radius = 5f * rand.NextFloat() * 10f;
				curAngle += angle;
				modelData2 = FetchModelData(	dudeList2[i], 
												modelData2, 
												float3(radius*Math.Sin(curAngle),0f,radius*Math.Cos(curAngle)), 
												float3(8f), 
												false);
			}


			Geom = new Batch( modelData.vertexCount, modelData.vertexCount, true);

			BatchModel(	Geom, 0, modelData);

			Geom2 = new Batch( modelData2.vertexCount, modelData2.vertexCount, true);
			
			BatchModel(	Geom2, 0, modelData2);
			*/

			/*
			var tree1 = import Model("../Assets/models/trees/tree1.fbx");

			var modelData = new ModelData();
			modelData = FetchModelData(	tree1, 
										modelData, 
										float3(0,0f,0), 
										float3(50f), 
										true,
										float3(1f),
										float3(-Math.PIf*.5f, 0,0)
										);

			
			
			GeomTrees = new Batch( modelData.vertexCount, modelData.vertexCount, true);

			BatchModel(	GeomTrees, 0, modelData);



			var rock1 = import Model("../Assets/models/rock/rock1_low.fbx");
			var rock2 = import Model("../Assets/models/rock/rock2_low.fbx");
			var rock5 = import Model("../Assets/models/rock/rock5_low.fbx");
			var rock6 = import Model("../Assets/models/rock/rock6_low.fbx");
			

			var modelDataRock1 = new ModelData();
			for(var i = 0; i < 7; i++)
			{
				modelDataRock1 = FetchModelData(	rock1, 
													modelDataRock1, 
													float3(-50f+100f*rand.NextFloat(),75f * rand.NextFloat(),-50f+100f*rand.NextFloat()), 
													float3(5f + 25f * rand.NextFloat()), 
													true,
													float3(1f),
													float3(rand.NextFloat() * Math.PIf*2f,rand.NextFloat() * Math.PIf*2f,rand.NextFloat() * Math.PIf*2f)
													);
			}

			GeomRock1 = new Batch( modelDataRock1.vertexCount, modelDataRock1.vertexCount, true);
			BatchModel(	GeomRock1, 0, modelDataRock1);
			debug_log "rock1 "+modelDataRock1.vertexCount;

			var modelDataRock2 = new ModelData();
			for(var i = 0; i < 9; i++)
			{
				modelDataRock2 = FetchModelData(	rock2, 
													modelDataRock2, 
													float3(-50f+100f*rand.NextFloat(),75f * rand.NextFloat(),-50f+100f*rand.NextFloat()), 
													float3(5f + 25f * rand.NextFloat()), 
													true,
													float3(1f),
													float3(rand.NextFloat() * Math.PIf*2f,rand.NextFloat() * Math.PIf*2f,rand.NextFloat() * Math.PIf*2f)
													);
			}

			GeomRock2 = new Batch( modelDataRock2.vertexCount, modelDataRock2.vertexCount, true);
			BatchModel(	GeomRock2, 0, modelDataRock2);
			debug_log "rock2 "+modelDataRock2.vertexCount;

			var modelDataRock5 = new ModelData();
			for(var i = 0; i < 10; i++)
			{
				modelDataRock5 = FetchModelData(	rock5, 
													modelDataRock5, 
													float3(-50f+100f*rand.NextFloat(),75f * rand.NextFloat(),-50f+100f*rand.NextFloat()), 
													float3(5f + 25f * rand.NextFloat()), 
													true,
													float3(1f),
													float3(rand.NextFloat() * Math.PIf*2f,rand.NextFloat() * Math.PIf*2f,rand.NextFloat() * Math.PIf*2f)
													);
			}

			GeomRock5 = new Batch( modelDataRock5.vertexCount, modelDataRock5.vertexCount, true);
			BatchModel(	GeomRock5, 0, modelDataRock5);
			debug_log "rock5 "+modelDataRock5.vertexCount;

			var modelDataRock6 = new ModelData();
			for(var i = 0; i < 3; i++)
			{
				modelDataRock6 = FetchModelData(	rock6, 
													modelDataRock6, 
													float3(-50f+100f*rand.NextFloat(),75f * rand.NextFloat(),-50f+100f*rand.NextFloat()), 
													float3(5f + 25f * rand.NextFloat()), 
													true,
													float3(1f),
													float3(rand.NextFloat() * Math.PIf*2f,rand.NextFloat() * Math.PIf*2f,rand.NextFloat() * Math.PIf*2f)
													);
			}
			GeomRock6 = new Batch( modelDataRock6.vertexCount, modelDataRock6.vertexCount, true);
			BatchModel(	GeomRock6, 0, modelDataRock6);
			debug_log "rock6 "+modelDataRock6.vertexCount;

			base.Setup();
			*/
		}
/*
		private ModelData FetchModelData(Model model, ModelData modelData, float3 pos, float3 sca, bool gotUV = true, float3 color = float3(1f), float3 rot = float3(0f))
		{
			float3 v,n;
			int i,j;

			debug_log "MODEL DRAWABLE COUNT "+model.DrawableCount;

				
			ModelMesh mesh;
			for(i = 0; i < model.DrawableCount; i++)
			{
				mesh = model.GetDrawable(i).Mesh;
				
				for(j = 0; j < mesh.VertexCount; j++)
				{
					v = mesh.Positions.GetFloat4(j).XYZ;
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(rot.X));
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationY(rot.Y));
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationZ(rot.Z));
					modelData.positions.Add(v * sca + pos);
					
					n = mesh.Normals.GetFloat4(j).XYZ;
					n = Uno.Vector.Transform(n, Uno.Quaternion.RotationX(rot.X));
					n = Uno.Vector.Transform(n, Uno.Quaternion.RotationY(rot.Y));
					n = Uno.Vector.Transform(n, Uno.Quaternion.RotationZ(rot.Z));
					modelData.normals.Add(n);
					if(gotUV)
					{
						modelData.uvs.Add(mesh.TexCoords.GetFloat4(j).XY);
					}else{
						modelData.uvs.Add(uvFromSphere(mesh.Positions.GetFloat4(j).XYZ + float3(0,-0.875f,0)));
					}
					
					modelData.color.Add(color);
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


			debug_log "Trees "+modelData.vertexCount;

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

			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../Assets/models/trees/brown_diff.jpg"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			//float metallic : 						sample(import Texture2D("../Assets/models/people/dude/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			//float roughness : 						sample(import Texture2D("../Assets/models/trees/brown_rough.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../Assets/models/trees/brown_ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../Assets/models/trees/brown_normal.jpg"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);

			PixelColor : float4(albedo.XYZ*ao, 1f);
		}

		

		block ShaderRock1
		{
    		apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

			float2 TexCoord : prev;
			
			float3 albedo : 						sample(import Texture2D("../Assets/models/rock/rock1albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../Assets/models/rock/rock1metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../Assets/models/rock/rock1roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../Assets/models/rock/rock1ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../Assets/models/rock/rock1normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
			
			PixelColor : float4(albedo.XYZ*ao, 1f);
		}


		block ShaderRock2
		{
    		apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

			float2 TexCoord : prev;
			
			float3 albedo : 						sample(import Texture2D("../Assets/models/rock/rock2albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../Assets/models/rock/rock2metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../Assets/models/rock/rock2roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			//float ao : 								sample(import Texture2D("../Assets/models/rock/rock2ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../Assets/models/rock/rock2normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
			
			PixelColor : float4(albedo.XYZ*ao, 1f);
		}

		block ShaderRock5
		{
    		apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

			float2 TexCoord : prev;
			
			float3 albedo : 						sample(import Texture2D("../Assets/models/rock/rock5albedo.jpg"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../Assets/models/rock/rock5metallic.jpg"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../Assets/models/rock/rock5roughness.jpg"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../Assets/models/rock/rock5ao.jpg"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../Assets/models/rock/rock5normal.jpg"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
			
			PixelColor : float4(albedo.XYZ*ao, 1f);
		}


		block ShaderRock6
		{
    		apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

			float2 TexCoord : prev;
			
			float3 albedo : 						sample(import Texture2D("../Assets/models/rock/rock6albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../Assets/models/rock/rock6metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../Assets/models/rock/rock6roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			//float ao : 								sample(import Texture2D("../Assets/models/rock/rock6ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../Assets/models/rock/rock6normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
			
			PixelColor : float4(albedo.XYZ*ao, 1f);
		}



		block MyColor
		{
			float3 albedo : 
				req(Attrib0 as float4)
					prev * Attrib0.XYZ;
		}
		*/

		override public void OnUpdate()
		{


		}


		protected override void OnDraw(DrawContext dc)
    	{
    		/*
    		//draw this, Geom, Shader, Material, virtual simppafi.RenderPipeline.PassFront;

    		draw this, GeomTrees, Shader, MyColor, virtual simppafi.RenderPipeline.PassFront;
    		
    		draw this, GeomRock1, ShaderRock1, MyColor, virtual simppafi.RenderPipeline.PassFront;
    		draw this, GeomRock2, ShaderRock2, MyColor, virtual simppafi.RenderPipeline.PassFront;
    		draw this, GeomRock5, ShaderRock5, MyColor, virtual simppafi.RenderPipeline.PassFront;
    		draw this, GeomRock6, ShaderRock6, MyColor, virtual simppafi.RenderPipeline.PassFront;
    		*/
		}


	}
}
