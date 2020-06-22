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
	public class VisualDodeca : simppafi.BaseVisual
	{
		private Batch				Geom;
		private Random 				rand = new Random(1);

		public VisualDodeca()
		{
			CastShadow = true;
			AddShadow = true;//false;
			UVCoordID = 3;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{


			var cube = simppafi.Geometry.VerticeGenerator.CreateIcoSphere(4);//.CreateCubeSphere(16);//CreateDodecahedron();//CreateCubeSphere(16); //.CreateDodecahedron();

			var cubeCount = 1;

			var verticeCount = cube.vertices.Count * cubeCount;
			var indiceCount =  cube.indices.Count * 3 * cubeCount;

			Geom = new Batch(verticeCount, indiceCount, true);

			debug_log "VisualDodeca Vertices "+verticeCount;

			float3 v, center, av;
			int i, j, indexAdd = 0;
			float div;

			
			var gr = (1f + Math.Sqrt(5f)) / 2.0f; //golden ratio
			var scale = 10f;
			var size = gr * scale;
			for(j = 0; j < cubeCount; j++)
			{
				center = float3(0, 10f, 0);

				//var angle = rand.NextFloat3() * Math.PIf*2f;

				//var spike = 2f;//1f + 5f * rand.NextFloat();


				var newVertexPositions = new List<float3>();
				var uvs = new float2[verticeCount];

				for(i = 0; i < cube.vertices.Count; i++)
				{
					v = cube.vertices[i];
					
					/*v = float3(
						Math.Clamp(v.X, -.75f, .75f),
						Math.Clamp(v.Y, -.75f, .75f),
						Math.Clamp(v.Z, -.75f, .75f)
						);*/
					//var uv = (Vector.Normalize(v).YZ + 1f) * .5f;

					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(angle.X));
					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationY(angle.Y));
					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationZ(angle.Z));
					var uv = uvFromSphere(v);
					//var uv = cube.texCoords[i];
					
					/*if(i < 20)
					{
						av = v * scale*.45f;
						Geom.Positions.Write(av);
						newVertexPositions.Add(av);
					}else{
					*/	
						av = v * scale + center;
						Geom.Positions.Write(av);// * spike);
						newVertexPositions.Add(av);
					//}

					

					Geom.Attrib0Buffer.Write(float4(center, 0));

					Geom.TexCoord0s.Write(uv);
					uvs[i] = uv;
				}

				indexAdd = simppafi.Utils.BatchHelper.WriteIndicesNormalsTangents(Geom, cube, newVertexPositions, uvs, indiceCount, indexAdd);

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

			PixelColor : float4(albedo.XYZ*ao, 1f);
		}


		override public void OnUpdate()
		{

		}

		protected override void OnDraw(DrawContext dc)
    	{
    		//draw this, Geom, Shader, simppafi.ShaderMaterial.Paint, virtual simppafi.RenderPipeline.PassFront;
		}

	}
}
