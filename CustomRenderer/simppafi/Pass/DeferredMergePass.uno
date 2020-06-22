using Uno;
namespace simppafi
{
	public class DeferredMergePass : BasePass
	{
		DepthTestEnabled: false;
		CullFace: Uno.Graphics.PolygonFace.None;

		float3 ambient : float3(.05f);


		//float2 ScreenUV :
		//		req(ClipPosition as float4)
		//			pixel ClipPosition.XY / ClipPosition.W * 0.5f + 0.5f;

		///*
		// TRANSPARENCY
		//float4 trans : sample(simppafi.FramebufferStorage.GlobalTransparencyBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.LinearWrap);

		//float4 lightSources : sample(simppafi.FramebufferStorage.GlobalLightSourcesBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.LinearWrap);
		
		apply simppafi.RenderLibrary.FXDeferred;
		float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

		//float bluenoise_uv : sample(import Uno.Graphics.Texture2D("../../Assets/bluenoise/1024_1024/LDR_RGBA_0.png"), (pixel ClipPosition.XY / ClipPosition.W * 0.5f + 0.5f)*2f, Uno.Graphics.SamplerState.LinearWrap).Y;
		
		float2 ScreenUV : pixel ClipPosition.XY / ClipPosition.W * 0.5f + 0.5f;//distruv;
		//ScreenUV : float2(prev.X, prev.Y+bluenoise_uv*_depth*.1f);


		// LIGHTS AND MATERIALS
		float4 FXDeferredFinal : sample(FramebufferStorage.GlobalDeferredFinalBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.LinearWrap);
		float3 lights : FXDeferredFinal.XYZ;
		PixelColor : float4(lights,1f);

		// SSR
		///*
		float3 ssr : sample(simppafi.FramebufferStorage.GlobalSSRBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.LinearWrap).XYZ;
		PixelColor : 
		float4(prev.XYZ + ssr.XYZ, prev.W);
		
		
		//SHADOWS
		///*
		float3 sssao : sample(simppafi.FramebufferStorage.GlobalSSSAOBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.LinearWrap).XYZ;
		PixelColor : 
			float4(prev.XYZ * 
				(1f-sssao), prev.W);
		//*/
		

		// NOISE MIX EVERYTHING
		//float4 px : prev PixelColor;
		//float bluenoise : bluenoise_uv;
		//PixelColor : float4(px.XYZ * (0.75f + bluenoise * .75f), 1f);

		
		//SSAO
		apply simppafi.RenderLibrary.FXSSAO;
		PixelColor : float4(prev.XYZ * float3(FXSSAO), 1f);


		// GLOW
		float3 glow : sample(simppafi.FramebufferStorage.GlobalGlowBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.LinearWrap).XYZ;
		//PixelColor : float4(prev.XYZ + (glow.XYZ * float3( Math.Min(1f, FXSSAO+.6f)) ), prev.W);
		PixelColor : float4(prev.XYZ + glow.XYZ, prev.W);

		
		//float mix_depth : sample(import Uno.Graphics.Texture2D("../../Assets/bluenoise/1024_1024/LDR_RGBA_0.png"), ScreenUV * (1f + _depth*2f), Uno.Graphics.SamplerState.NearestWrap).Y;

		//PixelColor : float4(prev.XYZ + float3(.8f*_depth, .9f*_depth, _depth)*bluenoise, prev.W);
		
		float mix_depth : sample(import Uno.Graphics.Texture2D("../../Assets/bluenoise/1024_1024/LDR_RGBA_0.png"), ScreenUV * 3f, Uno.Graphics.SamplerState.NearestWrap).Y;

		float3 depthFog : CustomRenderNode.peakPower * Math.Min(1f, _depth * (3f + (3f-6f * CustomRenderNode.peakPower))) * CustomRenderNode.FogColor * (1f-mix_depth*.3f * FXSSAO);

		// LENS GLOW
		float4 lensGlow : sample(simppafi.FramebufferStorage.GlobalLensGlowBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.LinearWrap);
		PixelColor : float4(prev.XYZ + lensGlow.XYZ*.25f + depthFog, 1f);
		


		//float weight : simppafi.Utils.BufferPacker.UnpackFloat16(sample(simppafi.FramebufferStorage.GlobalWeightBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).XY);
		//apply simppafi.RenderLibrary.FXDeferred;
		//float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);
		//float fat : (weight-_depth) * 100f;
		//PixelColor : float4(_depth,_depth,_depth,1);



		//float4 mrao : sample(simppafi.FramebufferStorage.GlobalMRAOBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		//PixelColor : mrao;
		//float4 _albedo : sample(simppafi.FramebufferStorage.GlobalAlbedoBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		//PixelColor : _albedo;

		///*
		//float4 material : sample(simppafi.FramebufferStorage.GlobalMaterialBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		//PixelColor : material + float4(ssr, 0);
		//*/

		/*
		apply simppafi.RenderLibrary.FXDeferred;

		float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

		PixelColor : float4(_depth,_depth,_depth,1);
//*/
	///*
		
		//float4 silhuette : sample(FramebufferStorage.GlobalSilhuetteBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		//PixelColor : prev + silhuette;	

		/*
		apply simppafi.RenderLibrary.FXDeferred;

		float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

		PixelColor : float4(_depth,_depth,_depth,1);
		*/

		//float4 ssao : sample(simppafi.FramebufferStorage.GlobalSSAOBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		//PixelColor : float4(prev.XYZ * ssao.XYZ, 1f);
		
		
		// FOG
		//apply simppafi.RenderLibrary.FXDeferred;
		//float fogDepth : simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);
		//fogDepth : 1f+Math.Clamp(prev*5f, 0f, 1f);
		//PixelColor : prev * float4(fogDepth,fogDepth,fogDepth,0f);

		///*
		// ADD TRANSPARENCY
		//PixelColor : float4(prev.XYZ + trans.XYZ*.1f, 1f);


		//float4 edges : sample(simppafi.FramebufferStorage.GlobalEdgesBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.TrilinearWrap);
		//PixelColor: float4(prev.XYZ + edges.XYZ, 1f);

		// ADD LIGHT SOURCES
		//PixelColor : float4(prev.XYZ + lightSources.XYZ, 1f);



		///*
		/*
		float2 ScaleScreenUV :
				req(ClipPosition as float4)
					pixel ClipPosition.XY / ClipPosition.W * float2(1f,.125f) + 0.5f;
		float4 lensGlowScale : sample(simppafi.FramebufferStorage.GlobalLensGlowBuffer.ColorBuffer, float2(1f-ScaleScreenUV.X,1f-ScaleScreenUV.Y), Uno.Graphics.SamplerState.LinearWrap);

		//PixelColor : float4(prev.XYZ + float3(0,0,(lensGlowScale.X+lensGlowScale.Y+lensGlowScale.Z) / 3f) * .75f, 1f);

		PixelColor : float4(prev.XYZ + lensGlowScale.XYZ * float3(0.1f, 0.1f, .75f), 1f);
		//*/



		//*/

		/*
		apply simppafi.RenderLibrary.FXDeferredFinal;

		float3 lights : FXDeferredFinal.XYZ;
		 
		PixelColor : float4(
								prev.XYZ * ambientLight + 
								prev.XYZ * lights * (float3(1f)-ambientLight)
								// + trans.XYZ * lights
								, 1f);


		// SSR
		//apply simppafi.SSRPass;
		//PixelColor : prev + float4(ReflectPixel, 0);
		float3 ssr : sample(simppafi.FramebufferStorage.GlobalSSRBuffer.ColorBuffer, ScreenUV, Uno.Graphics.SamplerState.LinearWrap).XYZ;
		PixelColor : prev + float4(ssr, 0);
		//*/

		//float _depth : simppafi.Utils.BufferPacker.UnpackFloat32(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap));
		//PixelColor : float4(_depth,_depth,_depth,1);

	}
}