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
	public class VisualParticleLO : simppafi.BaseVisual
	{
		private List<Batch>			GeomList = new List<Batch>();
		private Random 				rand = new Random(1);

		private float[] 			_Power;
		private float[] 			_PowerGoto;
		private float3[] 			_Color;
		private float3[] 			_LightPosition;

		public VisualParticleLO()
		{
			CastShadow = true;
			AddShadow = true;//false;
			UVCoordID = 3;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{


			AddParticleGroup(1000);
			//AddParticleGroup();
			//AddParticleGroup();
			//AddParticleGroup();
			
			debug_log "SETUP PARTICLE LO";

			base.Setup();
		}

		private void AddParticleGroup(int count = 0)
		{
			var points = PoissonDisk.getPoints();
			//debug_log("points.length "+points.Length);

			int lightCount = 5;

			var cube = simppafi.Geometry.VerticeGenerator.CreateTetrahedron();
			
			var cubeCount = 300;
			

			var verticeCount = cube.vertices.Count * cubeCount;
			var indiceCount =  cube.indices.Count * 3 * cubeCount;

			var Geom = new Batch(verticeCount, indiceCount, true);
			GeomList.Add(Geom);

			debug_log "VisualPeepsLO Vertices "+verticeCount+" cubeCount "+cubeCount;

			float3 v, center, av;
			int i, j, indexAdd = 0;
			float div;
			
			_Power = new float[lightCount];
			_PowerGoto = new float[lightCount];
			_Peak = new float[lightCount];
			_Color = new float3[lightCount];
			
			_LightPosition = new float3[lightCount];

			var _pos = new [] {	float3(0,50f,-80f), 
								float3(0,50f,-40f), 
								float3(0,50f,0), 
								float3(0,50f,40f), 
								float3(0,50f,80f)};

			var scale = float3(1f);//.01f + .05f * rand.NextFloat();
			for(j = 0; j < cubeCount; j++)
			{
				

				
				if(j < lightCount)
				{
					scale = float3(4f,80f,4f);

					center = float3(points[j*18].X * 80f, scale.Y, points[j*18].Y * 80f);
					
					//center = float3(_pos[j].X, scale.Y, _pos[j].Z);

					_Power[j] = 0f;
					_PowerGoto[j] = 0f;
					_Peak[j] = 0f;
					_LightPosition[j] = center;//float3(center.X, 2f+60f * rand.NextFloat(), center.Z);
					_Color[j] = float3(0f);
					//_Color[j] = simppafi.Color.ColorHexToRGB.HexToRGB(0xccccFF) * float3(1f, (.5f + rand.NextFloat()*1f), 1f);//0xccccFF);//0xf7e8d2); //0xe9af11

					//cube = cone;
				}

				scale = float3(10f, .05f, .05f);
				
				center = float3(-180f + 360f * rand.NextFloat(), 150f * rand.NextFloat(), -180f + 360f * rand.NextFloat());

				
				var color = float3(0.45f);

				var newVertexPositions = new List<float3>();
				var uvs = new float2[verticeCount];
				var rot = float3(Math.PIf*2f*rand.NextFloat(), Math.PIf*2f*rand.NextFloat(), Math.PIf*2f*rand.NextFloat());

				var r = rand.NextFloat() * Math.PIf * 2f;
				var r3 = float3(rand.NextFloat(),rand.NextFloat(), rand.NextFloat());
				for(i = 0; i < cube.vertices.Count; i++)
				{
					v = cube.vertices[i];
					
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(rot.X));
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationY(rot.Y));
					v = Uno.Vector.Transform(v, Uno.Quaternion.RotationZ(rot.Z));
					
					

					var uv = uvFromSphere(v);//cube.texCoords[i];
					av = v * scale + center;
					Geom.Positions.Write(av);// * spike);
					newVertexPositions.Add(av);
					
					//index
					Geom.InstanceIndices.Write((ushort)(j%lightCount));


					// from
					//Geom.Attrib0Buffer.Write(float4(v * scale + center, r));
					// to
					//Geom.Attrib1Buffer.Write(float4(v * scale + center, 0));

					//Geom.Attrib3Buffer.Write(float4(r3, r));
					

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


			//float mv :
			//	req(Attrib0 as float4)
			//		(1f + Math.Sin((float)Time * .1f + Attrib0.W)) * .5f;

			/*
			float t : 
				req(Attrib3 as float4)
				req(tim as float)
					tim * (.9f+Attrib3.W*4f); 

			float up_force :
				req(goUp as float)
				req(Attrib3 as float4)
					t * (goUp * (1f-Attrib3.X*.3f));

			float down_force : t; 

			float force :
				Math.Max(0f,  up_force - down_force);


			// ROTATION
			VertexPosition :
				req(tim as float)
				req(rot as float)
				req(Attrib3 as float4)
					//Uno.Vector.Transform(prev, Uno.Quaternion.RotationY(t + Attrib3.Y));
					prev * .1f;
					//Uno.Vector.Transform(prev, Uno.Quaternion.RotationAxis(float3(1,0,1), rot)) * .05f;

			// Position
			VertexPosition :
				req(Attrib0 as float4)
					prev + Attrib0.XYZ + float3(0, force, 0);
			*/

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


		//private float goUp = 1f;
		//private float goUpGoto = 1f;
		//private float rot = 0f;

		private float[] _dimm = new [] {0.99f,0.9f,0.9f,0.9f,0.9f};
		override public void Hit(float val) {

			if(val == 3f) //piano
			{
				//debug_log "PIANO";
				_Power[0] = 3f;

				//goUpGoto += .2f;
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

		private float tim = 0f;
		override public void OnUpdate()
		{
			tim += (float)Fuse.Time.FrameInterval*.25f;

			var ease = Math.Min(.75f, (float)Fuse.Time.FrameInterval * 20f);
			
			//goUp = goUp + (goUpGoto - goUp) * (float)Fuse.Time.FrameInterval;
			//goUpGoto = goUpGoto + (1f - goUpGoto) * (float)Fuse.Time.FrameInterval;
			//rot += (goUp-1f) * .1f;

			var l = _LightPosition.Length;
			for(var i = 0; i < l; i++)
			{
				_PowerGoto[i] = _PowerGoto[i] + ((_Power[i]+_Peak[i])-_PowerGoto[i]) * ease;
				
				simppafi.RenderPipeline.Lights[i].Position = _LightPosition[i] + float3(0,-50f,0);
				simppafi.RenderPipeline.Lights[i].Power = _PowerGoto[i];
				simppafi.RenderPipeline.Lights[i].Scale = 30f + Math.Min(30f, 30f * _PowerGoto[i]);
				_Color[i] = simppafi.RenderPipeline.Lights[i].Color * .75f;

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
