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
	public class VisualDoorsLO : simppafi.BaseVisual
	{
		private List<Batch>			GeomList = new List<Batch>();
		private Random 				rand = new Random(1);

		private float[] 			_Power;
		private float[] 			_PowerGoto;
		private float3[] 			_Color;
		private float3[] 			_LightPosition;

		public VisualDoorsLO()
		{
			CastShadow = true;
			AddShadow = true;//false;
			UVCoordID = 3;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{


			AddParticleGroup(5);
			//AddParticleGroup();
			//AddParticleGroup();
			//AddParticleGroup();
			

			base.Setup();
		}

		private void AddParticleGroup(int count = 0)
		{
			var cube = simppafi.Geometry.VerticeGenerator.CreateCubeSphereHalf(8, true);//.CreateHexcon(.1f, 1f);

			var cubeCount = 65535/4;
			if(count > 0)
			{
				cubeCount = count;
			}

			var verticeCount = cube.vertices.Count * cubeCount;
			var indiceCount =  cube.indices.Count * 3 * cubeCount;

			var Geom = new Batch(verticeCount, indiceCount, true);
			GeomList.Add(Geom);

			debug_log "VisualRoadLO Vertices "+verticeCount+" cubeCount "+cubeCount;

			float3 v, center, av;
			int i, j, indexAdd = 0;
			float div;
			
			_Power = new float[cubeCount];
			_PowerGoto = new float[cubeCount];
			_Peak = new float[cubeCount];
			//_Color = new float3[cubeCount];
			_Color = new [] {
				///*
				simppafi.Color.ColorHexToRGB.HexToRGB(0x225378), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x1695A3), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xACF0F2), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xF3FFE2), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xEB7F00)
				//*/
				/*
				simppafi.Color.ColorHexToRGB.HexToRGB(0xF8EFB6), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xFEBAC5), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x6CD1EA), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xFACFD7), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xC2EAE9)
				//*/
				/*
				simppafi.Color.ColorHexToRGB.HexToRGB(0xC7B773), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xE3DB9A), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xF5FCD0), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xB1C2B3), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x778691)
				//*/
				/*
				simppafi.Color.ColorHexToRGB.HexToRGB(0x3399CC), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x67B8DE), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x91C9E8), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xB4DCED), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xE8F8FF)
				//*/
				/*simppafi.Color.ColorHexToRGB.HexToRGB(0xFFBE00), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xFFDC00), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xFFD10F), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xFFDE20), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xE8CA00)*/
				/*
				simppafi.Color.ColorHexToRGB.HexToRGB(0x7f33cc), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x5333cc), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x7a28e9), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x2863e9), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xe228e9)
				*/
			};
			_LightPosition = new float3[cubeCount];

			//var _pos = new [] {float2(0,-25f), float2(0f,25f), float2(100f,50f), float2(100f,-50f), float2(-100f,0f)};
			var _pos = new [] {	float3(-100f,0f,-100f),
								float3(-100f,0f,100f), 
								float3(0f,0f,0f), 
								float3(100f,0f,100f), 
								float3(100f,0f,-100f) 
							};

			var _scales = new [] {
									float3(12f,12f,12f),
									float3(12f,12f,12f),
									float3(12f,12f,12f),
									float3(12f,12f,12f),
									float3(12f,12f,12f)
									};

			var scale = float3(1f);//.01f + .05f * rand.NextFloat();
			for(j = 0; j < cubeCount; j++)
			{
				
				scale = _scales[j];

				center = _pos[j] + float3(0,1f,-3f);//float3(_pos[j].X, scale.Y, _pos[j].Y);
				
				_Power[j] = 0f;
				_PowerGoto[j] = 0f;
				_Peak[j] = 0f;
				_LightPosition[j] = center;
				
				var color = float3(0.45f);

				var newVertexPositions = new List<float3>();
				var uvs = new float2[verticeCount];

				for(i = 0; i < cube.vertices.Count; i++)
				{
					v = cube.vertices[i];
					
					var uv = uvFromSphere(v);//var uv = cube.texCoords[i];
					av = v * scale + center;
					Geom.Positions.Write(av);// * spike);
					newVertexPositions.Add(av);
					
					//index
					Geom.InstanceIndices.Write((ushort)j);

					// from
					Geom.Attrib0Buffer.Write(float4(center, 0));
					// to
					Geom.Attrib1Buffer.Write(float4(center, 0));
					

					//color
					Geom.Attrib2Buffer.Write(float4(color, 0));

					Geom.TexCoord0s.Write(uv);
					uvs[i] = uv;
				}

				indexAdd = simppafi.Utils.BatchHelper.WriteIndicesNormalsTangents(Geom, cube, newVertexPositions, uvs, indiceCount, indexAdd);

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

		private float3 PositionOnSphereSurface(float u, float v)
		{
			var pos = float3(0);
			pos.Z = -1f + 2f * u;
			var z2 = Math.Sqrt(1f - pos.Z * pos.Z);
			var phi = 2f * Math.PIf * v;
			pos.X = z2 * Math.Cos(phi);
			pos.Y = z2 * Math.Sin(phi);
			return pos;
		}

		private float3 egg(float3 v)
		{
			var bo = .6f + (1f - (v.Y + 1f) * .5f) * .3f;
			return v * float3(bo, 1f, bo);
		}


		override public void OnOff() {}



		block Shader
		{
    		apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

			//int id : req(InstanceIndex as float) (int)InstanceIndex;

			//VertexPosition :
			//	req(_LightPosition as float3[])
			//		prev + _LightPosition[id];

			//PixelColor : float4(albedo.XYZ*ao, 1f);
			PixelColor : float4(1,1,1,1);
		}

		block MyColor
		{
			int id : req(InstanceIndex as float) (int)InstanceIndex;

			float Power : 
				req(_PowerGoto as float[])
						_PowerGoto[id];

			float3 Color : 
				req(_Color as float3[])
						_Color[id];

			PixelColor : float4(Color * Power, 1f);

			//PixelColor : 
			//	req(Attrib2 as float4)
			//		float4(Attrib2.XYZ * Power, 1f);
		}


		private float[] _dimm = new [] {0.99f,0.9f,0.9f,0.9f,0.9f};
		override public void Hit(float val) {

			if(val == 3f) //piano
			{
				//debug_log "PIANO";
				_Power[0] = 3f;
			}

			if(val == 0f || val == 4f) //tom
			{
				if(rand.NextFloat() > .5f)
				{
					if(_Power[1] < 2f)
					{
						_Power[1] += .25f;
					}
				}else{
					if(_Power[2] < 2f)
					{	
						_Power[2] += .25f;
					}
				}
			}
			if(val == 1f) //snare
			{
				_Power[3] = 2f;
			}
			if(val == 2f) //kick
			{
				_Power[4] = 1f;
			}
			
		}
		private float[] 			_Peak;
		override public void Peak(float power)
		{
			for(var i = 0; i < _Peak.Length; i++)
			{
				_Peak[i] = power;
			}
		}

		override public void OnUpdate()
		{
			var ease = Math.Min(.75f, (float)Fuse.Time.FrameInterval * 20f);
			
			var l = _LightPosition.Length;
			for(var i = 0; i < l; i++)
			{
				_PowerGoto[i] = _PowerGoto[i] + ((_Power[i]+_Peak[i])-_PowerGoto[i]) * ease;
				
				simppafi.RenderPipeline.Lights[i].Position = _LightPosition[i] + float3(0,60f,0);
				simppafi.RenderPipeline.Lights[i].Power = _PowerGoto[i];
				simppafi.RenderPipeline.Lights[i].Scale = 50f + Math.Min(50f, 50f * _PowerGoto[i]);
				_Color[i] = simppafi.RenderPipeline.Lights[i].Color;

				_Power[i] *= _dimm[i];
			}

		}

		protected override void OnDraw(DrawContext dc)
    	{
    		for(var i = 0; i < GeomList.Count; i++)
    		{
    			draw this, GeomList[i], Shader, MyColor, virtual simppafi.RenderPipeline.PassFront;
    		}
		}

	}
}
