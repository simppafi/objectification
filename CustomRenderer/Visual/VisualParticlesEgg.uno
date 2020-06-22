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
using OpenGL;

namespace simppafi
{
	public class VisualParticlesEgg : simppafi.BaseVisual
	{
		private Batch[]				Geom;

		private int BatchCount		 = 2;//2;//12;//16;

		private int					ParticleCount;
		private int 				ModelTriangleID;

		private texture2D			ParticleTexture = import Texture2D("../Assets/particle.png");

		private Random 				rand = new Random(1);
		private float 				GoldenRatio = Math.PIf * (3f - Math.Sqrt(5f));

		private float3[] 			QuadVertices = new [] {float3(0,0,0),float3(1,0,0),float3(1,1,0),float3(0,1,0)};
		private ushort[] 			QuadIndices = new ushort[] { 0,1,2,2,3,0 };
		
		private int 				maxVertices	= (int)(65535);

		public int noiseMode = 0;
		public bool shock = true;

		private int initStep = 0;

		public VisualParticlesEgg()
		{
			CastShadow = true;
			
		}

		override public void Settings() {}

		override public void OnOff() {
			//initStep = 0;
			//isSetup = false;
		}

		override public void Setup()
		{
			if(Geom == null)
			{
				Geom = simppafi.ParticleProvider.GetParticles(BatchCount);
			}

			// PARTICLE
			for(var i = 0; i < 8; i++)
			{
				ModelTriangleID = 0;

				SetupStep(initStep);

				initStep++;

				debug_log "VisualParticlesEgg "+initStep +" "+BatchCount;
				if(initStep == BatchCount)
				{
					ParticleCount = simppafi.ParticleProvider.ParticlesInBatch * BatchCount;

					debug_log "VisualParticlesEgg particle particle count : "+ParticleCount;

					base.Setup();

					break;
				}
			}
		}

		private void SetupStep(int step)
		{
			
			float3 v;
			int i,j;
			
			Geom[step].Attrib0Buffer.Position = 0;
			Geom[step].Attrib1Buffer.Position = 0;
			Geom[step].TexCoord0s.Position = 0;
			Geom[step].Normals.Position = 0;

			var angler = (Math.PIf*2) / 3f;
			var angler2 = angler*2;
			var angler3 = angler*3;
			for(j = 0; j < simppafi.ParticleProvider.ParticlesInBatch; j++)
			{
				
				//var center = egg(PositionOnSphereSurface(rand.NextFloat(), rand.NextFloat()));
				var center = PositionOnSphereSurface(rand.NextFloat(), rand.NextFloat());
				
				var spherePos = uvFromSphere(center);

				var _x = (int)(spherePos.X * TexturePixelProvider.ImageSizes[0].X);
				var _y = (int)(spherePos.Y * TexturePixelProvider.ImageSizes[0].Y);

				var BPP = 4;
				var stride = TexturePixelProvider.ImageSizes[0].X * 4;
				var ImageBytePos = _x * BPP + _y * stride;

				float val;
				float3 gotoPos;

				//if(rand.NextFloat() > .5f)
				//{
				//	val = (float)TexturePixelProvider.ImageBytes[1][ImageBytePos] / (float)255f;
				//	gotoPos = center * (1f + val*val*val*4f) * float3(1.5f,1,1.5f);

				//}else{
					val = (float)TexturePixelProvider.ImageBytes[0][ImageBytePos] / (float)255f;
					var val2 = (float)TexturePixelProvider.ImageBytes[2][ImageBytePos] / (float)255f;
					gotoPos = center * (4f + val*val*val*3f) + float3(0,val2*2f,0) + float3(0,1f,0);
					//gotoPos = center * (1f + float3(val,val*.1f,val)) + float3(0,-50-val2*200f,0);
					//gotoPos = center * (1f + val);//*val*val*.1f);
					//var spu = uvFromSphere(center);
					//gotoPos = PositionOnSphereSurface(spu.X,spu.Y) * 100f * (1f + val);//Vector.Normalize(center) * 10f;
				//}

				//gotoPos *= .6f + rand.NextFloat() * .4f;

				//gotoPos = center;

				//var timeStep = Vector.Normalize(center).Z * .05f;
				
				var time = (center.Y + 1f) * .5f;

				for(i = 0; i < simppafi.ParticleProvider.TriVertices.Length; i++)
				{
					v = simppafi.ParticleProvider.TriVertices[i];
					//Geom[step].Positions.Write(v);

					Geom[step].Attrib0Buffer.Write(float4(center * 10f + float3(0,10f,0), time * .05f));//timeStep));
					Geom[step].Attrib1Buffer.Write(float4(center * 10f + float3(0,10f,0), 0));//1-timeStep));

					//Geom[step].Attrib2Buffer.Write(float4(TriVertices[i],0));
					//Geom[step].Attrib3Buffer.Write(float4(TriVerticesFlip[i],0));

					Geom[step].TexCoord0s.Write(uvFromSphere(center+v));//*2f);//(float2(v.X, v.Y) + 1f) * .5f);
					Geom[step].Normals.Write(Vector.Normalize(center));

				}
				
			}

			Geom[step].Attrib0Buffer.Invalidate();
			Geom[step].Attrib1Buffer.Invalidate();
			Geom[step].TexCoord0s.Invalidate();
			Geom[step].Normals.Invalidate();
			
		}

		private float3 egg(float3 v)
		{
			var bo = .6f + (1f - (v.Y + 1f) * .5f) * .3f;
			return v * float3(bo, 1f, bo);
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


		block Shader
		{
			apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

    		
			CullFace: Uno.Graphics.PolygonFace.Back;
			
			/*
			float time :
				req(Attrib0 as float4)
				req(CurrentTime as float)
					(CurrentTime);//-Attrib0.W);// * Attrib1.W;

			float Move : time;
				//req(Attrib1 as float4)
				//	Math.Min(time*Attrib1.W, 1f);

			//float ease : 0.5f + Math.Sin(Move) * .5f;//Move - Math.Floor(Move);
			//float loop : Move - Math.Floor(Move);

			float ease : Move - Math.Floor(Move);
			//ease : Math.Max(-2f + prev * 5f, 0);
			//ease : Math.Clamp(-2f + prev * 5f, 0, 1);
			//ease : Math.Clamp(prev, 0, 1);

			float loopEase : ease;
			//float loopEase : ease * ease;
			//float loopEase : -Uno.Math.Pow( 2.0f, -10.0f * ease ) + 1.0f;
			//float loopEase : Uno.Math.Pow(2.0f, (10.0f * (ease*.25f - 1.0f))) - 0.001f;
			
			//float ease : Math.Max(0, -2f+Math.Sin(Move*Math.PIf)*3f);
			
			//float Y : Math.Sin(loopEase*Math.PIf);
			
			//float3 ease : float3(loopEase, Y, loopEase);
			*/
			
			float time : 
				req(Attrib0 as float4)
				req(CurrentTime as float)
					CurrentTime * .05f + Attrib0.W;

			float mv : time;// - Math.Floor(time);

			//float ease : mv*mv;
			//float Move : Math.Clamp(-.25f + ease*1.25f, 0, 1);


			//float ease : Math.Max(0, -.05f+mv*1.0f);//Math.Clamp(-.5f + mv*1.5f, 0, 1);
			//float Move : -Uno.Math.Pow( 2.0f, -10.0f * ease ) + 1.0f;
			float Move : 0.5f + Math.Sin(mv) * .5f;


			float3 VertexPosition :
				req(Attrib2 as float4)
				req(Attrib3 as float4)
				req(Flip as float)
					Attrib2.XYZ + (Attrib3.XYZ - Attrib2.XYZ) * Flip;

			/*float3 VertexPositionOffset :
				req(Attrib0 as float4) // moveFrom
				req(Attrib1 as float4) // moveTo
					Attrib0.XYZ + (Attrib1.XYZ - Attrib0.XYZ) * loopEase;
			*/

			float3 VertexPositionOffset :
				req(Attrib0 as float4) // moveFrom
				req(Attrib1 as float4) // moveTo
					Attrib0.XYZ + (Attrib1.XYZ - Attrib0.XYZ) * Move;

			//VertexPositionOffset : float3(prev.X, Math.Clamp(prev.Y, 0, 180), prev.Z);
			
			//VertexPositionOffset : float3(Math.Clamp(prev.X, -100, 100), Math.Clamp(prev.Y, -300, 100), Math.Clamp(prev.Z, -100, 100));

			//VertexPositionOffset : prev;// + float3(0,-ease*100f,0);

			///*
			float3 newPos : Vector.Transform(float4(VertexPositionOffset, 1), World).XYZ;
			float depth : 
					Math.Sqrt( Vector.Length( newPos-CameraPosition) );

			float3 TargetScale : float3(depth*.02f);// - (Math.Clamp(ease-2f, 0, 1));

			//float3 TargetScale : float3(1f);// - (Math.Clamp(ease-2f, 0, 1));

			float3 Size : 
				req(TargetScale as float3)
					VertexPosition*TargetScale;

			float3 TargetPosition : CameraPosition;

			Size : Vector.Transform(prev, Quaternion.RotationAlignForward(-TargetPosition, float3(0,1,0))).XYZ;
			//*/

			//float3 Size : VertexPosition;
			//float3 TargetPosition : CameraPosition;
			//Size : Vector.Transform(prev, Quaternion.RotationAlignForward(-TargetPosition, float3(0,1,0))).XYZ;

			WorldPosition: Vector.Transform(float4(VertexPositionOffset + Size, 1), World).XYZ;



		}

		block Fragment
		{
			
			float3 albedo : float3(1f);
			float metallic : 1f;
			float roughness : 0f;
			float ao : 1f;

			PixelColor : float4(albedo,1);

		}

		
		private float Flip = 0f;

		private float CurrentTime = 0f;

		override public void OnUpdate()
		{
			Flip = (Flip==1f) ? 0f : 1f;
			CurrentTime += (float)Fuse.Time.FrameInterval;
		}

		protected override void OnDraw(DrawContext dc)
    	{	
    		for(var i = 0; i < BatchCount; i++)
    		{
    			draw this, Geom[i], Shader, simppafi.ShaderMaterial.Plastic, virtual simppafi.RenderPipeline.PassFront;
    		}
			
		}
		
	}
}
