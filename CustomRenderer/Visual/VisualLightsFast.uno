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
using simppafi.Object;

namespace simppafi
{
	public class VisualLightsFast : simppafi.BaseVisual
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

		/*private List<EnvShadow> 	Shadows = new List<EnvShadow>();
		private List<float3> 		LightPositions = new List<float3>();
		private List<float> 		LightScales = new List<float>();
		private List<float3> 		LightColors = new List<float3>();
		private List<float> 		LightPowers = new List<float>();
		*/
		private List<ObjectLight> 	Lights = new List<ObjectLight>();

		private float3[]			_LightPositions;
		private float[] 			_LightScales;
		private float3[] 			_LightColors;
		private float[] 			_LightPowers;
		private float 				OverallPower = 0f;

		public VisualLightsFast()
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


		private void refreshLightState()
		{
			var l = Lights.Count;

			_LightPositions = new float3[l];
			_LightScales = new float[l];
			_LightColors = new float3[l];
			_LightPowers = new float[l];
			for(var i = 0; i < l; i++)
			{
				_LightPositions[i] = Lights[i].Position;
				_LightScales[i] = Lights[i].Scale;
				_LightColors[i] = Lights[i].Color;
				_LightPowers[i] = Lights[i].Power;
			}
		}
		
		public int AddLight(ObjectLight light, bool build = false)
		{
			
			Lights.Add(light);

			refreshLightState();

			LightCount++;

			if(build)
				ReBuild();

			return LightCount-1;
		}

		public int RemoveLight(int id)
		{
			if(LightCount > 0)
			{
				Lights.RemoveAt(id);
				
				LightCount--;

				ReBuild();

				refreshLightState();
			}
			return LightCount;
		}
		
		public void MoveLight(float3 newPosition, int id)
		{
			Lights[id].Position = newPosition;
		}

		public void SetPower(float newPower, int id)
		{
			Lights[id].Power = newPower;
		}

		public void SetScale(float newScale, int id)
		{
			Lights[id].Scale = newScale;
		}

		
		public void Clear()
		{
			Lights.Clear();

			refreshLightState();

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
				position = Lights[j].Position;
				scale = Lights[j].Scale;
				color = Lights[j].Color;
				power = Lights[j].Power;

				for(i = 0; i < cube.vertices.Count; i++)
				{
					v = cube.vertices[i];
					Geom.Positions.Write(v);
					Geom.Attrib0Buffer.Write(float4(position,0));
					Geom.InstanceIndices.Write((ushort)j);
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
				sca = Lights[j].Scale*.025f;
				position = Lights[j].Position;
				color = Lights[j].Color;
				power = Lights[j].Power;

				for(i = 0; i < QuadVertices.Length; i++)
				{
					v = QuadVertices[i];
					GeomParticles.Positions.Write(v*sca);
					GeomParticles.Attrib0Buffer.Write(float4(position, 0));
					GeomParticles.Normals.Write(v);
					GeomParticles.TexCoord0s.Write((v.XY + float2(1)) * .5f);
					GeomParticles.InstanceIndices.Write((ushort)j);
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
    		
			int id : req(InstanceIndex as float) (int)InstanceIndex;

			float3 LightPosition :
				req(_LightPositions as float3[])
					_LightPositions[id];

			float Radius :
				req(_LightScales as float[])
					_LightScales[id];

			float3 VertexPositionOffset : LightPosition + VertexPosition * Radius;

			WorldPosition: Vector.Transform(float4(VertexPositionOffset.XYZ, 1), World).XYZ;

			LightPosition : Vector.Transform(float4(prev, 1), World).XYZ;

			float LightRadius : Radius;

			float3 LightColor :
				req(_LightColors as float3[])
					_LightColors[id];

			float LightPower :
				req(OverallPower as float)
				req(_LightPowers as float[])
					_LightPowers[id] * OverallPower;

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

			int id : req(InstanceIndex as float) (int)InstanceIndex;
			
			float3 VertexPositionOffset :
				req(_LightPositions as float3[])
					_LightPositions[id];

			float3 Size : 
				req(OverallPower as float)
					VertexPosition * OverallPower;

			WorldPosition: Vector.Transform(float4(VertexPositionOffset.XYZ, 1), World).XYZ;

			ViewPosition: (Vector.Transform(float4(WorldPosition, 1), View) + float4(Size, 0)).XYZ;


			apply simppafi.RenderLibrary.FXDeferred;
			float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

			LinearDepth : pixel prev;

			float cut : Math.Round(((_depth - LinearDepth) + 1f) * .5f);

			float3 LightColor :
				req(_LightColors as float3[])
					_LightColors[id];

			float LightPower :
				req(OverallPower as float)
				req(_LightPowers as float[])
					_LightPowers[id] * OverallPower;

			PixelColor :
				req(ParticleTexture as texture2D)
				req(Attrib1 as float4)
					float4( sample(ParticleTexture, TexCoord).XYZ * LightColor * LightPower
						//* sample(import Texture2D("../Assets/perlin1.png"), TexCoord, Uno.Graphics.SamplerState.TrilinearWrap).XYZ
						, 1) * cut;
					
		}

		
		override public void OnUpdate()
		{
			
			if(Lights.Count > 0)
			{
				OverallPower = 1f;

				for(var i = 0; i < Lights.Count; i++)
				{
					_LightPositions[i] = Lights[i].Position;
					_LightScales[i] = Lights[i].Scale;
					_LightColors[i] = Lights[i].Color;
					_LightPowers[i] = Lights[i].Power;
				}
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
