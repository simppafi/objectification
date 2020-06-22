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
	public class VisualLightPillars : simppafi.BaseVisual
	{
		private Batch				Geom;
		private Random 				rand = new Random(1);
		private float4[] 			path;

		public VisualLightPillars()
		{
			CastShadow = false;
			AddShadow = false;//false;
			UVCoordID = 1;
			ReflectionCoordID = 0;
		}

		override public void Settings() {}

		override public void Setup()
		{
			base.Setup();
		}

		private List<ObjectLight> Lights = new List<ObjectLight>();
		
		public void AddLight(ObjectLight Light)
		{
			Lights.Add(Light);
			
			LightSourcePosition = new float3[Lights.Count];
			LightPowers = new float[Lights.Count];
			RotQu = new float4[Lights.Count];
			LightColor = new float3[Lights.Count];

		}

		public void ReBuild()
		{
			float div;
			float3 v, center, av;
			int i, j, indexAdd = 0;
			
			int parallels = 12;
			
			if(path == null)
			{
				path = new float4[3];// {float4(0,0,0,0f), float4(0,150f,0,46f), float4(0,300f,0,92f)};
				for(i = 0; i < path.Length; i++)
				{
					div = (float)i/(float)path.Length;
					//path[i] = float4(0,300f,0,64f) * div; //92f
					path[i] = float4(0,60f,0,32f) * div; //92f
				}
			}
			var tunnel = simppafi.Geometry.VerticeGenerator.CreateTunnelPath2(parallels, path);

			var tunnelCount = Lights.Count;

			var verticeCount = tunnel.vertices.Count * tunnelCount;
			var indiceCount =  tunnel.indices.Count * 3 * tunnelCount;

			Geom = new Batch(verticeCount, indiceCount, true);

			debug_log "VisualLightPillars Vertices "+verticeCount;
						
			for(j = 0; j < tunnelCount; j++)
			{
				center = float3(0, 0, 0);
				
				var newVertexPositions = new List<float3>();
				var uvs = new float2[verticeCount];

				for(i = 0; i < tunnel.vertices.Count; i++)
				{
					div = (float)i/(float)tunnel.vertices.Count;
					v = tunnel.vertices[i];
					
					//var uv = (Vector.Normalize(v).YZ + 1f) * .5f;

					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationX(angle.X));
					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationY(angle.Y));
					//v = Uno.Vector.Transform(v, Uno.Quaternion.RotationZ(angle.Z));
					var uv = tunnel.texCoords[i];// uvFromSphere(v);
					
					Geom.Positions.Write(v);
					newVertexPositions.Add(v);
					
					Geom.Attrib0Buffer.Write(float4(float3(1f-uv.Y), 0));

					Geom.InstanceIndices.Write((ushort)j);

					Geom.TexCoord0s.Write(uv);
					uvs[i] = uv;
				}

				indexAdd = simppafi.Utils.BatchHelper.WriteIndicesNormalsTangents(Geom, tunnel, newVertexPositions, uvs, indiceCount, indexAdd);

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

		override public void OnOff() {}



		block Shader
		{
			apply DefaultShading;
			DrawContext : req(_dc as Fuse.DrawContext) _dc;
			apply simppafi.SimppafiShading;
    		
			CullFace : Uno.Graphics.PolygonFace.None;
			WriteDepth: false;
		    DepthTestEnabled: false;
			apply simppafi.RenderLibrary.BlendAdd;


			//Scaling : float3(50f, 50f, 50f);

			//float time :
			///	req(Attrib0 as float4)
			//		(float)Uno.Application.Current.FrameTime + Attrib0.W * Math.PIf*2f;

			//float Move : Math.Max(0, Math.Sin(time));

			/*float4 rot : Uno.Quaternion.RotationAxis(float3(1f,.1f,.05f), (float)Time*.2f);

			VertexPosition : 
				Uno.Vector.Transform(prev, rot);

			VertexPosition :
				req(Attrib0 as float4)
					prev + Attrib0.XYZ;

			Normal : Uno.Vector.Transform(prev, rot);

			VertexBinormal : Uno.Vector.Transform(prev, rot);
			*/

			VertexPosition : 
				req(LightSourcePosition as float3[])
				req(RotQu as float4[])
				req(InstanceIndex as float)
					Uno.Vector.Transform(prev, RotQu[(int)InstanceIndex]) + LightSourcePosition[(int)InstanceIndex];

			//Transform : 
			//VertexPosition : Uno.Vector.Transform(prev, Uno.Quaternion.RotationAlignForward(float3(0), float3(0,1,0)));

			//VertexPosition :
			//	prev * 1f + Math.Sin(time + prev.Y*10f) * .02f +
			//				float3(0, Math.Sin(time*2f + prev.Z*10f) * .05f,0);

			//Rotation : Quaternion.RotationY((float)Time*.3f);

			//PixelColor : float4(prev.XYZ * .2f, prev.W);

			float LightPower :
				req(LightPowers as float[])
				req(InstanceIndex as float)
					LightPowers[(int)InstanceIndex];

			PixelColor : 
				req(Attrib0 as float4)
				req(LightColor as float3[])
				req(InstanceIndex as float)
					float4(Attrib0.XYZ * LightColor[(int)InstanceIndex] * //.75f *
						sample(import Texture2D("../Assets/perlin1.png"), TexCoord, Uno.Graphics.SamplerState.TrilinearWrap).XYZ
						* LightPower
					,1); // * .05f

		}

		private float CurrentTime = 0f;
		private float3[] LightSourcePosition;
		private float4[] RotQu;
		private float3[] LightColor;
		private float[] LightPowers;

		override public void OnUpdate()
		{
			CurrentTime = (float)Fuse.Time.FrameTime;
			if(Lights.Count > 0)
			{
				for(var i = 0; i < Lights.Count; i++)
				{
					LightPowers[i] = Lights[i].Power;
					LightSourcePosition[i] = Lights[i].Position;
					RotQu[i] = LookAt(LightSourcePosition[i], Lights[i].Target);
					LightColor[i] = Lights[i].Color;
				}
			}
		}

		protected override void OnDraw(DrawContext dc)
    	{
    		draw this, Geom, Shader, virtual simppafi.RenderPipeline.PassFront;
		}




		public float4 LookAt(float3 sourcePoint, float3 destPoint)
		{
		    float3 forwardVector = Vector.Normalize(destPoint - sourcePoint);

		    float dot = Vector.Dot(float3(0,1,0), forwardVector);

		    if (Math.Abs(dot - (-1.0f)) < 0.000001f)
		    {
		        return float4(0, 1, 0, 3.1415926535897932f);
		    }
		    if (Math.Abs(dot - (1.0f)) < 0.000001f)
		    {
		        return float4(0.0f, 0.0f, 0.0f, 1.0f);
		    }

		    float rotAngle = (float)Math.Acos(dot);
		    float3 rotAxis = Vector.Cross(float3(0,1,0), forwardVector);
		    rotAxis = Vector.Normalize(rotAxis);
		    return CreateFromAxisAngle(rotAxis, rotAngle);
		}

		// just in case you need that function also
		public float4 CreateFromAxisAngle(float3 axis, float angle)
		{
		    float halfAngle = angle * .5f;
		    float s = (float)Math.Sin(halfAngle);
		    float4 q;
		    q.X = axis.X * s;
		    q.Y = axis.Y * s;
		    q.Z = axis.Z * s;
		    q.W = (float)Math.Cos(halfAngle);
		    return q;
		}

	}
}
