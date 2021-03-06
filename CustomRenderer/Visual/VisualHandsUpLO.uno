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
	public class VisualHandsUpLO : simppafi.BaseVisual
	{
		private List<Batch>			GeomList = new List<Batch>();
		private Random 				rand = new Random(1);

		private float[] 			_Power;
		private float[] 			_PowerGoto;
		private float3[] 			_Color;
		private float3[] 			_LightPosition;

		public VisualHandsUpLO()
		{
			CastShadow = true;
			AddShadow = true;//false;
			UVCoordID = 3;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{
			/*var _pst = PoissonDisk.getPoints();
			pst = new List<float2>();
			for(var i = 0; i < _pst.Length; i++)
			{
				pst.Add(_pst[i] * 10f);
			}*/
			//pst = new float2[_pst.Length];
			//Uno.Array.Copy(_pst, pst, _pst.Length);

			AddParticleGroup(35); //6405 tetrahedron // max points 8192
			//AddParticleGroup();
			//AddParticleGroup();
			//AddParticleGroup();
			

			base.Setup();
		}

		/*
		List<float2> pst;
		private float2 getPoint(float scale, int offset)
		{
			var res = float2(pst[offset].X, pst[offset].Y);
			for(var i = offset; i < pst.Count; i++)
			{
				var curPt = res;
				var compPt = pst[i];
				if(Vector.Length(compPt - curPt) < scale*2f)
				{
					pst.RemoveAt(i);
				}
			}
			return res;
		}*/

		private void AddParticleGroup(int count = 0)
		{
			var points = PoissonDisk.getPoints();
			//debug_log "points.length " + points.Length;

			int lightCount = 5;

			//var cube = simppafi.Geometry.VerticeGenerator.CreateTetrahedron();
			var cube = simppafi.Geometry.VerticeGenerator.CreateIcoSphere(3);
			//var cube = simppafi.Geometry.VerticeGenerator.CreateCubeEight();

			var cubeCount = 65535/4;
			if(count > 0)
			{
				cubeCount = count;
			}

			var verticeCount = cube.vertices.Count * cubeCount;
			var indiceCount =  cube.indices.Count * 3 * cubeCount;

			var Geom = new Batch(verticeCount, indiceCount, true);
			GeomList.Add(Geom);

			debug_log "VisualHandsUpLO Vertices "+verticeCount+" cubeCount "+cubeCount;

			float3 v, center, av;
			int i, j, indexAdd = 0;
			float div;
			
			_Power = new float[lightCount];
			_PowerGoto = new float[lightCount];
			_Peak = new float[lightCount];
			//_Color = new float3[cubeCount];
			_Color = new [] {
				/*simppafi.Color.ColorHexToRGB.HexToRGB(0x225378), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x1695A3), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xACF0F2), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xF3FFE2), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xEB7F00)*/
				/*
				simppafi.Color.ColorHexToRGB.HexToRGB(0xF8EFB6), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xFEBAC5), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x6CD1EA), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xFACFD7), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xC2EAE9)
				*/
				///*
				simppafi.Color.ColorHexToRGB.HexToRGB(0x778691), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xE3DB9A), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xF5FCD0), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xB1C2B3), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xC7B773)
				//*/
				/*
				simppafi.Color.ColorHexToRGB.HexToRGB(0x3399CC), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x67B8DE), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x91C9E8), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xB4DCED), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xE8F8FF)
				*/
			};
			_LightPosition = new float3[lightCount];

			var _pos = new [] {	float3(0f,60f,0f), 
								float3(-110f,60f,-110f),
								float3(-110f,60f,110f), 
								float3(110f,60f,110f), 
								float3(110f,60f,-110f) };

			var scale = float3(1f);//.01f + .05f * rand.NextFloat();
			for(j = 0; j < cubeCount; j++)
			{
				
				if(j < lightCount)
				{
					if(j == 0)
					{
						scale = float3(36f,36f,36f);
					}else{
						scale = float3(10f,10f,10f);
					}
					//center = float3(_pos[j].X, scale.Y, _pos[j].Z);
					center = _pos[j];
					_Power[j] = 0f;
					_PowerGoto[j] = 0f;
					_Peak[j] = 0f;
					_LightPosition[j] = center;//float3(center.X, 2f+60f * rand.NextFloat(), center.Z);
					//_Color[j] = simppafi.Color.ColorHexToRGB.HexToRGB(0xccccFF) * float3(1f, (.5f + rand.NextFloat()*1f), 1f);//0xccccFF);//0xf7e8d2); //0xe9af11
				}else{

					var sca = rand.NextFloat()*2f;
					scale = float3(sca);
					
					//var pt = getPoint(sca, 0);
					center = float3(	points[8+j*8].X * 120f,
										scale.Y,
										points[8+j*8].Y * 120f);
					
				}
				
				var color = float3(0.45f);

				var newVertexPositions = new List<float3>();
				var uvs = new float2[verticeCount];

				for(i = 0; i < cube.vertices.Count; i++)
				{
					v = cube.vertices[i];

					if(j == 0)
					{
						//v = float3(v.X, v.Y, v.Z*( Math.Sin( Math.Abs(v.X)*Math.PIf)) );
						//var vz = Math.Sin(v.Z * Math.PIf);
						//var vz = Math.Clamp(Math.Abs(v.Z), .1f, 1f);
						/*if(v.Z > 0f)
						{
							//vz = v.Z + .5f;//Math.Sin(v.Z * Math.PIf);
							vz = Math.Sin(v.Z * Math.PIf * .5f + Math.PIf*.5f);
						}else{
							//vz = v.Z - .5f;//-Math.Sin(v.Z * Math.PIf);
							vz = -Math.Sin(Math.Abs(v.Z) * Math.PIf * .5f + Math.PIf*.5f);
						}*/

						//v = float3(v.X * vz, v.Y * vz , v.Z );
					}
					
					var uv = uvFromSphere(v);//cube.texCoords[i];
					av = v * scale + center;
					Geom.Positions.Write(av);// * spike);
					newVertexPositions.Add(av);
					
					//index
					Geom.InstanceIndices.Write((ushort)(j%lightCount));

					// from
					//Geom.Attrib0Buffer.Write(float4(center, 0));
					// to
					//Geom.Attrib1Buffer.Write(float4(center, 0));
					

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

			//VertexPosition : 
			//	req(tim as float)
			//		Uno.Vector.Transform(prev, Uno.Quaternion.RotationY(tim));

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


		override public void Hit(float val) {

			if(val == 3f) //piano
			{
				//debug_log "PIANO";
				_Power[0] = 3f;
			}

			if(val == 0f) //tom
			{
				//_Power[(int)(1+Math.Round(rand.NextFloat()*2f))] = 1f;
				if(rand.NextFloat() > .5f)
				{
					_Power[1] = 1f;
				}else{
					_Power[2] = 1f;
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
		private float[] _dimm = new [] {0.99f,0.9f,0.9f,0.9f,0.9f};

		private float move = 0f;
		//private float tim = 0f;
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
			move += (float)Fuse.Time.FrameInterval * .5f;
			var l = _LightPosition.Length;
			for(var i = 0; i < l; i++)
			{
				_PowerGoto[i] = _PowerGoto[i] + ((_Power[i]+_Peak[i])-_PowerGoto[i]) * ease;
				
				simppafi.RenderPipeline.Lights[i].Position = _LightPosition[i];// + float3(0,-50f,0);
				simppafi.RenderPipeline.Lights[i].Power = _PowerGoto[i];
				simppafi.RenderPipeline.Lights[i].Scale = 80f;// * _PowerGoto[i];
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
