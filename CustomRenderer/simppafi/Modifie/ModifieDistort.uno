using Uno;
using Fuse.Drawing.Primitives;
using Fuse;
using Uno.Vector;
using Uno.Math;

namespace simppafi
{
	public class ModifieDistort : BaseModifie
	{
		public bool endTitle = false;

		public bool EnableFXAA = true;
		public bool EnablePrevFrame = false;

		public static framebuffer PrevFrame = new framebuffer(int2(8,8), Uno.Graphics.Format.RGBA8888, Uno.Graphics.FramebufferFlags.None);
		private int2 PrevFrameSize = int2(8);

		
		public ModifieDistort()
		{
			
		}

		private Uno.Graphics.SamplerState	samplerState = Uno.Graphics.SamplerState.LinearWrap;

		/*private float DistortValue = 0f;
		public void Distort(float val)
		{
			DistortValue = val;
		}*/

		private Random rand = new Random(1);
		/*private float BlurMoveX = 0f;
		private float BlurMoveXTo = 0f;
		private float BlurMoveY = 0f;
		private float BlurMoveYTo = 0f;
		*/

		private float maxFrameTime = 0f;
		public override void Process(Fuse.DrawContext dc, framebuffer source)
		{

			// BLUR SHADOW
			//blur(dc, simppafi.FramebufferStorage.GlobalShadowBuffer, 1, 1f);
			//blur(dc, simppafi.FramebufferStorage.GlobalShadowBuffer, 2, float2(1f,1f), float2(1.0f,1.0f));

			/*
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

				//blur(dc, TRANS, 1, 1.5f);
				blur(dc, TRANS, 1, float2(1.5f,1.5f), float2(1.0f,1.0f));

			}



			var DEPTH = Fuse.FramebufferPool.Lock(source.Size/4, source.Format, false);

			dc.PushRenderTarget(DEPTH);
			dc.Clear(float4(0,0,0,0), 1);
			if(simppafi.RenderPipeline.RenderMode == simppafi.RenderPipeline.RenderingMode.FORWARD)
			{
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
					apply simppafi.RenderLibrary.GlobalDepthLinear;

					//float4 colA : float4(1,1,1,1);//simppafi.Color.ColorHexToRGB.HexToRGBA(0xbc2300, 0);
					//float4 depthColor : colA + (float4(0f) - colA) * Math.Min(1f, GlobalDepthLinear*2f);//*.5f;

					PixelColor : float4(GlobalDepthLinear);

				};
			}
			else
			{
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
					
					apply simppafi.RenderLibrary.FXDeferred;
					float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

					//float4 colA : simppafi.Color.ColorHexToRGB.HexToRGBA(0xbc2300, 0);
					//float4 depthColor : colA + (float4(0f) - colA) * Math.Min(1f, _depth*2f);

					//PixelColor : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) + depthColor * .1f;

					PixelColor : float4(_depth);

				};
			}
			dc.PopRenderTarget();
			

			// DEPTH COLOR AND SUCH
			var SRC = source;//Fuse.FramebufferPool.Lock(source.Size, source.Format, false);
	

			//var SRC = source;

			// FXAA
			var FXAA = Fuse.FramebufferPool.Lock(SRC.Size, SRC.Format, false);

			if(EnableFXAA)
			{ 
				dc.PushRenderTarget(FXAA);
				dc.Clear(float4(0,0,0,0), 1);
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
					
					float2 inverseVP : float2(1.0f / SRC.Size.X, 1.0f / SRC.Size.Y);
					float2 v_rgbNW : uv + (float2(-1.0f, -1.0f) * inverseVP);
					float2 v_rgbNE : uv + (float2(1.0f, -1.0f) * inverseVP);
					float2 v_rgbSW : uv + (float2(-1.0f, 1.0f) * inverseVP);
					float2 v_rgbSE : uv + (float2(1.0f, 1.0f) * inverseVP);
					float2 v_rgbM : uv;

					float FXAA_REDUCE_MIN : 1.0f / 128.0f;
					float FXAA_REDUCE_MUL : 1.0f / 8.0f;
					float FXAA_SPAN_MAX : 8.0f;

					float3 rgbNW : sample(SRC.ColorBuffer, v_rgbNW, Uno.Graphics.SamplerState.LinearWrap).XYZ;
				    float3 rgbNE : sample(SRC.ColorBuffer, v_rgbNE, Uno.Graphics.SamplerState.LinearWrap).XYZ;
				    float3 rgbSW : sample(SRC.ColorBuffer, v_rgbSW, Uno.Graphics.SamplerState.LinearWrap).XYZ;
				    float3 rgbSE : sample(SRC.ColorBuffer, v_rgbSE, Uno.Graphics.SamplerState.LinearWrap).XYZ;
				    float4 texColor : sample(SRC.ColorBuffer, v_rgbM, Uno.Graphics.SamplerState.LinearWrap);
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
				        sample(SRC.ColorBuffer, uv  + dir2 * (1.0f / 3.0f - 0.5f), Uno.Graphics.SamplerState.LinearWrap).XYZ +
				        sample(SRC.ColorBuffer, uv + dir2 * (2.0f / 3.0f - 0.5f), Uno.Graphics.SamplerState.LinearWrap).XYZ);
				    float3 rgbB : rgbA * 0.5f + 0.25f * (
				        sample(SRC.ColorBuffer, uv  + dir2 * -0.5f, Uno.Graphics.SamplerState.LinearWrap).XYZ +
				        sample(SRC.ColorBuffer, uv  + dir2 * 0.5f, Uno.Graphics.SamplerState.LinearWrap).XYZ);

				    float lumaB : Vector.Dot(rgbB, luma);
					
					PixelColor : ((lumaB < lumaMin) || (lumaB > lumaMax)) ? float4(rgbA, texColor.W) : float4(rgbB, texColor.W);
					


					//PixelColor : float4(prev.XYZ - (1f-sample(simppafi.FramebufferStorage.GlobalShadowBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).X) * .5f, prev.W);

					//float shadow : sample(simppafi.FramebufferStorage.GlobalShadowBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).X;
					//shadow : (prev + prev);// * 2f;//prev * (prev+.5f);
					//PixelColor : float4(prev.XYZ * shadow, prev.W);

					
					//float4 ssao : sample(simppafi.FramebufferStorage.GlobalSSAOBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

					//PixelColor : float4(prev.XYZ * ssao.XYZ, 1f);

					//PixelColor : float4(prev.XYZ - (1f-ssao.XYZ), 1f);


					PixelColor : prev + sample(TRANS.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

					//PixelColor : prev + (sample(blurred.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) - prev) * Math.Clamp((50f-uv.Y*100f), 0f, 1f);

				};
				dc.PopRenderTarget();
			}
			else{
				FXAA = SRC;
			}



			var blurred = Fuse.FramebufferPool.Lock(FXAA.Size/2, FXAA.Format, false);
			dc.PushRenderTarget(blurred);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(FXAA.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();
			int rounds = 8;
			BokehBlur(dc, blurred, rounds);


			// BOKEH FRONT
			var bokehfront = Fuse.FramebufferPool.Lock(FXAA.Size/4, FXAA.Format, true);
			dc.PushRenderTarget(bokehfront);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				
				float4 depthPx : sample(DEPTH.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

				float limitnear : simppafi.GlobalParams.BokehLimitNear;
				
				//float depthCutNear : 
				//{
				//	if(depthPx.X < limitnear)
				//	{
				//		return limitnear + (limitnear-depthPx.X) * (1f/limitnear);
				//	}
				//	else{
				//		return 0f;
				//	}
				//};

				float depthCutNear : (depthPx.X < limitnear) ? limitnear + (limitnear-depthPx.X) * (1f/limitnear) : 0f;

				PixelColor : float4(depthCutNear);

			};
			dc.PopRenderTarget();
			blur(dc, bokehfront, 4, float2(1f,1f), float2(1.0f,1.0f));
			

			var _endTitle = endTitle;

			var JJ = Fuse.FramebufferPool.Lock(FXAA.Size/4, FXAA.Format, false);
			dc.PushRenderTarget(JJ);
			dc.Clear(float4(0,0,0,0), 1);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

				float _depth : 1f-sample(DEPTH.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).X;//1f-simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

				float4 colorPx : sample(import Uno.Graphics.Texture2D("../../Assets/lensflare/lens_color.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap);

				float4 orgPx : sample(blurred.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				float3 thresshold : Math.Round( (orgPx.XYZ) - .5f ) * _depth;

				PixelColor : float4(thresshold*colorPx.XYZ,1f);
			};
			dc.PopRenderTarget();
			blur(dc, JJ, 16, float2(9f,.01f), float2(1.1f,1f));
			//blur(dc, JJ, 1, float2(1f,10f), float2(2f,2f));



			//draw {texture2D LensTexture : LensTextures[LensTextureID];}, Quad
			
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

				float4 JJPx : float4(sample(JJ.ColorBuffer, ClipPosition.XY * 0.5f + 0.5f, Uno.Graphics.SamplerState.LinearWrap).XYZ, 1f);
				
				uv : prev + float2(JJPx.X*.03f,0);

				float4 blurPx : sample(blurred.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);// + dirt;
				float4 bokehfrontPx : sample(bokehfront.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				float4 depthPx : sample(DEPTH.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				
				float4 orgPx : sample(FXAA.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

				PixelColor :  orgPx;
				

				//float4 dirt : sample(import Uno.Graphics.Texture2D("../../Assets/lensflare/lensdirt.jpg"), TexCoord, Uno.Graphics.SamplerState.LinearWrap);
				
				

				float limitfar : simppafi.GlobalParams.BokehLimitFar;
				//float depthCut : 
				//{
				//	if(depthPx.X > limitfar)
				//	{
				//		return Math.Min(1f, (depthPx.X-limitfar) * (1f/limitfar));
				//	}else{
				//		return 0f;
				//	}
				//};

				float depthCut : (depthPx.X > limitfar) ? Math.Min(1f, (depthPx.X-limitfar) * (1f/limitfar)) : 0f;



				PixelColor : prev * (1f-depthCut) + blurPx * depthCut;// * depthCutNear;

				float off : Math.Min(1f, bokehfrontPx.W*5f);
				PixelColor : float4( Math.Max(float3(0f), (prev.XYZ * (float3(1f) - off )) ) + blurPx.XYZ * off, 1f);

				
				PixelColor : prev - float4(0f,.025f,.05f,0) * Math.Max(0f, (1f-depthPx.X * 6f));

				

				PixelColor : float4(prev.XYZ + JJPx.XYZ, 1f);
				
				
				float downFade : 1f+Math.Min(simppafi.GlobalParams.FadeAddValue, 0f);

				PixelColor : float4(
					Math.Min(float3(1f), (prev.XYZ*downFade + float3(0.144f*prev.X + 0.587f*prev.Y + 0.299f*prev.Z) * (1f-downFade)))
					 + float3(simppafi.GlobalParams.FadeAddValue), 1f);



			};

			Fuse.FramebufferPool.Release(blurred);
			Fuse.FramebufferPool.Release(bokehfront);
			Fuse.FramebufferPool.Release(JJ);
			Fuse.FramebufferPool.Release(DEPTH);
			Fuse.FramebufferPool.Release(FXAA);
			Fuse.FramebufferPool.Release(TRANS);
			*/
		}

/*
		public int size = 1;
		public float Stretch = 1.25f;

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
				float4 so = float4(0);
				for(var i = 0; i < rounds; i++)
				{
					so += sample(src.ColorBuffer, uv + angle * i, Uno.Graphics.SamplerState.LinearWrap);//.XYZ;// * (1f+(float)i/(float)rounds);
				}
				return (so/rounds);
			};
		}

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
				//PixelColor : float4((AngleBlur.XYZ + sample(rhombi1.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).XYZ + sample(rhombi2.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).XYZ ) / 2.35f, 1);
				PixelColor : ((AngleBlur + sample(rhombi1.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) + sample(rhombi2.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) ) / 2.35f);
				//PixelColor : float4(sample(rhombi1.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).XYZ, 1f);
			};
			dc.PopRenderTarget();
			
			Fuse.FramebufferPool.Release(rhombi1);
			Fuse.FramebufferPool.Release(rhombi2);
			Fuse.FramebufferPool.Release(rhombi3);
			Fuse.FramebufferPool.Release(offset);

		}




		private int a = 0;

		private block AA
		{
			//apply simppafi.RenderLibrary.FXDeferred;
			//apply simppafi.RenderLibrary.ValuePixelOnScreen;
			//float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).ZW);
			apply simppafi.RenderLibrary.GlobalDepthLinear;

			float2 PixelSize : prev;

			float _depthMX : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ValuePixelOnScreen + float2(PixelSize.X,0), Uno.Graphics.SamplerState.LinearWrap).ZW);
			float _depthPX : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ValuePixelOnScreen - float2(PixelSize.X,0), Uno.Graphics.SamplerState.LinearWrap).ZW);
			float _depthMY : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ValuePixelOnScreen + float2(0,PixelSize.Y), Uno.Graphics.SamplerState.LinearWrap).ZW);
			float _depthPY : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ValuePixelOnScreen - float2(0,PixelSize.Y), Uno.Graphics.SamplerState.LinearWrap).ZW);

			float depthSum : Math.Abs(GlobalDepthLinear - _depthMX) + Math.Abs(GlobalDepthLinear - _depthPX) + Math.Abs(GlobalDepthLinear - _depthPY) + Math.Abs(GlobalDepthLinear - _depthPY);
			PixelColor : 
				req(BlurPixel as float4)
					//prev + (BlurPixel-prev) * Math.Min(1f, depthSum*2f);
					//prev + (0f-prev) * Math.Min(1f, depthSum);
					prev - (depthSum*.1f);
		}


		private void blur(DrawContext dc, framebuffer source, int Steps = 1, float2 mul = float2(1,1), float2 power = float2(1f,1f))
		{
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			// GAUSSIAN DOF
			var offsetX = float2(1f/(float)source.Size.X, 0) * mul;
			var offsetY = float2(0, 1f/(float)source.Size.Y) * mul;
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(offset);
				dc.Clear(float4(0,0,0,0), 1);
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 sum : sample(source.ColorBuffer, uv, samplerState) * 0.204164f * power.X;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 1.407333f, samplerState) * 0.304005f * power.X;
					sum : prev + sample(source.ColorBuffer, uv - offsetX * 1.407333f, samplerState) * 0.304005f * power.X;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 3.294215f, samplerState) * 0.093913f * power.X;
					PixelColor : sum + sample(source.ColorBuffer, uv - offsetX * 3.294215f, samplerState) * 0.093913f * power.X;
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 sum : sample(offset.ColorBuffer, uv, samplerState) * 0.204164f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 1.407333f, samplerState) * 0.304005f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv - offsetY * 1.407333f, samplerState) * 0.304005f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 3.294215f, samplerState) * 0.093913f * power.Y;
					PixelColor : sum + sample(offset.ColorBuffer, uv - offsetY * 3.294215f, samplerState) * 0.093913f * power.Y;
				};
				dc.PopRenderTarget();

			}

			Fuse.FramebufferPool.Release(offset);
		}



		private block DepthCurve
		{
			apply simppafi.RenderLibrary.GlobalDepthLinear;
			float curv : (1f-Math.Sin(GlobalDepthLinear * Math.PIf));
			curv : prev * prev * prev * prev;
			float DepthCurve : curv;
		}

		private void depthBlur(DrawContext dc, framebuffer source, int Steps = 1, float2 mul = float2(1,1), float2 power = float2(1f,1f))
		{
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			// GAUSSIAN DOF
			var offsetX = float2(1f/(float)source.Size.X, 0) * mul;
			var offsetY = float2(0, 1f/(float)source.Size.Y);
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(offset);
				dc.Clear(float4(0,0,0,0), 1);
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
					
					apply DepthCurve;
					
					float4 sum : sample(source.ColorBuffer, uv, samplerState) * 0.204164f * power.X;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 1.407333f * DepthCurve, samplerState) * 0.304005f * power.X;
					sum : prev + sample(source.ColorBuffer, uv - offsetX * 1.407333f * DepthCurve, samplerState) * 0.304005f * power.X;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 3.294215f * DepthCurve, samplerState) * 0.093913f * power.X;
					PixelColor : sum + sample(source.ColorBuffer, uv - offsetX * 3.294215f * DepthCurve, samplerState) * 0.093913f * power.X;
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					apply DepthCurve;

					float4 sum : sample(offset.ColorBuffer, uv, samplerState) * 0.204164f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 1.407333f * DepthCurve, samplerState) * 0.304005f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv - offsetY * 1.407333f * DepthCurve, samplerState) * 0.304005f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 3.294215f * DepthCurve, samplerState) * 0.093913f * power.Y;
					PixelColor : sum + sample(offset.ColorBuffer, uv - offsetY * 3.294215f * DepthCurve, samplerState) * 0.093913f * power.Y;
				};
				dc.PopRenderTarget();

			}

			Fuse.FramebufferPool.Release(offset);
		}
		*/

	}
}