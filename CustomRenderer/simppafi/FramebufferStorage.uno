using Uno;
using Uno.Collections;
using Fuse;
using Uno.Graphics;
using simppafi.Utils.Size;

namespace simppafi
{
	public static class FramebufferStorage
	{
		public static bool			RenderPost = false;
		public static bool			RenderDepth = false;
		public static bool 			RenderMask = false;
		public static bool			RenderModifie = false;
		public static bool			RenderNormal = false;
		public static bool			RenderUV = false;
		public static bool			RenderDeferred = false;
		public static bool			RenderReflect = false;
		public static bool			RenderMotion = false;
		public static bool			RenderCache = false;
		public static bool			RenderShadow = false;
		//public static bool			RenderShadowMapAtlas = false;
		public static bool			RenderTransparency = false;
		public static bool			RenderSSAO = false;
		public static bool 			RenderLightSources = false;
		public static bool 			RenderEdges = false;
		public static bool 			RenderLensGlow = false;
		public static bool 			RenderSSR = false;
		public static bool 			RenderAlbedo = false;
		public static bool 			RenderSilhuette = false;
		public static bool 			RenderMRAO = false;
		public static bool 			RenderSSSAO = false;
		public static bool 			RenderWeight = false;
		public static bool 			RenderGlow = false;
		
		public static float			ResolutionPost = 1f;
		public static float			ResolutionDepth = 1f;
		public static float			ResolutionMask = 1f;
		public static float			ResolutionModifie = 1f;
		public static float			ResolutionDeferred = 1f;
		public static float			ResolutionDeferredFinal = 1f;
		public static float			ResolutionNormal = 1f;
		public static float			ResolutionUV = 1f;
		public static float			ResolutionReflect = 1f;
		public static float			ResolutionMotion = 1f;
		//public static float			ResolutionShadow = 1f;
		//public static float 		ResolutionShadowMapAtlas = 1f;
		public static float			ResolutionTransparency = 1f;
		public static float			ResolutionSSAO = 1f;
		public static float 		ResolutionLightSources = 1f;
		public static float 		ResolutionEdges = 1f;
		public static float 		ResolutionLensGlow = 1f;
		public static float 		ResolutionSSR = 1f;
		public static float 		ResolutionAlbedo = 1f;
		public static float 		ResolutionSilhuette = 1f;
		public static float 		ResolutionMRAO = 1f;
		public static float 		ResolutionSSSAO = 1f;
		public static float 		ResolutionWeight = 1f;
		public static float 		ResolutionGlow = 1f;


		public static framebuffer	GlobalPostBuffer;
		public static framebuffer	GlobalPostBufferSource;
		public static framebuffer	GlobalDepthBuffer;
		public static framebuffer	GlobalMaskBuffer;
		public static framebuffer	GlobalModifieBuffer;
		public static framebuffer	GlobalDeferredBuffer;
		public static framebuffer	GlobalDeferredFinalBuffer;
		public static framebuffer	GlobalNormalBuffer;
		public static framebuffer	GlobalUVBuffer;
		public static framebuffer	GlobalReflectBuffer;
		public static framebuffer	GlobalMotionBuffer;
		public static framebuffer	GlobalCacheBuffer;
		//public static framebuffer	GlobalShadowBuffer;
		//public static framebuffer	GlobalShadowMapAtlasBuffer;
		public static framebuffer	GlobalTransparencyBuffer;
		public static framebuffer	GlobalSSAOBuffer;
		public static framebuffer	GlobalLightSourcesBuffer;
		public static framebuffer	GlobalEdgesBuffer;
		public static framebuffer	GlobalLensGlowBuffer;
		public static framebuffer	GlobalSSRBuffer;
		public static framebuffer	GlobalAlbedoBuffer;
		public static framebuffer	GlobalSilhuetteBuffer;
		public static framebuffer	GlobalMRAOBuffer;
		public static framebuffer	GlobalSSSAOBuffer;
		public static framebuffer	GlobalWeightBuffer;
		public static framebuffer	GlobalGlowBuffer;

		private static int2			GlobalPostBuffer_Size = int2(2,2);
		private static int2			GlobalDepthBuffer_Size = int2(2,2);
		private static int2			GlobalMaskBuffer_Size = int2(2,2);
		private static int2			GlobalModifieBuffer_Size = int2(2,2);
		private static int2			GlobalDeferredBuffer_Size = int2(2,2);
		private static int2			GlobalDeferredFinalBuffer_Size = int2(2,2);
		private static int2			GlobalNormalBuffer_Size = int2(2,2);
		private static int2			GlobalUVBuffer_Size = int2(2,2);
		private static int2			GlobalReflectBuffer_Size = int2(2,2);
		private static int2			GlobalMotionBuffer_Size = int2(2,2);
		private static int2			GlobalCacheBuffer_Size = int2(2,2);
		//private static int2			GlobalShadowBuffer_Size = int2(2,2);
		//private static int2			GlobalShadowMapAtlasBuffer_Size = int2(2,2);
		private static int2			GlobalTransparencyBuffer_Size = int2(2,2);
		private static int2			GlobalSSAOBuffer_Size = int2(2,2);
		private static int2			GlobalLightSourcesBuffer_Size = int2(2,2);
		private static int2			GlobalEdgesBuffer_Size = int2(2,2);
		private static int2			GlobalLensGlowBuffer_Size = int2(2,2);
		private static int2			GlobalSSRBuffer_Size = int2(2,2);
		private static int2			GlobalAlbedoBuffer_Size = int2(2,2);
		private static int2			GlobalSilhuetteBuffer_Size = int2(2,2);
		private static int2			GlobalMRAOBuffer_Size = int2(2,2);
		private static int2			GlobalSSSAOBuffer_Size = int2(2,2);
		private static int2			GlobalWeightBuffer_Size = int2(2,2);
		private static int2			GlobalGlowBuffer_Size = int2(2,2);

		public static void Clear()
		{
			RenderPost = false;
			RenderDepth = false;
			RenderMask = false;
			RenderModifie = false;
			RenderNormal = false;
			RenderUV = false;
			RenderDeferred = false;
			RenderReflect = false;
			RenderMotion = false;
			RenderCache = false;
			RenderShadow = false;
			//RenderShadowMapAtlas = false;
			RenderTransparency = false;
			RenderSSAO = false;
			RenderLightSources = false;
			RenderEdges = false;
			RenderLensGlow = false;
			RenderSSR = false;
			RenderAlbedo = false;
			RenderSilhuette = false;
			RenderMRAO = false;
			RenderSSSAO = false;
			RenderWeight = false;
			RenderGlow = false;
		}
		
		public static void AllOn()
		{
			RenderPost = true;
			RenderDepth = true;
			RenderMask = true;
			RenderModifie = true;
			RenderNormal = true;
			RenderUV = true;
			RenderDeferred = true;
			RenderReflect = true;
			RenderMotion = true;
			RenderCache = true;
			RenderShadow = true;
			//RenderShadowMapAtlas = false;
			RenderTransparency = true;
			RenderSSAO = true;
			RenderLightSources = true;	
			RenderEdges = true;
			RenderLensGlow = true;
			RenderSSR = true;
			RenderAlbedo = true;
			RenderSilhuette = true;
			RenderMRAO = true;
			RenderSSSAO = true;
			RenderWeight = true;
			RenderGlow = true;
		}

		public static void ResizePost(int2 size)
		{
			if(GlobalPostBuffer != null) { GlobalPostBuffer.Dispose(); GlobalPostBuffer = null; }
			GlobalPostBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalPostBuffer_Size = size;

			if(GlobalPostBufferSource != null) { GlobalPostBufferSource.Dispose(); GlobalPostBufferSource = null; }
			GlobalPostBufferSource = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
		}

		public static void ResizeDepth(int2 size)
		{
			if(GlobalDepthBuffer != null) { GlobalDepthBuffer.Dispose(); GlobalDepthBuffer = null; }
			GlobalDepthBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalDepthBuffer_Size = size;
		}

		public static void ResizeMask(int2 size)
		{
			if(GlobalMaskBuffer != null) { GlobalMaskBuffer.Dispose(); GlobalMaskBuffer = null; }
			GlobalMaskBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalMaskBuffer_Size = size;
		}

		public static void ResizeModifie(int2 size)
		{
			if(GlobalModifieBuffer != null) { GlobalModifieBuffer.Dispose(); GlobalModifieBuffer = null; }
			GlobalModifieBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalModifieBuffer_Size = size;
		}

		public static void ResizeDeferred(int2 size)
		{
			if(GlobalDeferredBuffer!= null) { GlobalDeferredBuffer.Dispose(); GlobalDeferredBuffer = null; }
			GlobalDeferredBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalDeferredBuffer_Size = size;
		}

		public static void ResizeDeferredFinal(int2 size)
		{
			if(GlobalDeferredFinalBuffer!= null) { GlobalDeferredFinalBuffer.Dispose(); GlobalDeferredFinalBuffer = null; }
			GlobalDeferredFinalBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalDeferredFinalBuffer_Size = size;
		}

		public static void ResizeNormal(int2 size)
		{
			if(GlobalNormalBuffer!= null) { GlobalNormalBuffer.Dispose(); GlobalNormalBuffer = null; }
			GlobalNormalBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalNormalBuffer_Size = size;
		}

		public static void ResizeUV(int2 size)
		{
			if(GlobalUVBuffer!= null) { GlobalUVBuffer.Dispose(); GlobalUVBuffer = null; }
			GlobalUVBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalUVBuffer_Size = size;
		}

		public static void ResizeReflect(int2 size)
		{
			if(GlobalReflectBuffer != null) { GlobalReflectBuffer.Dispose(); GlobalReflectBuffer = null; }
			GlobalReflectBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalReflectBuffer_Size = size;
		}

		public static void ResizeMotion(int2 size)
		{
			if(GlobalMotionBuffer != null) { GlobalMotionBuffer.Dispose(); GlobalMotionBuffer = null; }
			GlobalMotionBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.None);
			GlobalMotionBuffer_Size = size;
		}

		public static void ResizeCache(int2 size)
		{
			if(GlobalCacheBuffer != null) { GlobalCacheBuffer.Dispose(); GlobalCacheBuffer = null; }
			GlobalCacheBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalCacheBuffer_Size = size;
		}

		/*public static void ResizeShadow(int2 size)
		{
			if(GlobalShadowBuffer != null) { GlobalShadowBuffer.Dispose(); GlobalShadowBuffer = null; }
			GlobalShadowBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalShadowBuffer_Size = size;
		}*/

		/*public static void ResizeShadowMapAtlas(int2 size)
		{
			if(GlobalShadowMapAtlasBuffer != null) { GlobalShadowMapAtlasBuffer.Dispose(); GlobalShadowMapAtlasBuffer = null; }
			GlobalShadowMapAtlasBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.None);
			GlobalShadowMapAtlasBuffer_Size = size;
		}*/

		public static void ResizeTransparency(int2 size)
		{
			if(GlobalTransparencyBuffer != null) { GlobalTransparencyBuffer.Dispose(); GlobalTransparencyBuffer = null; }
			GlobalTransparencyBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalTransparencyBuffer_Size = size;
		}

		public static void ResizeSSAO(int2 size)
		{
			if(GlobalSSAOBuffer != null) { GlobalSSAOBuffer.Dispose(); GlobalSSAOBuffer = null; }
			GlobalSSAOBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalSSAOBuffer_Size = size;
		}

		public static void ResizeLightSources(int2 size)
		{
			if(GlobalLightSourcesBuffer != null) { GlobalLightSourcesBuffer.Dispose(); GlobalLightSourcesBuffer = null; }
			GlobalLightSourcesBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalLightSourcesBuffer_Size = size;
		}

		public static void ResizeEdges(int2 size)
		{
			if(GlobalEdgesBuffer != null) { GlobalEdgesBuffer.Dispose(); GlobalEdgesBuffer = null; }
			GlobalEdgesBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalEdgesBuffer_Size = size;
		}

		public static void ResizeLensGlow(int2 size)
		{
			if(GlobalLensGlowBuffer != null) { GlobalLensGlowBuffer.Dispose(); GlobalLensGlowBuffer = null; }
			GlobalLensGlowBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalLensGlowBuffer_Size = size;
		}

		public static void ResizeSSR(int2 size)
		{
			if(GlobalSSRBuffer != null) { GlobalSSRBuffer.Dispose(); GlobalSSRBuffer = null; }
			GlobalSSRBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalSSRBuffer_Size = size;
		}

		public static void ResizeAlbedo(int2 size)
		{
			if(GlobalAlbedoBuffer != null) { GlobalAlbedoBuffer.Dispose(); GlobalAlbedoBuffer = null; }
			GlobalAlbedoBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalAlbedoBuffer_Size = size;
		}

		public static void ResizeSilhuette(int2 size)
		{
			if(GlobalSilhuetteBuffer != null) { GlobalSilhuetteBuffer.Dispose(); GlobalSilhuetteBuffer = null; }
			GlobalSilhuetteBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalSilhuetteBuffer_Size = size;
		}

		public static void ResizeMRAO(int2 size)
		{
			if(GlobalMRAOBuffer != null) { GlobalMRAOBuffer.Dispose(); GlobalMRAOBuffer = null; }
			GlobalMRAOBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalMRAOBuffer_Size = size;
		}

		public static void ResizeSSSAO(int2 size)
		{
			if(GlobalSSSAOBuffer != null) { GlobalSSSAOBuffer.Dispose(); GlobalSSSAOBuffer = null; }
			GlobalSSSAOBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalSSSAOBuffer_Size = size;
		}

		public static void ResizeWeight(int2 size)
		{
			if(GlobalWeightBuffer != null) { GlobalWeightBuffer.Dispose(); GlobalWeightBuffer = null; }
			GlobalWeightBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalWeightBuffer_Size = size;
		}

		public static void ResizeGlow(int2 size)
		{
			if(GlobalGlowBuffer != null) { GlobalGlowBuffer.Dispose(); GlobalGlowBuffer = null; }
			GlobalGlowBuffer = new framebuffer(size, Uno.Graphics.Format.RGBA8888, FramebufferFlags.DepthBuffer);
			GlobalGlowBuffer_Size = size;
		}



		public static bool Resize(DrawContext dc)
		{
			bool changed = false;

			int2 _size;
			if(RenderPost)
			{
				_size = GetSize(ResolutionPost, dc);
				if(_size != GlobalPostBuffer_Size)
				{
					ResizePost(_size);
					changed = true;
				}
			}

			if(RenderDepth)
			{
				_size = GetSize(ResolutionDepth, dc);
				if(_size != GlobalDepthBuffer_Size)
				{
					ResizeDepth(_size);
					changed = true;
				}
			}

			if(RenderMask)
			{
				_size = GetSize(ResolutionMask, dc);
				if(_size != GlobalMaskBuffer_Size)
				{
					ResizeMask(_size);
					changed = true;
				}
			}

			if(RenderModifie)
			{
				_size = GetSize(ResolutionModifie, dc);
				if(_size != GlobalModifieBuffer_Size)
				{
					ResizeModifie(_size);
					changed = true;
				}
			}

			if(RenderDeferred)
			{
				_size = GetSize(ResolutionDeferred, dc);
				if(_size != GlobalDeferredBuffer_Size)
				{
					ResizeDeferred(_size);
					changed = true;
				}
				_size = GetSize(ResolutionDeferredFinal, dc);
				if(_size != GlobalDeferredFinalBuffer_Size)
				{
					ResizeDeferredFinal(_size);
					changed = true;
				}
			}

			if(RenderNormal)
			{
				_size = GetSize(ResolutionNormal, dc);
				if(_size != GlobalNormalBuffer_Size)
				{
					ResizeNormal(_size);
					changed = true;
				}
			}

			if(RenderUV)
			{
				_size = GetSize(ResolutionUV, dc);
				if(_size != GlobalUVBuffer_Size)
				{
					ResizeUV(_size);
					changed = true;
				}
			}

			if(RenderReflect)
			{
				_size = GetSize(ResolutionReflect, dc);
				if(_size != GlobalReflectBuffer_Size)
				{
					ResizeReflect(_size);
					changed = true;
				}
			}

			if(RenderMotion)
			{
				_size = GetSize(ResolutionMotion, dc);
				if(_size != GlobalMotionBuffer_Size)
				{
					ResizeMotion(_size);
					changed = true;
				}
			}

			if(RenderCache)
			{
				_size = GetSize(1f, dc);
				if(_size != GlobalCacheBuffer_Size)
				{
					ResizeCache(_size);
					changed = true;
				}
			}

			if(RenderTransparency)
			{
				_size = GetSize(ResolutionTransparency, dc);
				if(_size != GlobalTransparencyBuffer_Size)
				{
					ResizeTransparency(_size);
					changed = true;
				}
			}

			if(RenderSSAO)
			{
				_size = GetSize(ResolutionSSAO, dc);
				if(_size != GlobalSSAOBuffer_Size)
				{
					ResizeSSAO(_size);
					changed = true;
				}
			}

			if(RenderLightSources)
			{
				_size = GetSize(ResolutionLightSources, dc);
				if(_size != GlobalLightSourcesBuffer_Size)
				{
					ResizeLightSources(_size);
					changed = true;
				}
			}

			if(RenderEdges)
			{
				_size = GetSize(ResolutionEdges, dc);
				if(_size != GlobalEdgesBuffer_Size)
				{
					ResizeEdges(_size);
					changed = true;
				}
			}

			if(RenderLensGlow)
			{
				_size = GetSize(ResolutionLensGlow, dc);
				if(_size != GlobalLensGlowBuffer_Size)
				{
					ResizeLensGlow(_size);
					changed = true;
				}
			}

			if(RenderSSR)
			{
				_size = GetSize(ResolutionSSR, dc);
				if(_size != GlobalSSRBuffer_Size)
				{
					ResizeSSR(_size);
					changed = true;
				}
			}

			if(RenderAlbedo)
			{
				_size = GetSize(ResolutionAlbedo, dc);
				if(_size != GlobalAlbedoBuffer_Size)
				{
					ResizeAlbedo(_size);
					changed = true;
				}
			}

			if(RenderSilhuette)
			{
				_size = GetSize(ResolutionSilhuette, dc);
				if(_size != GlobalSilhuetteBuffer_Size)
				{
					ResizeSilhuette(_size);
					changed = true;
				}
			}

			if(RenderMRAO)
			{
				_size = GetSize(ResolutionMRAO, dc);
				if(_size != GlobalMRAOBuffer_Size)
				{
					ResizeMRAO(_size);
					changed = true;
				}
			}

			if(RenderSSSAO)
			{
				_size = GetSize(ResolutionSSSAO, dc);
				if(_size != GlobalSSSAOBuffer_Size)
				{
					ResizeSSSAO(_size);
					changed = true;
				}
			}

			if(RenderWeight)
			{
				_size = GetSize(ResolutionWeight, dc);
				if(_size != GlobalWeightBuffer_Size)
				{
					ResizeWeight(_size);
					changed = true;
				}
			}

			if(RenderGlow)
			{
				_size = GetSize(ResolutionGlow, dc);
				if(_size != GlobalGlowBuffer_Size)
				{
					ResizeGlow(_size);
					changed = true;
				}
			}
			

			return changed;

		}
	}
}
