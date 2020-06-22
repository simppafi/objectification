using Uno;
using Fuse.Drawing.Primitives;
using Fuse;
using Uno.Vector;
using Uno.Math;

namespace simppafi
{
	public class ModifieFXAA : BaseModifie
	{
		//public bool EnableFXAA = true;
		//public bool EnablePrevFrame = false;

		//public static framebuffer PrevFrame = new framebuffer(int2(8,8), Uno.Graphics.Format.RGBA8888, Uno.Graphics.FramebufferFlags.None);
		//private int2 PrevFrameSize = int2(8);

		public ModifieFXAA()
		{
			
		}

		public override void Process(Fuse.DrawContext dc, framebuffer source)
		{

			//BLUR SHADOW
			//sample(simppafi.FramebufferStorage.GlobalShadowBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).X
			//blurX(dc, simppafi.FramebufferStorage.GlobalShadowBuffer, 1, 1f);


			// LIGHTS
			var TRANS = Fuse.FramebufferPool.Lock(simppafi.FramebufferStorage.GlobalTransparencyBuffer.Size, simppafi.FramebufferStorage.GlobalTransparencyBuffer.Format, false);
			if(simppafi.FramebufferStorage.RenderTransparency)
			{
				dc.PushRenderTarget(TRANS);
				dc.Clear(float4(0,0,0,0), 1);
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
					PixelColor : sample(simppafi.FramebufferStorage.GlobalTransparencyBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				};
				dc.PopRenderTarget();

				blur(dc, TRANS, 1, 1.5f);

			}

			
			// DEPTH COLOR AND SUCH
			//var SRC = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			// draw color to source
			/*dc.PushRenderTarget(SRC);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

				PixelColor : float4(prev.XYZ - (1f-sample(simppafi.FramebufferStorage.GlobalShadowBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).X) * .5f, prev.W);

			};
			dc.PopRenderTarget();*/
			
			//var SRC = source;

			// FXAA
			//var FXAA = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			
			//dc.PushRenderTarget(FXAA);
			//dc.Clear(float4(0,0,0,0), 1);
			///*
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				
				float2 inverseVP : float2(1.0f / source.Size.X, 1.0f / source.Size.Y);
				float2 v_rgbNW : uv + (float2(-1.0f, -1.0f) * inverseVP);
				float2 v_rgbNE : uv + (float2(1.0f, -1.0f) * inverseVP);
				float2 v_rgbSW : uv + (float2(-1.0f, 1.0f) * inverseVP);
				float2 v_rgbSE : uv + (float2(1.0f, 1.0f) * inverseVP);
				float2 v_rgbM : uv;

				float FXAA_REDUCE_MIN : 1.0f / 128.0f;
				float FXAA_REDUCE_MUL : 1.0f / 8.0f;
				float FXAA_SPAN_MAX : 8.0f;

				float3 rgbNW : sample(source.ColorBuffer, v_rgbNW, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			    float3 rgbNE : sample(source.ColorBuffer, v_rgbNE, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			    float3 rgbSW : sample(source.ColorBuffer, v_rgbSW, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			    float3 rgbSE : sample(source.ColorBuffer, v_rgbSE, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			    float4 texColor : sample(source.ColorBuffer, v_rgbM, Uno.Graphics.SamplerState.LinearWrap);
			    float3 rgbM : texColor.XYZ;
			    float3 luma : float3(0.299f, 0.587f, 0.114f);

			    float lumaNW : Vector.Dot(rgbNW, luma);
			    float lumaNE : Vector.Dot(rgbNE, luma);
			    float lumaSW : Vector.Dot(rgbSW, luma);
			    float lumaSE : Vector.Dot(rgbSE, luma);
			    float lumaM  : Vector.Dot(rgbM,  luma);
			    float lumaMin : Math.Min(lumaM, Math.Min(Math.Min(lumaNW, lumaNE), Math.Min(lumaSW, lumaSE)));
			    float lumaMax : Math.Max(lumaM, Math.Max(Math.Max(lumaNW, lumaNE), Math.Max(lumaSW, lumaSE)));
			    
			    float2 dir : float2(
			    					-((lumaNW + lumaNE) - (lumaSW + lumaSE)),
			    					((lumaNW + lumaSW) - (lumaNE + lumaSE)) 
			    					);
			    
			    float dirReduce : Math.Max((lumaNW + lumaNE + lumaSW + lumaSE) *
			                          (0.25f * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
			    
			    float rcpDirMin : 1.0f / (Math.Min(Math.Abs(dir.X), Math.Abs(dir.Y)) + dirReduce);

			    float2 dir2 : 	Math.Min(float2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
			              		Math.Max(float2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
			              		dir * rcpDirMin)) * inverseVP;
			    
			    float3 rgbA : 0.5f * (
			        sample(source.ColorBuffer, uv  + dir2 * (1.0f / 3.0f - 0.5f), Uno.Graphics.SamplerState.LinearWrap).XYZ +
			        sample(source.ColorBuffer, uv + dir2 * (2.0f / 3.0f - 0.5f), Uno.Graphics.SamplerState.LinearWrap).XYZ);
			    float3 rgbB : rgbA * 0.5f + 0.25f * (
			        sample(source.ColorBuffer, uv  + dir2 * -0.5f, Uno.Graphics.SamplerState.LinearWrap).XYZ +
			        sample(source.ColorBuffer, uv  + dir2 * 0.5f, Uno.Graphics.SamplerState.LinearWrap).XYZ);

			    float lumaB : Vector.Dot(rgbB, luma);
				
				PixelColor : ((lumaB < lumaMin) || (lumaB > lumaMax)) ? float4(rgbA, texColor.W) : float4(rgbB, texColor.W);
				//PixelColor : texColor;

				//PixelColor : float4(prev.XYZ - (1f-sample(simppafi.FramebufferStorage.GlobalShadowBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).X) * .5f, prev.W);

				//apply simppafi.RenderLibrary.FXDeferred;
				//float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

				//float4 _trans : sample(TRANS.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				//float LinearDepth : pixel prev;

				//float cut : Math.Round(((_depth - _trans.X) + 1f) * .5f);

				PixelColor : prev + sample(TRANS.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

				float4 ssao : sample(simppafi.FramebufferStorage.GlobalSSAOBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

				PixelColor : float4(prev.XYZ * ssao.XYZ, 1f);
				//PixelColor : sample(TRANS.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);//float4(sample(TRANS.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).XXX, 1f);
				
			};
			//dc.PopRenderTarget();
			//*/
/*
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

				float4 trans : sample(TRANS.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

				//float4 noise : sample(import Uno.Graphics.Texture2D("../../Assets/white_normal.png"), uv, Uno.Graphics.SamplerState.LinearWrap);

				PixelColor : sample(FXAA.ColorBuffer, uv + float2(trans.X + trans.Y, trans.Y + trans.Z)*.2f, Uno.Graphics.SamplerState.LinearWrap) + trans;
				
			};
*/

			//hexacons(dc, 0.2f, SRC);

			/*
			var BOKEH = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			dc.PushRenderTarget(BOKEH);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(SRC.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();
			
			//int rounds = 8;
			//BokehBlur(dc, BOKEH, rounds);
			hexacons(dc, 0.03f, BOKEH);

			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				float4 sharp : sample(SRC.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				float4 blur : sample(BOKEH.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

				float curv : Math.Min(1f, Math.Abs(-1.5f + pixel uv.Y * 3f));
				//float curv : Math.Abs(-1f + pixel uv.Y * 2f);
				PixelColor : sharp * (1f-curv) + blur * (curv);
			};
			*/

			/*
			draw Quad//{texture2D LensTexture : LensTextures[LensTextureID];}, Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

				PixelColor :  sample(FXAA.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				
			};
			
			Fuse.FramebufferPool.Release(FXAA);
			*/

			//Fuse.FramebufferPool.Release(SRC);
			//Fuse.FramebufferPool.Release(BOKEH);

			//Fuse.FramebufferPool.Release(FXAA);
			Fuse.FramebufferPool.Release(TRANS);
			
		}

		public int size = 1;
		public float Stretch = 2f;

		private block AngleBlur
		{
			DepthTestEnabled: false;
			CullFace: Uno.Graphics.PolygonFace.None;
			float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

			float4 AngleBlur :
			req(angle as float2)
			req(src as framebuffer)
			req(rounds as int)
			{
				float3 so = float3(0);
				for(var i = 0; i < rounds; i++)
				{
					so += sample(src.ColorBuffer, uv + angle * i, Uno.Graphics.SamplerState.LinearWrap).XYZ * (1f+(float)i/(float)rounds);
				}
				return float4(so/rounds,1);
			};
		}


		//private void BokehBlur(Fuse.DrawContext dc, framebuffer source, framebuffer target, framebuffer blurTarget, int rounds)
		private void BokehBlur(Fuse.DrawContext dc, framebuffer source, int rounds)
		{
			
			var deg = (2f*Math.PIf)/3f;
			
			var offset = Fuse.FramebufferPool.Lock(source.Size/size, source.Format, false);
			var rhombi1 = Fuse.FramebufferPool.Lock(source.Size/size, source.Format, false);
			var rhombi2 = Fuse.FramebufferPool.Lock(source.Size/size, source.Format, false);
			var rhombi3 = Fuse.FramebufferPool.Lock(source.Size/size, source.Format, false);
			
			var RES = float2((1.0f/source.Size.X), (1.0f/source.Size.Y)) * Stretch;


			//UP
			dc.PushRenderTarget(offset);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				int rounds : local::rounds;
				float2 angle : float2(0, 1f) * RES;
				framebuffer src : source;
				apply AngleBlur;
				PixelColor : AngleBlur;
			};
			dc.PopRenderTarget();

			//UP + DOWN_RIGHT
			dc.PushRenderTarget(rhombi1);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				int rounds : local::rounds;
				float2 angle : float2(Math.Sin(deg), Math.Cos(deg)) * RES;
				framebuffer src : offset;
				apply AngleBlur;
				PixelColor : AngleBlur;
			};
			dc.PopRenderTarget();

			// UP+DOWN_LEFT
			dc.PushRenderTarget(rhombi2);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				int rounds : local::rounds;
				float2 angle : float2(Math.Sin(deg*2), Math.Cos(deg*2)) * RES;
				framebuffer src : offset;
				apply AngleBlur;
				PixelColor : AngleBlur;
			};
			dc.PopRenderTarget();

			// DOWN_LEFT
			dc.PushRenderTarget(offset);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				int rounds : local::rounds;
				float2 angle : float2(Math.Sin(deg*2), Math.Cos(deg*2)) * RES;
				framebuffer src : source;
				apply AngleBlur;
				PixelColor : AngleBlur;
			};
			dc.PopRenderTarget();

			//DOWN_LEFT+DOWN_RIGHT
			dc.PushRenderTarget(source);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				int rounds : local::rounds;
				float2 angle : float2(Math.Sin(deg), Math.Cos(deg)) * RES;
				framebuffer src : offset;
				apply AngleBlur;
				PixelColor : float4((AngleBlur.XYZ + sample(rhombi1.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).XYZ + sample(rhombi2.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).XYZ ) / 2f, 1);
			};
			dc.PopRenderTarget();
			
			Fuse.FramebufferPool.Release(rhombi1);
			Fuse.FramebufferPool.Release(rhombi2);
			Fuse.FramebufferPool.Release(rhombi3);
			Fuse.FramebufferPool.Release(offset);

		}



		const float sqrt3 = 1.7320508076f;
		const float halfSqrt3 = 0.866025404f;
		private void hexacons(DrawContext dc, float size, framebuffer source)
		{
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);
			dc.PushRenderTarget(offset);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();

			float2 center = float2(0.5f,0.5f);

			dc.PushRenderTarget(source);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{

				//apply simppafi.RenderLibrary.FXDeferred;
				//float Depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);
				//Depth : prev * 2f;


				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

				//float curv : Vector.Length(pixel uv - float2(.5f,.5f)) * 2f;//Math.Abs(-1f + pixel uv.Y * 2f);

				float _size : size;// * curv;

				float2 grid : pixel float2(_size,sqrt3*_size);
				float2 po1 : Math.Floor((uv-center)/grid+0.5f);
				po1 : prev*grid +center - uv;
				float dst1 : po1.X*po1.X + po1.Y*po1.Y;
				float2 center2 : center+_size*float2(0.5f,halfSqrt3);
				float2 po2 : Math.Floor((uv-center2)/grid+0.5f);
				po2 : prev*grid +center2 -uv;
				float dst2 : po2.X*po2.X + po2.Y*po2.Y;
				float2 px : (dst1<dst2) ? po1 : po2;

				PixelColor : sample(offset.ColorBuffer, uv+px, Uno.Graphics.SamplerState.LinearWrap);// * Depth;

			};
			dc.PopRenderTarget();

			Fuse.FramebufferPool.Release(offset);
		}

		private void blurX(DrawContext dc, framebuffer source, int Steps = 1, float stretch = 1f)
		{
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			// GAUSSIAN DOF
			var offsetX = float2(1f/(float)source.Size.X, 0) * stretch;
			var offsetY = float2(0, 1f/(float)source.Size.Y) * stretch;
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(offset);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float sum : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).X * 0.204164f;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap).X * 0.304005f;
					sum : prev + sample(source.ColorBuffer, uv - offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap).X * 0.304005f;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).X * 0.093913f;
					PixelColor : float4(sum + sample(source.ColorBuffer, uv - offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).X * 0.093913f, 0,0,0);
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float sum : sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).X * 0.204164f;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap).X * 0.304005f;
					sum : prev + sample(offset.ColorBuffer, uv - offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap).X * 0.304005f;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).X * 0.093913f;
					PixelColor : float4(sum + sample(offset.ColorBuffer, uv - offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).X * 0.093913f, 0,0,0);
				};
				dc.PopRenderTarget();

			}

			Fuse.FramebufferPool.Release(offset);
		}


		private void blur(DrawContext dc, framebuffer source, int Steps = 1, float stretch = 1f)
		{
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			// GAUSSIAN DOF
			var offsetX = float2(1f/(float)source.Size.X, 0) * stretch;
			var offsetY = float2(0, 1f/(float)source.Size.Y) * stretch;
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(offset);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 sum : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) * 0.204164f;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
					sum : prev + sample(source.ColorBuffer, uv - offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;
					PixelColor : sum + sample(source.ColorBuffer, uv - offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).X * 0.093913f;
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 sum : sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) * 0.204164f;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
					sum : prev + sample(offset.ColorBuffer, uv - offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;
					PixelColor : sum + sample(offset.ColorBuffer, uv - offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;
				};
				dc.PopRenderTarget();

			}

			Fuse.FramebufferPool.Release(offset);
		}

	}
}
