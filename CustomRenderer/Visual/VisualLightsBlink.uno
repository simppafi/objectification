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
	public class VisualLightsBlink : simppafi.BaseVisual
	{
		public int LightCount = 0;
		public bool RenderLightSources = true;

		private texture2D			ParticleTexture = import Texture2D("../Assets/particle2.png");

		private Batch				Geom;
		private Batch				GeomParticles;

		private Random rand = new Random(1);

		private simppafi.Geometry.GeometryVO cube = simppafi.Geometry.VerticeGenerator.CreateCubeEight();
		private float3[] QuadVertices = new [] {float3(-1,-1,0),float3(1,-1,0),float3(1,1,0),float3(-1,1,0)};
		private ushort[] QuadIndices = new ushort[] { 0,1,2,2,3,0 };

		private List<EnvShadow> 	Shadows = new List<EnvShadow>();
		private List<float3> 		LightPositions = new List<float3>();
		private List<float> 		LightScales = new List<float>();
		private List<float3> 		LightColors = new List<float3>();
		private List<float> 		LightPowers = new List<float>();

		public VisualLightsBlink()
		{
			SkipUVDraw = true;
		}

		override public void Settings() {}

		override public void Setup()
		{
			
			base.Setup();
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

		override public void OnOff() {}


		public int AddLightWithShadow(EnvShadow shadow, float scale, float3 color, float power = 1f, bool build = false)
		{
			Shadows.Add(shadow);
			LightPositions.Add(shadow.Light.Position);
			LightScales.Add(scale);
			LightColors.Add(color);
			LightPowers.Add(power);

			LightCount++;

			if(build)
				ReBuild();

			return LightCount-1;
		}


		public int AddLight(float3 position, float scale, float3 color, float power = 1f, bool build = false)
		{
			LightPositions.Add(position);
			LightScales.Add(scale);
			LightColors.Add(color);
			LightPowers.Add(power);

			LightCount++;

			if(build)
				ReBuild();

			return LightCount-1;
		}

		public int RemoveLight(int id)
		{
			if(LightCount > 0)
			{
				LightPositions.RemoveAt(id);
				LightScales.RemoveAt(id);
				LightColors.RemoveAt(id);
				LightPowers.RemoveAt(id);
				
				LightCount--;

				ReBuild();
			}
			return LightCount;
		}

		public void MoveLight(float3 newPosition, float newScale = 1f, int id)
		{
			var position = LightPositions[id] = newPosition;
			var scale = LightScales[id] * newScale;
			int i;
						
			Geom.Attrib0Buffer.Position = Geom.Attrib0Buffer.StrideInBytes * cube.vertices.Count * id;
			for(i = 0; i < cube.vertices.Count; i++)
			{
				Geom.Attrib0Buffer.Write(float4(position,scale));
			}
			Geom.Attrib0Buffer.Invalidate();
			

			GeomParticles.Attrib0Buffer.Position = GeomParticles.Attrib0Buffer.StrideInBytes * QuadVertices.Length * id;
			for(i = 0; i < QuadVertices.Length; i++)
			{
				GeomParticles.Attrib0Buffer.Write(float4(position, scale*0.025f));
			}
			GeomParticles.Attrib0Buffer.Invalidate();
		}


		public void SetPower(float newPower, int id)
		{
			var color = LightColors[id];
			var power = LightPowers[id] = newPower;

			Geom.Attrib1Buffer.Position = Geom.Attrib1Buffer.StrideInBytes * cube.vertices.Count * id;
			for(var i = 0; i < cube.vertices.Count; i++)
			{
				Geom.Attrib1Buffer.Write(float4(color,power));
			}
			Geom.Attrib1Buffer.Invalidate();
			

			GeomParticles.Attrib1Buffer.Position = GeomParticles.Attrib1Buffer.StrideInBytes * QuadVertices.Length * id;
			for(var i = 0; i < QuadVertices.Length; i++)
			{
				GeomParticles.Attrib1Buffer.Write(float4(color, power));
			}
			GeomParticles.Attrib1Buffer.Invalidate();

		}

		private float RotationAdd = 0f;
		private float RotationY = 0f;
		public void AddRotation(float val)
		{
			RotationAdd += val;

			var id = (int)(rand.NextFloat() * LightPositions.Count);
			//var pos = LightPositions[id];
			MoveLight(float3(-400f + 800f * rand.NextFloat(), -200f + 400f * rand.NextFloat(), -400f + 800f * rand.NextFloat()), rand.NextFloat()*2f, id);
		}

		private float OverallPower = 0f;
		public void PowerOut()
		{
			OverallPower = 3f * rand.NextFloat();
		}


		public void Clear()
		{
			LightPositions.Clear();
			LightScales.Clear();
			LightColors.Clear();
			LightPowers.Clear();

			Geom = null;
			GeomParticles = null;
			LightCount = 0;
		}

		public void ReBuild()
		{
			if(Geom != null)
			{
				Geom = null;
			}

			var verticeCount = cube.vertices.Count * LightCount;
			var indiceCount = cube.indices.Count * LightCount * 3;

			Geom = new Batch(verticeCount, indiceCount, false);

			float3 v;
			int j, i;
			int vcount = 0;
			float3 position, color;
			float scale,power;

			for(j = 0; j < LightCount; j++)
			{
				position = LightPositions[j];
				scale = LightScales[j];
				color = LightColors[j];
				power = LightPowers[j];

				for(i = 0; i < cube.vertices.Count; i++)
				{
					v = cube.vertices[i];
					Geom.Positions.Write(v);
					Geom.Attrib0Buffer.Write(float4(position,scale));
					Geom.Attrib1Buffer.Write(float4(color,power));
				}

				for(i = 0; i < cube.indices.Count; i++)
				{
					Geom.Indices.Write((ushort)(cube.indices[i].X + vcount));
					Geom.Indices.Write((ushort)(cube.indices[i].Y + vcount));
					Geom.Indices.Write((ushort)(cube.indices[i].Z + vcount));
				}
				vcount += cube.vertices.Count;
			}



			// PARTICLE

			if(GeomParticles != null)
			{
				GeomParticles = null;
			}

			verticeCount = LightCount * QuadVertices.Length;
			indiceCount = LightCount * QuadIndices.Length;

			float sca;
			int indexAdd = 0;

			GeomParticles = new Batch(verticeCount, indiceCount, false);

			for(j = 0; j < LightCount; j++)
			{
				sca = LightScales[j]*.025f;
				position = LightPositions[j];
				color = LightColors[j];
				power = LightPowers[j];

				for(i = 0; i < QuadVertices.Length; i++)
				{
					v = QuadVertices[i];
					GeomParticles.Positions.Write(v*sca);

					GeomParticles.Attrib0Buffer.Write(float4(position, sca)); // MOVE FROM, sca

					GeomParticles.Attrib1Buffer.Write(float4(color, power)); // MOVE FROM, sca

					GeomParticles.Normals.Write(v);

					GeomParticles.TexCoord0s.Write((v.XY + float2(1)) * .5f);
				}
				for(i = 0; i < QuadIndices.Length; i++)
				{
					GeomParticles.Indices.Write((ushort)(QuadIndices[i] + indexAdd));
				}

				indexAdd += QuadVertices.Length;
			}

		}

		block Shader
		{
			apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;
    		
			float3 LightPosition :
				req(Attrib0 as float4)
				req(RotationY as float)
					Vector.Transform(Attrib0.XYZ, Quaternion.RotationY(RotationY) );

			float Radius :
				req(Attrib0 as float4)
					Attrib0.W;

			float3 VertexPositionOffset :
				req(Attrib0 as float4)
					LightPosition + VertexPosition * Radius;

			WorldPosition: Vector.Transform(float4(VertexPositionOffset.XYZ, 1), World).XYZ;

			LightPosition : Vector.Transform(float4(prev, 1), World).XYZ;

			float LightRadius : Radius;

			float3 LightColor :
				req(Attrib1 as float4)
					Attrib1.XYZ;

			float LightPower :
				req(Attrib1 as float4)
				req(OverallPower as float)
					Attrib1.W * OverallPower;

			PixelColor : float4(0,0,0,0);
		}


		block ShaderParticles
		{
			apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;
    		
			WriteDepth: false;
		    DepthTestEnabled: false;
		   	BlendSrc: Uno.Graphics.BlendOperand.One;
			BlendDst: Uno.Graphics.BlendOperand.One;
			BlendEnabled: true;
			CullFace: Uno.Graphics.PolygonFace.Back;
			
			float3 VertexPositionOffset :
				req(Attrib0 as float4)
				req(RotationY as float)
					Vector.Transform(Attrib0.XYZ, Quaternion.RotationY(RotationY) );

			float3 Size : 
				req(OverallPower as float)
					VertexPosition * OverallPower;

			WorldPosition: Vector.Transform(float4(VertexPositionOffset.XYZ, 1), World).XYZ;

			ViewPosition: (Vector.Transform(float4(WorldPosition, 1), View) + float4(Size, 0)).XYZ;


			apply simppafi.RenderLibrary.FXDeferred;
			float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

			LinearDepth : pixel prev;

			float cut : Math.Round(((_depth - LinearDepth) + 1f) * .5f);

			PixelColor :
				req(ParticleTexture as texture2D)
				req(Attrib1 as float4)
					float4( sample(ParticleTexture, TexCoord).XYZ * Attrib1.XYZ * Attrib1.W, 1) * cut;

		}

		
		override public void OnUpdate()
		{
			//RotationAdd *= .8f;
			//RotationY += (float)Fuse.Time.FrameInterval;//.1f;//RotationAdd;

			OverallPower = 1f;//rand.NextFloat();
			//OverallPower *= .9f;//OverallPower + (1f - OverallPower) * .1f;

			var timeInterval = (float)Fuse.Time.FrameInterval;
			var time = (float)Fuse.Time.FrameTime;
			var div = 0f;
			for(var i = 0; i < LightPositions.Count; i++)
			{
				div = (float)i/(float)LightPositions.Count;
				//LightPositions[i] = 
				//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(angle.X));

				//Shadows[i].lightPosition = Uno.Vector.Transform(Shadows[i].lightPosition, Uno.Quaternion.RotationY(timeInterval));

				//Shadows[i].lightPosition = Uno.Vector.Transform(Shadows[i].lightPosition, Uno.Quaternion.RotationX(Math.Sin(time*6f + i*3.42f) * .03f));

				var angle = div * Math.PIf * 2f + Math.Sin(time*.1f + i) * 10f;
				var rad = 90f + 80f * Math.Sin(time+i);
				Shadows[i].Light.Position = float3(
													Math.Sin(angle) * rad,
													40f,//20f + 18f * Math.Sin(angle*2f),
													Math.Cos(angle) * rad
													);

				MoveLight(Shadows[i].Light.Position, LightPowers[i], i);
			}
		}

		protected override void OnDraw(DrawContext dc)
    	{
    		if(Geom != null)
				draw this, Geom, Shader, virtual simppafi.RenderPipeline.PassFront;
		}

		override public void DrawParticles(DrawContext dc)
		{
			if(GeomParticles != null && RenderLightSources)
			{
				draw this, GeomParticles, ShaderParticles;
			}
		}

	}
}
