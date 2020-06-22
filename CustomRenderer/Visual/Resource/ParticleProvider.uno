using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Drawing.Batching;

namespace simppafi
{
	public static class ParticleProvider
	{
		public static int 				ParticleSize;
		public static bool 				IsSetup = false;
		public static int 				ParticlesInBatch;
		public static int 				VerticesInBatch;
		public static int 				IndicesInBatch;

		public static float3[] 			TriVertices;
		public static float3[] 			TriVerticesFlip;
		private static ushort[] 		TriIndices = new ushort[] { 0,1,2 };

		private static int 				maxVertices	= (int)(65535);
		//private static int 				initStep = 0;
		private static int 				BatchCount;

		//private static Batch[]			Geom;

		public static void Init(int Count = 16)
		{
			BatchCount = Count;

			//Geom = new Batch[BatchCount];

			TriVertices = new [] {float3(0),float3(0),float3(0)};
			TriVerticesFlip = new [] {float3(0),float3(0),float3(0)};
			ParticleSize = TriVertices.Length;

			ParticlesInBatch = maxVertices / TriVertices.Length;
			VerticesInBatch = ParticlesInBatch * TriVertices.Length;
			IndicesInBatch = ParticlesInBatch * TriVertices.Length;
		}

		public static void Setup()
		{
			/*
			for(var i = 0; i < 8; i++)
			{
				SetupStep(initStep);

				initStep++;

				debug_log "Particle setup: "+ initStep +" / "+BatchCount;
				if(initStep == BatchCount)
				{
					var particleCount = (maxVertices/TriVertices.Length) * BatchCount;

					debug_log "Particle particle count : "+particleCount;

					IsSetup = true;

					break;
				}
			}
			*/

		}

		private static Batch SetupBatch()
		{
			var Geom = new Batch(VerticesInBatch, IndicesInBatch, false);
			
			int indexAdd = 0;
			int j, i;
			float3 v;

			var rand = new Random(1);
			var angler = (Math.PIf*2) / 3f;
			var angler2 = angler*2;
			var angler3 = angler*3;
			for(j = 0; j < ParticlesInBatch; j++)
			{
				var ada = Math.PIf*2f*rand.NextFloat();
				TriVertices[0] = 	float3(Math.Sin(angler2 + Math.PIf + ada), Math.Cos(angler2 + Math.PIf + ada), 0);
				TriVertices[1] = 	float3(Math.Sin(angler + Math.PIf + ada), Math.Cos(angler + Math.PIf + ada), 0);
				TriVertices[2] = 	float3(Math.Sin(angler3 + Math.PIf + ada), Math.Cos(angler3 + Math.PIf + ada), 0);

				TriVerticesFlip[0] =	float3(Math.Sin(angler2 + ada), Math.Cos(angler2 + ada), 0);
				TriVerticesFlip[1] =	float3(Math.Sin(angler + ada), Math.Cos(angler + ada), 0);
				TriVerticesFlip[2] =	float3(Math.Sin(angler3 + ada), Math.Cos(angler3 + ada), 0);
				
				for(i = 0; i < TriVertices.Length; i++)
				{
					v = TriVertices[i];
					Geom.Attrib2Buffer.Write(float4(TriVertices[i],0));
					Geom.Attrib3Buffer.Write(float4(TriVerticesFlip[i],0));

					Geom.TexCoord0s.Write((v.XY + 1f) * .5f);
					Geom.Normals.Write(v);

				}
				for(i = 0; i < TriIndices.Length; i++)
				{
					Geom.Indices.Write((ushort)(TriIndices[i]+indexAdd));
				}
				indexAdd += TriVertices.Length;

			}

			return Geom;
			
		}

		public static Batch[] GetParticles(int count)
		{
			//for(var i = 0; i < count; i++)
			//{
			//	SetupStep(initStep);
			//	initStep++;
			//}

			var res = new Batch[count];
			for(var i = 0; i < count; i++)
			{
				res[i] = SetupBatch();//Geom[i];
			}
			return res;
		}

	}
}
