using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Fuse.Entities;
using Uno.Content;
using Uno.Content.Models;
using simppafi.Utils.Size;

namespace simppafi
{
	public class RenderPipeline
	{
		public delegate void RenderPipelineEventHandler();
		public event RenderPipelineEventHandler 		ALL_IS_SETUP;
		public event RenderPipelineEventHandler 		INIT_STEP;

		public enum RenderingMode
		{
			DEFERRED,
			FORWARD
		}

		public Frustum CameraFrustum {get;set;}

		public static RenderingMode RenderMode = simppafi.RenderPipeline.RenderingMode.FORWARD;

		public static List<simppafi.Object.ObjectLight> Lights = new List<simppafi.Object.ObjectLight>();
		
		public static bool Glitch = false;

		public static bool IsPost = false;
		public static bool IsDepth = false;
		public static bool IsNormal = false;
		public static bool IsShadow = false;
		public static bool IsSSAO = false;
		public static bool ScreenResized = false;
		public static bool IsWeight = false;
		public bool AllIsSetup = false;
		
		public static float Resolution = 1f;

		public static framebuffer PostFullFrame = new framebuffer(int2(8,8), Uno.Graphics.Format.RGBA8888, FramebufferFlags.None);
		private int2 PostFullFrame_Size = int2(8,8);
		private int2 _postFullFrame_size = int2(8,8);

		public static bool IsMirror = false;

		public static Transform3D CameraTransform;

		public int BlurUV = 0;
		public static float2 PixelSize;

		public List<EnvShadow> ShadowList = new List<EnvShadow>();

		public RenderPipeline()
		{
			//EnvShadow.lightPosition = float3(30f, 500f, 50f);
			//EnvShadow.shadowAmbient = .35f;
			//EnvShadow.lightDepth = 1500.0f;

			//EnvShadow.lightTarget = float3(0,0,0);
			//EnvShadow.perspective = 1f;

		}

		public void AddChild(BaseVisual visual)
		{
			setupAllCount = 0;
			if(!visual.isSetup)
			{
				AllIsSetup = false;
			}
			DisplayList.Add(visual);

			if(!EffectList.Contains(visual.Effect))
			{
				EffectList.Add(visual.Effect);
			}

			if(!RenderList.ContainsKey(visual.Effect))
			{
				RenderList[visual.Effect] = new List<simppafi.BaseVisual>();
			}

			if(visual.IsSilhuette)
			{
				SilhuetteDrawList.Add(visual);
			}

			RenderList[visual.Effect].Add(visual);
		}

		public void RemoveChild(BaseVisual visual)
		{
			if(RenderList != null)
			{
				if(RenderList.ContainsKey(visual.Effect))
				{

					if(RenderList[visual.Effect].Count == 1)
					{
						EffectList.Remove(visual.Effect);
					}

					RenderList[visual.Effect].Remove(visual);
					visual.OnOff();
					DisplayList.Remove(visual);
				}
			}
			if(visual.IsSilhuette)
			{
				SilhuetteDrawList.Remove(visual);
			}
		}


		public void AddLight(BaseVisual visual)
		{
			DisplayList.Add(visual);

			if(!EffectLightList.Contains(visual.Effect))
			{
				EffectLightList.Add(visual.Effect);
			}

			if(!RenderLightList.ContainsKey(visual.Effect))
			{
				RenderLightList[visual.Effect] = new List<simppafi.BaseVisual>();
			}

			RenderLightList[visual.Effect].Add(visual);
		}

		public void RemoveLight(BaseVisual visual)
		{
			if(RenderLightList != null)
			{
				if(RenderLightList.ContainsKey(visual.Effect))
				{

					if(RenderLightList[visual.Effect].Count == 1)
					{
						EffectLightList.Remove(visual.Effect);
					}

					RenderLightList[visual.Effect].Remove(visual);
					visual.OnOff();
					DisplayList.Remove(visual);
				}
			}
		}


		public void AddTransparent(BaseVisual visual)
		{
			DisplayList.Add(visual);

			if(!EffectTransparencyList.Contains(visual.Effect))
			{
				EffectTransparencyList.Add(visual.Effect);
			}

			if(!RenderTransparencyList.ContainsKey(visual.Effect))
			{
				RenderTransparencyList[visual.Effect] = new List<simppafi.BaseVisual>();
			}

			RenderTransparencyList[visual.Effect].Add(visual);

		}

		public void RemoveTransparent(BaseVisual visual)
		{
			if(RenderTransparencyList != null)
			{
				if(RenderTransparencyList.ContainsKey(visual.Effect))
				{

					if(RenderTransparencyList[visual.Effect].Count == 1)
					{
						EffectTransparencyList.Remove(visual.Effect);
					}

					RenderTransparencyList[visual.Effect].Remove(visual);
					visual.OnOff();
					DisplayList.Remove(visual);
				}
			}
		}


		public void AddGlowChild(BaseVisual visual)
		{
			DisplayList.Add(visual);
			GlowList.Add(visual);
		}

		public void RemoveGlowChild(BaseVisual visual)
		{
			if(GlowList != null)
			{
				visual.OnOff();
				GlowList.Remove(visual);
				DisplayList.Remove(visual);
			}
		}



		public void ClearChilds()
		{
			if(RenderList != null)
			{
				var l = DisplayList.Count;
				for(var i = 0; i < l; i++)
				{
					DisplayList[i].OnOff();
				}
				DisplayList.Clear();
				RenderList.Clear();
				EffectList.Clear();
				RenderLightList.Clear();
				EffectLightList.Clear();
				RenderTransparencyList.Clear();
				EffectTransparencyList.Clear();
				SilhuetteDrawList.Clear();
				GlowList.Clear();
			}
		}

		private BaseModifie _currentModifie;
		public BaseModifie CurrentModifie
		{
			get {
				return _currentModifie;
			}
			set {
				_currentModifie = value;
				FramebufferStorage.RenderModifie = (value != null);
			}
		}

		public void Hit(float val)
		{
			for(var j = 0; j < DisplayList.Count; j++)
			{
				if(!DisplayList[j].Disabled && DisplayList[j].isSetup)
						DisplayList[j].Hit(val);
			}
		}

		public void Peak(float val)
		{
			for(var j = 0; j < DisplayList.Count; j++)
			{
				if(!DisplayList[j].Disabled && DisplayList[j].isSetup)
						DisplayList[j].Peak(val);
			}
		}

		public void Reset()
		{
			for(var j = 0; j < DisplayList.Count; j++)
			{
				if(!DisplayList[j].Disabled)
						DisplayList[j].Reset();
			}
		}

		public void Change(float val)
		{
			for(var j = 0; j < DisplayList.Count; j++)
			{
				if(!DisplayList[j].Disabled)
						DisplayList[j].Change(val);
			}
		}

		private Dictionary<simppafi.Effect.BaseEffect, List<simppafi.BaseVisual>> 	RenderList = new Dictionary<simppafi.Effect.BaseEffect, List<simppafi.BaseVisual>>();
		private List<simppafi.Effect.BaseEffect> 									EffectList = new List<simppafi.Effect.BaseEffect>();

		private Dictionary<simppafi.Effect.BaseEffect, List<simppafi.BaseVisual>> 	RenderLightList = new Dictionary<simppafi.Effect.BaseEffect, List<simppafi.BaseVisual>>();
		private List<simppafi.Effect.BaseEffect> 									EffectLightList = new List<simppafi.Effect.BaseEffect>();

		private Dictionary<simppafi.Effect.BaseEffect, List<simppafi.BaseVisual>> 	RenderTransparencyList = new Dictionary<simppafi.Effect.BaseEffect, List<simppafi.BaseVisual>>();
		private List<simppafi.Effect.BaseEffect> 									EffectTransparencyList = new List<simppafi.Effect.BaseEffect>();
		
		private List<BaseVisual> 													DisplayList = new List<BaseVisual>();
		private List<BaseVisual> 													SilhuetteDrawList = new List<BaseVisual>();
		private List<BaseVisual> 													GlowList = new List<BaseVisual>();
		
		private static bool InitAllIsSetup = false;
		private int setupAllCount = 0;

		public void OnUpdate()
		{
			int i,l;

			l = DisplayList.Count;
			if(l == 0) return;

			if(!AllIsSetup)
			{
				if(!DisplayList[setupAllCount].isSetup)
				{
					DisplayList[setupAllCount].Setup();
					if(INIT_STEP != null) INIT_STEP();
					return;
				}
				setupAllCount++;
				if(setupAllCount == DisplayList.Count)
				{
					AllIsSetup = true;
					if(ALL_IS_SETUP != null) ALL_IS_SETUP();
				}
			}


			BaseVisual visual;
			for(i = 0; i < l; i++)
			{
				visual = DisplayList[i];
				if(visual.isSetup)
				{
					visual.OnUpdate();
				}
			}

		}

		

		//FORWARD RENDER
/*
		public void RenderPost(Fuse.DrawContext dc)
		{
			int i, j;
			int2 _size;
			simppafi.Effect.BaseEffect 	fx;
			List<simppafi.BaseVisual> 	ls;

			PixelSize = float2(1f/dc.RenderTarget.Size.X, 1f/dc.RenderTarget.Size.Y);

			if(FramebufferStorage.Resize(dc))
			{
				ScreenResized = true;
			}else{
				ScreenResized = false;
			}

			//SETTINGS
			_frustumCorners = new simppafi.Utils.FrustumCorners(Matrix.Invert(dc.Viewport.ProjectionTransform));//dc.InverseProjection);

			BasePass.dcViewportSize = FramebufferStorage.GlobalPostBuffer.Size;
			BasePass.dcRatio = FramebufferStorage.GlobalPostBuffer.Size.Ratio;
			BasePass.FarCorners = _frustumCorners.FarCorners;
			BasePass.NearCorners = _frustumCorners.NearCorners;

			

			//SHADOW MAP
			
			if(FramebufferStorage.RenderShadow)
			{
				EnvShadow.Begin(dc);

				PassFront = shadowPass;
				PassBackground = emptyPass;
				IsDepth = false;
				IsPost = false;
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && ls[i].CastShadow)
						{
							ls[i].Draw(dc);
							ls[i].DrawSecond(dc);
						}
					}
				}

				EnvShadow.End(dc);

				//blur16Bit(dc, EnvShadow.shadowMap, 2);
				blur32Bit(dc, EnvShadow.shadowMap, 1);

			}
			



			// EFFECT MASK
			if(FramebufferStorage.RenderMask)
			{
				dc.PushRenderTarget(FramebufferStorage.GlobalMaskBuffer);
				dc.Clear(float4(0,0,0,0), 1f);

				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];

					if(fx.SkipMask)
						continue;

					ls = RenderList[fx];

					frontMaskPass.MaskColor = fx.MaskColor = (float)j/(float)EffectList.Count;

					PassFront = frontMaskPass;
					PassBackground = bgMaskPass;

					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].SkipMaskDraw)
						{
							ls[i].Draw(dc);
							ls[i].DrawSecond(dc);
						}
					}

				}
				dc.PopRenderTarget();
			}

			//blur(dc, FramebufferStorage.GlobalMaskBuffer, 1);

			// DEPTH
			if(FramebufferStorage.RenderDepth)
			{
				PassFront = depthPass;
				PassBackground = depthPass;
				IsDepth = true;
				IsPost = false;
				dc.PushRenderTarget(FramebufferStorage.GlobalDepthBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].SkipDepthDraw)
						{
							ls[i].Draw(dc);
							ls[i].DrawSecond(dc);
						}
					}
				}
				dc.PopRenderTarget();
			}


			// POST
			for(j = 0; j < EffectList.Count; j++)
			{
				fx = EffectList[j];
				if(fx.SkipPost)
					continue;
				
				ls = RenderList[fx];

				IsPost = true;
				IsDepth = false;
				_size = GetSize(FramebufferStorage.ResolutionPost, dc);
				if(_size != fx.PostFramebuffer.Size)
				{
					if(fx.PostFramebuffer != null) {  fx.PostFramebuffer.Dispose();  fx.PostFramebuffer = null; }
					if(fx.PostTarget != null) {  fx.PostTarget.Dispose();  fx.PostTarget = null; }
					fx.PostFramebuffer = new framebuffer(_size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
					fx.PostTarget = new framebuffer(_size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
				}

				dc.PushRenderTarget(fx.PostTarget);
				dc.Clear(float4(0,0,0,1), 1f);

				PassFront = fx.postFront;
				PassBackground = fx.postBackground;

				for(i = 0; i < ls.Count; i++)
				{
					if(!ls[i].Disabled)
					{
						ls[i].Draw(dc);
						ls[i].DrawSecond(dc);
					}
				}
				dc.PopRenderTarget();

				if(fx.Post != null) 
				{
					fx.Post.dcViewportSize = FramebufferStorage.GlobalPostBuffer.Size;
					fx.Post.dcRatio = FramebufferStorage.GlobalPostBuffer.Size.Ratio;
					fx.Post.FarCorners = _frustumCorners.FarCorners;
					fx.Post.NearCorners = _frustumCorners.NearCorners;
					fx.Post.InverseProjection = Matrix.Invert(dc.Viewport.ProjectionTransform);

					fx.Post.Process(dc, fx.PostTarget, fx.PostFramebuffer);
				}
			}


			// MERGE POST
			var offset = FramebufferPool.Lock(FramebufferStorage.GlobalPostBuffer.Size, Uno.Graphics.Format.RGBA8888, false);
			dc.PushRenderTarget(offset);
			dc.Clear(float4(0,0,0,0));
			dc.PopRenderTarget();
			
			for(j = 0; j < EffectList.Count; j++)
			{
				fx = EffectList[j];
				if(fx.SkipPost)
					continue;

				dc.PushRenderTarget(FramebufferStorage.GlobalPostBuffer);
				dc.Clear(float4(0,0,0,0));
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv : ClipPosition.XY * 0.5f + 0.5f;
					PixelColor : 	sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) +
									sample(fx.PostFramebuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				};
				dc.PopRenderTarget();

				if(j < EffectList.Count-1 && fx.AddToOtherEffects)
				{
					dc.PushRenderTarget(offset);
					dc.Clear(float4(0,0,0,0));
					draw Fuse.Drawing.Primitives.Quad
					{
						DepthTestEnabled: false;
						CullFace: Uno.Graphics.PolygonFace.None;
						float2 uv : ClipPosition.XY * 0.5f + 0.5f;
						PixelColor : sample(FramebufferStorage.GlobalPostBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
					};
					dc.PopRenderTarget();
				}
			}
			FramebufferPool.Release(offset);
			

			

		}

		public void RenderFinal(Fuse.DrawContext dc)
		{
			int i,j;

			//SETTINGS
			BasePass.dcViewportSize = dc.GLViewportPixelSize;
			BasePass.dcRatio = dc.GLViewportPixelSize.Ratio;

			if(IsMirror)
			{
				dc.PushRenderTarget(EnvMirror.mirrorMap);
				dc.Clear(float4(0,0,0,0));
			}
			else if(FramebufferStorage.RenderModifie)
			{
				dc.PushRenderTarget(FramebufferStorage.GlobalModifieBuffer);
				dc.Clear(float4(0,0,0,0));
			}

			IsPost = false;
			IsDepth = false;
			dc.Clear(float4(0,0,0,1), 1f);

			simppafi.Effect.BaseEffect 	fx;
			List<simppafi.BaseVisual> 	ls;
			for(j = 0; j < EffectList.Count; j++)
			{
				fx = EffectList[j];
				ls = RenderList[fx];

				PassFront = fx.finalFront;
				PassBackground = fx.finalBackground;

				for(i = 0; i < ls.Count; i++)
				{
					if(!ls[i].Disabled)
					{
						ls[i].Draw(dc);
						ls[i].DrawSecond(dc);
						ls[i].DrawParticles(dc);
					}
				}
			}


			if(IsMirror)
			{
				dc.PopRenderTarget();

				blur(dc, EnvMirror.mirrorMap, 1);
			}
			else if(FramebufferStorage.RenderModifie)
			{
				dc.PopRenderTarget();

				_currentModifie.Process(dc, FramebufferStorage.GlobalModifieBuffer);
			}


			//dc.Clear(float4(0,0,0,0), 1);
			//draw Fuse.Drawing.Primitives.Quad
			//{
			//	DepthTestEnabled: false;
			//	CullFace: Uno.Graphics.PolygonFace.None;
			//	float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

				//PixelColor : sample(FramebufferStorage.GlobalMaskBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			//	PixelColor : sample(EnvMirror.mirrorMap.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			//};
			
		}
		*/


		//private simppafi.DepthPass			depthPass = new simppafi.DepthPass();
		//private simppafi.NormalPass			normalPass = new simppafi.NormalPass();
		//private simppafi.UVPass				uvPass = new simppafi.UVPass();
		//private simppafi.ReflectPass		reflectPass = new simppafi.ReflectPass();
		//private simppafi.SSAOPass			ssaoPass = new simppafi.SSAOPass();
		//private simppafi.EmptyPass			emptyPass = new simppafi.EmptyPass();
		private simppafi.DeferredMergePass 	deferredMergePass = new simppafi.DeferredMergePass();
		//private simppafi.EdgePass			edgePass = new simppafi.EdgePass();
		private simppafi.SSRPass 			ssrPass = new simppafi.SSRPass();
		private simppafi.ByPass 			byPass = new simppafi.ByPass();
		private simppafi.MRAOPass 			mraoPass = new simppafi.MRAOPass();
		private simppafi.SSSAOPass 			sssaoPass = new simppafi.SSSAOPass();
		private simppafi.WeightPass 		weightPass = new simppafi.WeightPass();
		private simppafi.DepthCutPass 		depthCutPass = new simppafi.DepthCutPass();

		//private simppafi.ShadowPass			shadowPass = new simppafi.ShadowPass();
		//public static simppafi.ShadowFramePass 	shadowFramePass = new simppafi.ShadowFramePass();

		//public simppafi.PostFindEdges 		postFindEdges = new simppafi.PostFindEdges(1f, .5f, float4(1,1,1,1));
		//public simppafi.PostRadialRemi 		postRadial = new simppafi.PostRadialRemi();

		public static simppafi.BasePass		PassFront;
		public static simppafi.BasePass		PassBackground;

		private int2 						size;

		//private simppafi.MaskBackgroundPass	bgMaskPass = new MaskBackgroundPass();
		//private simppafi.MaskFrontPass		frontMaskPass = new MaskFrontPass();


		private simppafi.Utils.FrustumCorners _frustumCorners;

		public static bool IsMirrorDraw = false;

		// DEFERRED RENDER

		public void RenderDeferred(Fuse.DrawContext dc)
		{
			int i, j;
			simppafi.Effect.BaseEffect 	fx;
			List<simppafi.BaseVisual> 	ls;

			if(FramebufferStorage.Resize(dc))
			{
				ScreenResized = true;
			}else{
				ScreenResized = false;
			}

			//debug_log dc.RenderTarget.Size;

			//SETTINGS
			//DrawContext.Camera.ProjectionTransformInverse
			_frustumCorners = new simppafi.Utils.FrustumCorners(Matrix.Invert(dc.Viewport.ProjectionTransform));//dc.InverseProjection); //OPTIMIZE THIS

			BasePass.dcViewportSize = FramebufferStorage.GlobalDeferredBuffer.Size;
			BasePass.dcRatio = FramebufferStorage.GlobalDeferredBuffer.Size.Ratio;
			BasePass.FarCorners = _frustumCorners.FarCorners;
			BasePass.NearCorners = _frustumCorners.NearCorners;
			BasePass.InverseProjection = Matrix.Invert(dc.Viewport.ProjectionTransform);//dc.InverseProjection;
			BasePass.Projection = dc.Viewport.ProjectionTransform;
			BasePass.ZFar = CameraFrustum.ZFar;
			BasePass.ZNear = CameraFrustum.ZNear;

			/*
			// DEPTH
			if(FramebufferStorage.RenderDepth)
			{
				PassFront = depthPass;
				PassBackground = depthPass;
				IsDepth = true;
				IsPost = false;
				dc.PushRenderTarget(FramebufferStorage.GlobalDepthBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].SkipDepthDraw && !ls[i].IsSilhuette)
							ls[i].Draw(dc);
					}
				}
				dc.PopRenderTarget();
				IsDepth = false;

				//blur32Bit(dc, FramebufferStorage.GlobalDepthBuffer, 3);
			}


			// NORMALS
			if(FramebufferStorage.RenderNormal)
			{
				PassFront = normalPass;
				PassBackground = normalPass;
				IsDepth = false;
				IsPost = false;
				IsNormal = true;
				dc.PushRenderTarget(FramebufferStorage.GlobalNormalBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].SkipNormalDraw && !ls[i].IsSilhuette)
							ls[i].Draw(dc);
					}
				}
				dc.PopRenderTarget();
				IsNormal = false;
			}
	*/
			


			

			/*
			// UV
			if(FramebufferStorage.RenderUV)
			{
				PassFront = uvPass;
				PassBackground = emptyPass;
				IsDepth = false;
				IsPost = false;
				IsNormal = false;
				dc.PushRenderTarget(FramebufferStorage.GlobalUVBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].SkipUVDraw && !ls[i].IsSilhuette) ls[i].Draw(dc);
					}
				}
				dc.PopRenderTarget();

				if(BlurUV > 0)
					blur(dc, FramebufferStorage.GlobalUVBuffer, BlurUV);
			}
			*/


/*
			// REFLECT
			if(FramebufferStorage.RenderReflect)
			{
				PassFront = reflectPass;
				PassBackground = emptyPass;
				IsDepth = false;
				IsPost = false;
				IsNormal = false;
				dc.PushRenderTarget(FramebufferStorage.GlobalReflectBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].SkipReflectDraw && !ls[i].IsSilhuette) ls[i].Draw(dc);
					}
				}
				dc.PopRenderTarget();
			}
			*/


			
			
			
			
			

			// EFFECT DEFERRED
			dc.PushRenderTarget(FramebufferStorage.GlobalDeferredBuffer);
			dc.Clear(float4(1,1,1,1), 1f);
			for(j = 0; j < EffectList.Count; j++)
			{
				fx = EffectList[j];
				ls = RenderList[fx];

				PassFront = fx.postFront;
				PassBackground = fx.postBackground;

				for(i = 0; i < ls.Count; i++)
				{
					if(!ls[i].Disabled && !ls[i].IsSilhuette)
						ls[i].Draw(dc);
				}

			}

			ls = SilhuetteDrawList;
			for(i = 0; i < ls.Count; i++)
			{
				ls[i].DrawSilhuette(dc);
			}

			ls = GlowList;
			for(i = 0; i < ls.Count; i++)
			{
				if(!ls[i].Disabled)
					ls[i].Draw(dc);
			}
			dc.PopRenderTarget();
			

			// WEIGHT
			if(FramebufferStorage.RenderWeight)
			{
				PassFront = weightPass;
				PassBackground = weightPass;
				IsDepth = false;
				IsPost = false;
				IsWeight = true;
				dc.PushRenderTarget(FramebufferStorage.GlobalWeightBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].IsSilhuette)
							ls[i].Draw(dc);
					}
				}
				ls = GlowList;
				for(i = 0; i < ls.Count; i++)
				{
					if(!ls[i].Disabled)
						ls[i].Draw(dc);
				}
				dc.PopRenderTarget();
				IsWeight = false;
			}
				


			// METALLIC ROUGHNESS AO
			if(FramebufferStorage.RenderMRAO)
			{
				PassFront = mraoPass;
				PassBackground = mraoPass;
				IsDepth = false;
				IsPost = false;
				dc.PushRenderTarget(FramebufferStorage.GlobalMRAOBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].IsSilhuette)
							ls[i].Draw(dc);
					}
				}

				ls = GlowList;
				for(i = 0; i < ls.Count; i++)
				{
					if(!ls[i].Disabled)
						ls[i].Draw(dc);
				}

				dc.PopRenderTarget();


				//blur32Bit(dc, FramebufferStorage.GlobalDepthBuffer, 3);
			}


			if(FramebufferStorage.RenderAlbedo)
			{
				dc.PushRenderTarget(FramebufferStorage.GlobalAlbedoBuffer);
				dc.Clear(float4(0,0,0,0), 1f);

				PassFront = byPass;
				PassBackground = byPass;

				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];

					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled)// && !ls[i].IsSilhuette)
							ls[i].Draw(dc);
					}

				}

				ls = GlowList;
				for(i = 0; i < ls.Count; i++)
				{
					if(!ls[i].Disabled)
						ls[i].Draw(dc);
				}
				
				dc.PopRenderTarget();
			}




			// SILHUETTE
			if(FramebufferStorage.RenderSilhuette)
			{
				dc.PushRenderTarget(FramebufferStorage.GlobalSilhuetteBuffer);
				dc.Clear(float4(0,0,0,0), 1f);
				ls = SilhuetteDrawList;
				for(i = 0; i < ls.Count; i++)
				{
					ls[i].Draw(dc);
				}
				dc.PopRenderTarget();
			}

			
			// SSSAO
			if(FramebufferStorage.RenderSSSAO)
			{
				PassFront = sssaoPass;
				PassBackground = sssaoPass;
				IsDepth = false;
				IsPost = false;
				
				///*
				dc.PushRenderTarget(FramebufferStorage.GlobalSSSAOBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectLightList.Count; j++)
				{
					fx = EffectLightList[j];
					ls = RenderLightList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].IsSilhuette)
							ls[i].Draw(dc);
					}
				}

				dc.PopRenderTarget();
				//*/

				//dc.PushRenderTarget(FramebufferStorage.GlobalSSSAOBuffer);
				//dc.Clear(float4(0,0,0,0), 1);
				//draw Fuse.Drawing.Primitives.Quad, sssaoPass;
				//dc.PopRenderTarget();

				//blurBilateralGauss(dc, FramebufferStorage.GlobalSSSAOBuffer, 1);
				//fxaa(dc, FramebufferStorage.GlobalSSSAOBuffer, 1);
				//blur(dc, FramebufferStorage.GlobalSSSAOBuffer, 1, float2(1f), float2(1f));
			}

			

			// LIGHT SOURCES
			if(FramebufferStorage.RenderLightSources)
			{
				PassFront = null;
				PassBackground = null;
				IsDepth = false;
				IsPost = false;
				IsNormal = false;
				dc.PushRenderTarget(FramebufferStorage.GlobalLightSourcesBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				
				for(j = 0; j < EffectLightList.Count; j++)
				{
					fx = EffectLightList[j];
					ls = RenderLightList[fx];

					PassFront = fx.finalFront;
					PassBackground = fx.finalBackground;

					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled)
						{
							ls[i].DrawParticles(dc);
						}
					}
				}
				dc.PopRenderTarget();

				//radial(dc, FramebufferStorage.GlobalLightSourcesBuffer);

			}

			/*
			// EDGES
			if(FramebufferStorage.RenderEdges)
			{
				PassFront = edgePass;
				PassBackground = emptyPass;

				IsDepth = false;
				IsPost = false;
				IsNormal = false;

				var source = Fuse.FramebufferPool.Lock(FramebufferStorage.GlobalEdgesBuffer.Size, FramebufferStorage.GlobalEdgesBuffer.Format, true);

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];

					for(i = 0; i < ls.Count; i++)
					{
						PassFront.MaskColor = (float)i/(float)ls.Count;

						if(!ls[i].Disabled) ls[i].Draw(dc);
					}
				}
				dc.PopRenderTarget();


				postFindEdges.Process(dc, source, FramebufferStorage.GlobalEdgesBuffer);

				Fuse.FramebufferPool.Release(source);
			}
			*/

			/*
			// SSAO
			if(FramebufferStorage.RenderSSAO)
			{
				PassFront = ssaoPass;
				PassBackground = emptyPass;
				IsDepth = false;
				IsPost = false;
				IsNormal = false;
				IsShadow = false;
				IsSSAO = true;
				dc.PushRenderTarget(FramebufferStorage.GlobalSSAOBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectList.Count; j++)
				{
					fx = EffectList[j];
					ls = RenderList[fx];
					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled && !ls[i].SkipSSAO && !ls[i].IsSilhuette) ls[i].Draw(dc);
					}
				}
				dc.PopRenderTarget();

				blurBilateralGauss(dc, FramebufferStorage.GlobalSSAOBuffer, 1);

				//blur(dc, FramebufferStorage.GlobalSSAOBuffer, 1);

				//fxaa(dc, FramebufferStorage.GlobalSSAOBuffer, 1);

				IsSSAO = false;
				
			}
			*/
			

			// TRANSPARENT ELEMENTS
			if(FramebufferStorage.RenderTransparency)
			{
				dc.PushRenderTarget(FramebufferStorage.GlobalTransparencyBuffer);
				dc.Clear(float4(0,0,0,1), 1f);
				for(j = 0; j < EffectTransparencyList.Count; j++)
				{
					fx = EffectTransparencyList[j];
					ls = RenderTransparencyList[fx];

					PassFront = fx.finalFront;
					PassBackground = fx.finalBackground;

					for(i = 0; i < ls.Count; i++)
					{
						if(!ls[i].Disabled)
							ls[i].Draw(dc);
					}
				}
				dc.PopRenderTarget();

				//fxaa(dc, FramebufferStorage.GlobalTransparencyBuffer, 1);

				//blur(dc, FramebufferStorage.GlobalTransparencyBuffer, 1);
			}


			// GLOW ELEMENTS
			if(FramebufferStorage.RenderGlow)
			{
				dc.PushRenderTarget(FramebufferStorage.GlobalGlowBuffer);
				dc.Clear(float4(0,0,0,0), 1f);
				PassFront = depthCutPass;
				PassBackground = depthCutPass;
				for(i = 0; i < GlowList.Count; i++)
				{
					if(!GlowList[i].Disabled)
						GlowList[i].Draw(dc);
				}
				dc.PopRenderTarget();
				//blur(dc, FramebufferStorage.GlobalGlowBuffer, 16, float2(9f,.025f), float2(1.1f,1f));
				//fxaa(dc, FramebufferStorage.GlobalTransparencyBuffer, 1);

				//blur(dc, FramebufferStorage.GlobalTransparencyBuffer, 1);
			}




			/*
			//SHADOW MAP
			if(FramebufferStorage.RenderShadow)
			{	
				// SHADOW MAP
				IsShadow = true;
				for(var k = 0; k < ShadowList.Count; k++)
				{
					var shadow = ShadowList[k];

					shadowPass._envShadow = shadow;

					dc.PushRenderTarget(shadow.shadowMap);
					dc.Clear(float4(0,0,0,0), 1.0f);

					PassFront = shadowPass;
					PassBackground = emptyPass;
					IsDepth = false;
					IsPost = false;
					for(j = 0; j < EffectList.Count; j++)
					{
						fx = EffectList[j];
						ls = RenderList[fx];
						for(i = 0; i < ls.Count; i++)
						{
							if(!ls[i].Disabled && ls[i].CastShadow)
								ls[i].Draw(dc);
						}
					}

					for(j = 0; j < EffectTransparencyList.Count; j++)
					{
						fx = EffectTransparencyList[j];
						ls = RenderTransparencyList[fx];
						for(i = 0; i < ls.Count; i++)
						{
							if(!ls[i].Disabled && ls[i].CastShadow)
								ls[i].Draw(dc);
						}
					}

					dc.PopRenderTarget();

					//ShadowList[0].End(dc);

					blur32BitShadow(dc, shadow.shadowMap, 3);
				}

				IsShadow = false;

				
				var l = ShadowList.Count;
				if(shadowFramePass.ShadowList == null)
				{
					shadowFramePass.ShadowList = new EnvShadow[l];
					shadowFramePass._LightPositions = new float3[l];
					shadowFramePass._LightTargets = new float3[l]; 			
					shadowFramePass._LightShadowArea = new float2[l]; 		
					shadowFramePass._LightDepth = new float[l];				
					shadowFramePass._LightShadowC = new float[l];			
					shadowFramePass._LightShadowMap = new framebuffer[l];	
					shadowFramePass._LightPower = new float[l];			
				}

				for(i = 0; i < l; i++)
				{
					shadowFramePass.ShadowList[i] = ShadowList[i];
					shadowFramePass._LightPositions[i] = ShadowList[i].Light.Position;
					shadowFramePass._LightTargets[i] = ShadowList[i].Light.Target;
					shadowFramePass._LightShadowArea[i] = ShadowList[i].shadowArea;
					shadowFramePass._LightDepth[i] = ShadowList[i].lightDepth;
					shadowFramePass._LightShadowC[i] = ShadowList[i].shadowC;
					shadowFramePass._LightShadowMap[i] = ShadowList[i].shadowMap;
					shadowFramePass._LightPower[i] = ShadowList[i].Light.Power;
				}


			}
			*/

			
			

			

		}


		public void RenderLights(Fuse.DrawContext dc)
		{
			
			glow(dc, FramebufferStorage.GlobalGlowBuffer, 4, 4, float2(1.5f,1f));
			


			int i,j;

			// DEFERRED LIGHTS
			dc.PushRenderTarget(FramebufferStorage.GlobalDeferredFinalBuffer);
			dc.Clear(float4(0,0,0,0), 1f);

			IsPost = false;
			IsDepth = false;
			dc.Clear(float4(0,0,0,1), 1f);

			simppafi.Effect.BaseEffect 	fx;
			List<simppafi.BaseVisual> 	ls;
			for(j = 0; j < EffectLightList.Count; j++)
			{
				fx = EffectLightList[j];
				ls = RenderLightList[fx];

				PassFront = fx.finalFront;
				PassBackground = fx.finalBackground;

				for(i = 0; i < ls.Count; i++)
				{
					if(!ls[i].Disabled)
					{
						ls[i].Draw(dc);
					}
				}
			}
			dc.PopRenderTarget();

			//blurBilateralGauss(dc, FramebufferStorage.GlobalDeferredFinalBuffer, 1);
			//fxaa(dc, FramebufferStorage.GlobalDeferredFinalBuffer);
			//blur(dc, FramebufferStorage.GlobalDeferredFinalBuffer, 1);

			//blurBilateralGauss(dc, FramebufferStorage.GlobalDeferredFinalBuffer, 1);
			
			
			//SCREEN SPACE REFLECTION
			if(FramebufferStorage.RenderSSR)
			{
				
				dc.PushRenderTarget(FramebufferStorage.GlobalSSRBuffer);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad, ssrPass;
				dc.PopRenderTarget();
				
				//blurAlpha(dc, FramebufferStorage.GlobalSSRBuffer, 1, float2(4f));
				//blur(dc, FramebufferStorage.GlobalSSRBuffer, 1, float2(.5f));
				
				//fxaa(dc, FramebufferStorage.GlobalSSRBuffer, 1);
				//fxaa(dc, FramebufferStorage.GlobalSSRBuffer, 1);
				//fxaa(dc, FramebufferStorage.GlobalSSRBuffer, 1);

			}


			// LENS GLOW
			if(FramebufferStorage.RenderLensGlow)
			{
				dc.PushRenderTarget(FramebufferStorage.GlobalLensGlowBuffer);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 orgPx : sample(FramebufferStorage.GlobalGlowBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

					//float3 thresshold : orgPx.XYZ * 4f;

					PixelColor : orgPx;//float4(orgPx, 1f);
				};
				dc.PopRenderTarget();
				blur(dc, FramebufferStorage.GlobalLensGlowBuffer, 16, float2(9f,.025f), float2(1.1f,1f));
			}


			/*
			// FINAL COMBINATION
			PassFront = deferredMergePass;
			PassBackground = deferredMergePass;
			IsDepth = false;
			IsPost = false;
			IsNormal = false;
			dc.Clear(float4(0,0,0,1), 1f);
			for(j = 0; j < EffectList.Count; j++)
			{
				fx = EffectList[j];
				ls = RenderList[fx];
				for(i = 0; i < ls.Count; i++)
				{
					if(!ls[i].Disabled && !ls[i].IsSilhuette)
						ls[i].Draw(dc);
				}
			}
			*/

			//draw Fuse.Drawing.Primitives.Quad, deferredMergePass;

			// FINAL COMBINATION
			///*
			//debug_log Resolution;
			_postFullFrame_size = GetSize(1f, dc);
			if(_postFullFrame_size != PostFullFrame_Size)
			{
				PostFullFrame_Size = _postFullFrame_size;
				if(PostFullFrame != null) { PostFullFrame.Dispose(); PostFullFrame = null; }
				PostFullFrame = new framebuffer(_postFullFrame_size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.None);
			}
			
			//debug_log PostFullFrame.Size;
			// draw color to source
			dc.PushRenderTarget(PostFullFrame);
			dc.Clear(float4(0,0,0,0), 1);
			//debug_log dc.RenderTarget.Size;
			draw Fuse.Drawing.Primitives.Quad, deferredMergePass;
			dc.PopRenderTarget();

			//float2 siz = 1f / PostFullFrame.Size;
			fxaa(dc, PostFullFrame);
			///*
			dc.Clear(float4(0,0,0,0));
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv : ClipPosition.XY * 0.5f + 0.5f;

				float bluenoise : sample(import Uno.Graphics.Texture2D("../Assets/bluenoise/1024_1024/LDR_RGBA_0.png"), uv*2f, Uno.Graphics.SamplerState.LinearWrap).Y;
		

				float4 org_px : sample(FramebufferStorage.GlobalLensGlowBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				float av_px : (org_px.X+org_px.Y+org_px.Z) * .33f;

				float pos : (uv.X * 2f - 1f) * av_px * .2f;
				float4 neighX : sample(PostFullFrame.ColorBuffer, uv+float2(pos * bluenoise,0), Uno.Graphics.SamplerState.LinearWrap);

				//float4 neighY : sample(PostFullFrame.ColorBuffer, uv+float2(0,siz.Y*2f), Uno.Graphics.SamplerState.LinearWrap);

				PixelColor : neighX;// + neighY;
			};

			Fuse.FramebufferPool.Release(PostFullFrame);
			//*/
			/*
			var PostBlur = Fuse.FramebufferPool.Lock(dc.RenderTarget.Size/4, Uno.Graphics.Format.RGBA8888, false);
			dc.PushRenderTarget(PostBlur);
			dc.Clear(float4(0,0,0,0));
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv : ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(PostFullFrame.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();
			blur(dc, PostBlur, 1);
			//Bokeh(dc, PostBlur);
			//radial(dc, PostBlur);
			*/
			/*
			if(Glitch)
			{
				dc.Clear(float4(0,0,0,0));
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv : ClipPosition.XY * 0.5f + 0.5f;
					float tilt : Math.Sin(pixel uv.Y*Math.PIf);
					tilt : prev*prev;

					//float2 distruv : uv;
					/*
					float4 px : sample(PostFullFrame.ColorBuffer, float2(0.5f, uv.Y), Uno.Graphics.SamplerState.LinearWrap);
					float grey : (px.X+px.Y+px.Z)/3f;
					
					float distortValue : .5f;

					float2 distruv : ClipPosition.XY * 0.5f + 0.5f;
					distruv : 
							float2( 
								Math.Min(Math.Max(prev.X, grey * distortValue ), (grey+.5f+ (.5f-distortValue) ) )
								, prev.Y);
					*/		


					//float4 blurpx : sample(PostBlur.ColorBuffer, distruv, Uno.Graphics.SamplerState.LinearWrap);

					//PixelColor : sample(PostFullFrame.ColorBuffer, distruv, Uno.Graphics.SamplerState.LinearWrap) * tilt;
					//PixelColor : prev + 
					//blurpx * (1f-tilt);

					//float _depth : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).ZW);
					//float _weight : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalWeightBuffer.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).XY);
					//PixelColor : float4(_weight,_weight,_weight,1f);

					//PixelColor : float4(prev.XYZ + blurpx.XYZ * Math.Min(3f, _depth*10f), 1f);
/*
					float VerticalDistort : 9f;//

					float4 px : sample(PostFullFrame.ColorBuffer, float2(0.5f, uv.Y), Uno.Graphics.SamplerState.LinearWrap);
					float grey : (px.X+px.Y+px.Z)/3f;

					float distortValue : .5f;

					float2 distruv : prev uv;
					distruv : 
							float2( 
								Math.Min(Math.Max(prev.X, grey * distortValue ), (grey+.5f+ (.5f-distortValue) ) )
								, prev.Y);

					float4 distrPx : sample(PostFullFrame.ColorBuffer, distruv, Uno.Graphics.SamplerState.LinearWrap);

					PixelColor : distrPx;

					float2 texMos : float2( 
						Math.Round(pixel uv.X*VerticalDistort - .01f)/VerticalDistort, 
						uv.Y //Math.Round(pixel TexCoord.Y*32f - .01f)/32f
						);
					float3 rectas : sample(PostFullFrame.ColorBuffer, texMos, Uno.Graphics.SamplerState.NearestWrap).XYZ;
					PixelColor : float4( (prev.XYZ + rectas) * .5f, prev.W);
					
				};
			}else{
				*/
				/*
				dc.Clear(float4(0,0,0,0));
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv : ClipPosition.XY * 0.5f + 0.5f;
					
					float4 px : sample(PostFullFrame.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);

					//float bluenoise : sample(import Texture2D("../Assets/bluenoise/1024_1024/LDR_RGBA_0.png"), px.XY, Uno.Graphics.SamplerState.LinearWrap).X;// * .1f;

					PixelColor : px;//float4(px.XYZ * bluenoise, 1f);
					
				};*/
			/*}*/
/*
			Fuse.FramebufferPool.Release(PostFullFrame);
*/			//Fuse.FramebufferPool.Release(PostBlur);



		}

/*
		private void Bokeh(DrawContext dc, framebuffer target)
		{
			//var SRC = Fuse.FramebufferPool.Lock(target.Size, target.Format, false);

			// draw color to source
			//dc.PushRenderTarget(SRC);
			//dc.Clear(float4(0,0,0,0), 1);
			//draw Fuse.Drawing.Primitives.Quad
			//{
			//	DepthTestEnabled: false;
			//	CullFace: Uno.Graphics.PolygonFace.None;
			//	float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
			//	PixelColor : sample(target.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				//PixelColor : prev * prev * 2f;
				//PixelColor : float4(Math.Round(prev.XYZ), 1f);
			//};
			//dc.PopRenderTarget();
			//

			int NUM_SAMPLES = 8;

			var px = float2(1f/(float)target.Size.X, 1f/(float)target.Size.Y);
			
			//VERTICAL
			var VerticalBlur = Fuse.FramebufferPool.Lock(target.Size, target.Format, false);
			dc.PushRenderTarget(VerticalBlur);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 screencoord :	ClipPosition.XY * 0.5f + 0.5f;
				
				float coc :	1f;//simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, screencoord, Uno.Graphics.SamplerState.LinearWrap).ZW);
				//coc : Math.Min(1f, prev * 8f);//1f-(prev*prev);//Math.Sin(prev*Math.PIf*2f);
				float coc : Math.Sin(pixel screencoord.Y*Math.PIf);
				coc : 1f-prev*prev;

				float invViewDims : 1f;
				float2 direction : coc * invViewDims * float2(Math.Cos(Math.PIf/2f), Math.Sin(Math.PIf/2)) * px;
				
		    	float2 uv : (ClipPosition.XY * 0.5f + 0.5f) + direction * 0.5f;

				float4 BlurPixelColor : {
					float4 finalColor = float4(0.0f);
		    		float blurAmount = 0.0f;
		    		for (int i = 0; i < NUM_SAMPLES; ++i)
				    {
				        float4 color = sample(SRC.ColorBuffer, uv + direction * i, Uno.Graphics.SamplerState.LinearWrap);
				        color *= color.W;
				        blurAmount += color.W; 
				        finalColor += color;
				    }
				    return (finalColor / blurAmount);
				};

				PixelColor : float4(BlurPixelColor.XYZ * coc, coc);
			};
			dc.PopRenderTarget();

			
			//DIAGONAL
			var DiagonalBlur = Fuse.FramebufferPool.Lock(target.Size, target.Format, false);
			dc.PushRenderTarget(DiagonalBlur);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 screencoord : ClipPosition.XY * 0.5f + 0.5f;
				
				float coc : sample(VerticalBlur.ColorBuffer, screencoord, Uno.Graphics.SamplerState.LinearWrap).W;
				//float coc :	1f;//-simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, screencoord, Uno.Graphics.SamplerState.LinearWrap).ZW);
				float invViewDims : 1f;
				float2 direction : coc * invViewDims * float2(Math.Cos(-Math.PIf/6f), Math.Sin(-Math.PIf/6f)) * px;
				
		    	float2 uv : (ClipPosition.XY * 0.5f + 0.5f) + direction * 0.5f;

				float4 BlurPixelColor : {
					float4 finalColor = float4(0.0f);
		    		float blurAmount = 0.0f;
		    		for (int i = 0; i < NUM_SAMPLES; ++i)
				    {
				        float4 color = sample(SRC.ColorBuffer, uv + direction * i, Uno.Graphics.SamplerState.LinearWrap);
				        color *= color.W;
				        blurAmount += color.W; 
				        finalColor += color;
				    }
				    return (finalColor / blurAmount);
				};

				PixelColor : float4(
					Math.Max(float3(0f), BlurPixelColor.XYZ * coc)
					 + 
					sample(VerticalBlur.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap).XYZ
					, coc);
			};
			dc.PopRenderTarget();
			
			//dc.PushRenderTarget(target);
			//dc.Clear(float4(0,0,0,0), 1);
			//draw Fuse.Drawing.Primitives.Quad
			//{
			//	DepthTestEnabled: false;
			//	CullFace: Uno.Graphics.PolygonFace.None;
			//	float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
			//	PixelColor : sample(DiagonalBlur.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			//};
			//dc.PopRenderTarget();
			//

			//Rhomboid 
			dc.PushRenderTarget(target);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 screencoord :	ClipPosition.XY * 0.5f + 0.5f;
				
				float coc1 : sample(VerticalBlur.ColorBuffer, screencoord, Uno.Graphics.SamplerState.LinearWrap).W;
				float invViewDims1 : 1f;
				float2 direction1 : coc1 * invViewDims1 * float2(Math.Cos(-Math.PIf/6f), Math.Sin(-Math.PIf/6f)) * px;
				float2 uv1 : (ClipPosition.XY * 0.5f + 0.5f) + direction1 * 0.5f;

				float4 BlurPixelColor1 : {
					float4 finalColor = float4(0.0f);
		    		float blurAmount = 0.0f;
		    		
					for (int i = 0; i < NUM_SAMPLES; ++i)
				    {
				        float4 color = sample(VerticalBlur.ColorBuffer, uv1 + direction1 * i, Uno.Graphics.SamplerState.LinearWrap);
				        color *= color.W;
				        blurAmount += color.W; 
				        finalColor += color;
				    }
				    return (finalColor / blurAmount);
				};

				float3 px1 : Math.Max(float3(0f), BlurPixelColor1.XYZ * coc1);


				
				float coc2 : sample(DiagonalBlur.ColorBuffer, screencoord, Uno.Graphics.SamplerState.LinearWrap).W;
				float invViewDims2 : 1f;
				float2 direction2 : coc2 * invViewDims2 * float2(Math.Cos(-5f*Math.PIf/6f), Math.Sin(-5f*Math.PIf/6f)) * px;
				float2 uv2 : (ClipPosition.XY * 0.5f + 0.5f) + direction2 * 0.5f;

				float4 BlurPixelColor2 : {
					float4 finalColor = float4(0.0f);
		    		float blurAmount = 0.0f;
		    		for (int i = 0; i < NUM_SAMPLES; ++i)
				    {
				        float4 color = sample(DiagonalBlur.ColorBuffer, uv2 + direction2 * i, Uno.Graphics.SamplerState.LinearWrap);
				        color *= color.W;
				        blurAmount += color.W; 
				        finalColor += color;
				    }
				    return (finalColor / blurAmount);
				};

				float3 px2 : Math.Max(float3(0f), BlurPixelColor2.XYZ * coc2);


				PixelColor : float4((px1 + px2) * 0.5f, 1f);

				
			};
			dc.PopRenderTarget();

			Fuse.FramebufferPool.Release(SRC);
			Fuse.FramebufferPool.Release(VerticalBlur);
			Fuse.FramebufferPool.Release(DiagonalBlur);
		}
*/
		
///*
		private void fxaa(DrawContext dc, framebuffer target)
		{

			
			var SRC = Fuse.FramebufferPool.Lock(target.Size, target.Format, false);

			// draw color to source
			dc.PushRenderTarget(SRC);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(target.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();

			
			dc.PushRenderTarget(target);
			dc.Clear(float4(0,0,0,0), 1);
			
			draw Fuse.Drawing.Primitives.Quad
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
				
			};
			dc.PopRenderTarget();
			

			Fuse.FramebufferPool.Release(SRC);


		}
		//*/
		

/*
		private PostBilateralGauss blurBil;
		private void blurBilateralGauss(DrawContext dc, framebuffer target, int Steps = 1)
		{
			if(blurBil == null)
			{
				blurBil = new simppafi.PostBilateralGauss(Steps);
			}

			var source = Fuse.FramebufferPool.Lock(target.Size, target.Format, false);
			dc.PushRenderTarget(source);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(target.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();

			blurBil.Process(dc, source, target);

			Fuse.FramebufferPool.Release(source);
		}
*/

		

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
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 sum : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) * 0.204164f * power.X;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f * power.X;
					sum : prev + sample(source.ColorBuffer, uv - offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f * power.X;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f * power.X;
					PixelColor : sum + sample(source.ColorBuffer, uv - offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f * power.X;
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 sum : sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) * 0.204164f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv - offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f * power.Y;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f * power.Y;
					PixelColor : sum + sample(offset.ColorBuffer, uv - offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f * power.Y;
				};
				dc.PopRenderTarget();

			}

			Fuse.FramebufferPool.Release(offset);
		}

/*
		private void blur16Bit(DrawContext dc, framebuffer source, int Steps = 1)
		{
			
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			// GAUSSIAN DOF
			var offsetX = float2(1f/(float)source.Size.X, 0);
			var offsetY = float2(0, 1f/(float)source.Size.Y);
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(offset);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 sam : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
					float2 sum : float2(	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
											simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.204164f;

					sam : sample(source.ColorBuffer, uv + offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap);
					sum : prev + float2(	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
										 	simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.304005f;
					
					sam : sample(source.ColorBuffer, uv - offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap);
					sum : prev + float2(	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
											simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.304005f;

					sam : sample(source.ColorBuffer, uv + offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap);
					sum : prev + float2(	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
											simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.093913f;
					
					sam : sample(source.ColorBuffer, uv - offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap);
					sum : prev + float2( 	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
											simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.093913f;
					
					PixelColor : float4(simppafi.Utils.BufferPacker.PackFloat16(sum.X), simppafi.Utils.BufferPacker.PackFloat16(sum.Y));


				};
				dc.PopRenderTarget();
				
				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					//float4 sum : sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) * 0.204164f;
					//sum : prev + sample(offset.ColorBuffer, uv + offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
					//sum : prev + sample(offset.ColorBuffer, uv - offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
					//sum : prev + sample(offset.ColorBuffer, uv + offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;
					//PixelColor : sum + sample(offset.ColorBuffer, uv - offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;

					float4 sam : sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
					float2 sum : float2(	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
											simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.204164f;

					sam : sample(offset.ColorBuffer, uv + offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap);
					sum : prev + float2(	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
										 	simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.304005f;
					
					sam : sample(offset.ColorBuffer, uv - offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap);
					sum : prev + float2(	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
											simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.304005f;

					sam : sample(offset.ColorBuffer, uv + offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap);
					sum : prev + float2(	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
											simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.093913f;
					
					sam : sample(offset.ColorBuffer, uv - offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap);
					sum : prev + float2( 	simppafi.Utils.BufferPacker.UnpackFloat16(sam.XY),
											simppafi.Utils.BufferPacker.UnpackFloat16(sam.ZW) ) * 0.093913f;
					
					PixelColor : float4(simppafi.Utils.BufferPacker.PackFloat16(sum.X), simppafi.Utils.BufferPacker.PackFloat16(sum.Y));


				};
				dc.PopRenderTarget();
				
			}

			Fuse.FramebufferPool.Release(offset);
			
		}
		*/

/*
		private void blur32Bit(DrawContext dc, framebuffer source, int Steps = 1)
		{
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			// GAUSSIAN
			var offsetX = float2(1f/(float)source.Size.X, 0);// * 2f;
			var offsetY = float2(0, 1f/(float)source.Size.Y);// * 2f;
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(offset);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float src1 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap));
					float src2 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv + offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap));
					float src3 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv - offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap));
					float src4 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv + offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap));
					float src5 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv - offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap));
					
					float sum : src1 * 0.204164f;
					sum : prev + src2 * 0.304005f;
					sum : prev + src3 * 0.304005f;
					sum : prev + src4 * 0.093913f;
					sum : prev + src5 * 0.093913f;

					PixelColor : simppafi.Utils.BufferPacker.PackFloat32(sum);
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float src1 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap));
					float src2 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv + offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap));
					float src3 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv - offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap));
					float src4 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv + offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap));
					float src5 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv - offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap));
					
					float sum : src1 * 0.204164f;
					sum : prev + src2 * 0.304005f;
					sum : prev + src3 * 0.304005f;
					sum : prev + src4 * 0.093913f;
					sum : prev + src5 * 0.093913f;

					PixelColor : simppafi.Utils.BufferPacker.PackFloat32(sum);
				};
				dc.PopRenderTarget();

			}

			Fuse.FramebufferPool.Release(offset);
		}
*/

/*
		private void blur32BitShadow(DrawContext dc, framebuffer source, int Steps = 1)
		{
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			// GAUSSIAN
			var offsetX = float2(1f/(float)source.Size.X, 0);// * 2f;
			var offsetY = float2(0, 1f/(float)source.Size.Y);// * 2f;
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(offset);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float src1 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap));

					float spread : 1f + src1*src1 * 200f;

					float src2 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv + offsetX * 1.407333f * spread, Uno.Graphics.SamplerState.LinearWrap));
					float src3 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv - offsetX * 1.407333f * spread, Uno.Graphics.SamplerState.LinearWrap));
					float src4 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv + offsetX * 3.294215f * spread, Uno.Graphics.SamplerState.LinearWrap));
					float src5 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(source.ColorBuffer, uv - offsetX * 3.294215f * spread, Uno.Graphics.SamplerState.LinearWrap));
					
					float sum : src1 * 0.204164f;
					sum : prev + src2 * 0.304005f;
					sum : prev + src3 * 0.304005f;
					sum : prev + src4 * 0.093913f;
					sum : prev + src5 * 0.093913f;

					PixelColor : simppafi.Utils.BufferPacker.PackFloat32(sum);
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float src1 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap));

					float spread : 1f + src1*src1 * 200f;

					float src2 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv + offsetY * 1.407333f * spread, Uno.Graphics.SamplerState.LinearWrap));
					float src3 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv - offsetY * 1.407333f * spread, Uno.Graphics.SamplerState.LinearWrap));
					float src4 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv + offsetY * 3.294215f * spread, Uno.Graphics.SamplerState.LinearWrap));
					float src5 : simppafi.Utils.BufferPacker.UnpackFloat32(sample(offset.ColorBuffer, uv - offsetY * 3.294215f * spread, Uno.Graphics.SamplerState.LinearWrap));
					
					float sum : src1 * 0.204164f;
					sum : prev + src2 * 0.304005f;
					sum : prev + src3 * 0.304005f;
					sum : prev + src4 * 0.093913f;
					sum : prev + src5 * 0.093913f;

					PixelColor : simppafi.Utils.BufferPacker.PackFloat32(sum);
				};
				dc.PopRenderTarget();

			}

			Fuse.FramebufferPool.Release(offset);
		}
		*/
/*
		private void blurAlpha(DrawContext dc, framebuffer source, int Steps = 1, float2 mul = float2(1,1))
		{
			var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);
			
			// GAUSSIAN DOF
			for(var i = 0; i < Steps; i++)
			{
				dc.PushRenderTarget(offset);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 px : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
					float alphaPow : px.W * px.W;
					float2 offsetX : float2(1f/(float)source.Size.X, 0) * alphaPow * mul.X;

					//float x : Uno.Math.Sin(Uno.Vector.Dot(prev uv, float2(12.9898f,78.233f))) * 43758.5453f;
					//float noise : -.5f + (x - Uno.Math.Floor(x)) * 2f;
					//float distr : noise*.01f * alphaPow;

					float3 sum : px.XYZ * 0.204164f;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap).XYZ * 0.304005f;
					sum : prev + sample(source.ColorBuffer, uv - offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap).XYZ * 0.304005f;
					sum : prev + sample(source.ColorBuffer, uv + offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).XYZ * 0.093913f;
					PixelColor : float4(sum + sample(source.ColorBuffer, uv - offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).XYZ * 0.093913f, px.W);
				};
				dc.PopRenderTarget();

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

					float4 px : sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
					float alphaPow : px.W * px.W;
					float2 offsetY : float2(0, 1f/(float)source.Size.Y) * alphaPow * mul.Y;

					//float x : Uno.Math.Sin(Uno.Vector.Dot(prev uv, float2(12.9898f,78.233f))) * 43758.5453f;
					//float noise : -.5f + (x - Uno.Math.Floor(x)) * 2f;
					//float distr : noise*.01f * alphaPow;

					float3 sum : px.XYZ * 0.204164f;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap).XYZ * 0.304005f;
					sum : prev + sample(offset.ColorBuffer, uv - offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap).XYZ * 0.304005f;
					sum : prev + sample(offset.ColorBuffer, uv + offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).XYZ * 0.093913f;
					PixelColor : float4(sum + sample(offset.ColorBuffer, uv - offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap).XYZ * 0.093913f, px.W);
				};
				dc.PopRenderTarget();

			}

			Fuse.FramebufferPool.Release(offset);
		}
*/
		/*
		private void radial(DrawContext dc, framebuffer source, bool addOrginal = false)
		{
			var radialSource = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);
			var radialTarget = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			dc.PushRenderTarget(radialSource);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();

			if(addOrginal)
			{
				postRadial.Process(dc, radialSource, radialTarget);

				dc.PushRenderTarget(source);
				dc.Clear(float4(0,0,0,0), 1);
				draw Fuse.Drawing.Primitives.Quad
				{
					DepthTestEnabled: false;
					CullFace: Uno.Graphics.PolygonFace.None;
					float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
					PixelColor : sample(radialSource.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) + sample(radialTarget.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
				};
				dc.PopRenderTarget();
			}else{
				postRadial.Process(dc, radialSource, source);
			}
			Fuse.FramebufferPool.Release(radialSource);
			Fuse.FramebufferPool.Release(radialTarget);
		}
		*/


		private void glow(DrawContext dc, framebuffer source, int Steps, int downScale, float2 mul = float2(1f,1f), float2 power = float2(1f,1f))
		{
			var glowSource = Fuse.FramebufferPool.Lock(source.Size/downScale, source.Format, false);
			var glowTarget = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

			dc.PushRenderTarget(glowSource);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();

			dc.PushRenderTarget(glowTarget);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();

			blur(dc, glowSource, Steps, mul, power);

			dc.PushRenderTarget(source);
			dc.Clear(float4(0,0,0,0), 1);
			draw Fuse.Drawing.Primitives.Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				float2 uv :	ClipPosition.XY * 0.5f + 0.5f;
				PixelColor : sample(glowSource.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) + sample(glowTarget.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap);
			};
			dc.PopRenderTarget();

			Fuse.FramebufferPool.Release(glowSource);
			Fuse.FramebufferPool.Release(glowTarget);
		}

		

	}
}