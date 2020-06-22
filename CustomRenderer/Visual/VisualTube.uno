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
	public class VisualTube : simppafi.BaseVisual
	{
		private Batch				Geom;
		private Random 				rand = new Random(1);

		public VisualTube()
		{
			CastShadow = true;
			AddShadow = true;//false;
			UVCoordID = 1;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{
			int i, j, indexAdd = 0;
			float div;

			var path = new float4[256];
			var rx = 0f;
			var rz = 0f;
			var ry = 0f;
			var wi = 0f;
			for(i = 0; i < path.Length; i++)
			{
				div = (float)i/(float)path.Length;

				if(i < 1 || i > path.Length-2)
				{
					wi = 0f;
				}else{
					wi = 4f;
				}


				if(div > .25f && div < .75f)
				{
					rx += .25f;
				}else{
					ry += .25f;//-40f + div*80f;
				}
				
				path[i] = float4(
									rx,//20 * Math.Sin(div * Math.PIf*4f),
									ry,
									rz,//20 * Math.Cos(div * Math.PIf*4f),
									wi//4 * (Math.Sin(div*Math.PIf)) 

									);
			}

			var obj = simppafi.Geometry.VerticeGenerator.CreateTunnelPath2(12, path);

			var objCount = 1;

			var verticeCount = obj.vertices.Count * objCount;
			var indiceCount =  obj.indices.Count * 3 * objCount;

			Geom = new Batch(verticeCount, indiceCount, true);

			debug_log "VisualTube Vertices "+verticeCount;

			float3 v, center, av;
			
			
			var gr = (1f + Math.Sqrt(5f)) / 2.0f; //golden ratio
			var scale = 12f;
			var size = gr * scale;
			for(j = 0; j < objCount; j++)
			{
				center = float3(0, -15, 0);

				var newVertexPositions = new List<float3>();
				var uvs = new float2[verticeCount];

				for(i = 0; i < obj.vertices.Count; i++)
				{
					v = obj.vertices[i] + center;
					
					//var uv = (Vector.Normalize(v).YZ + 1f) * .5f;

					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(angle.X));
					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationY(angle.Y));
					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationZ(angle.Z));
					//var uv = uvFromSphere(v);
					
					var uv = obj.texCoords[i];

					Geom.Positions.Write(v);
					newVertexPositions.Add(v);
					
					//Geom.Attrib0Buffer.Write(float4(center, 0));

					Geom.TexCoord0s.Write(uv);
					uvs[i] = uv;
				}

				indexAdd = simppafi.Utils.BatchHelper.WriteIndicesNormalsTangents(Geom, obj, newVertexPositions, uvs, indiceCount, indexAdd);

			}


			base.Setup();
		}

		private float2 uvFromSphere(float3 v)
		{
			var va = Vector.Normalize(v);
			return float2(
				.5f + Math.Atan2(va.Z, va.X) / (Math.PIf*2f),
				.5f - Math.Asin(va.Y) / Math.PIf
			);
		}

		override public void OnOff() {}



		block Shader
		{
			apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;

		}


		override public void OnUpdate()
		{

		}

		protected override void OnDraw(DrawContext dc)
    	{
    		draw this, Geom, Shader, virtual simppafi.RenderPipeline.PassFront;
		}

	}
}
