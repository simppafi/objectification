using Uno;
using Uno.Math;
using Uno.Vector;

namespace simppafi
{
	public class RenderLibrary
	{
		public block ValuePixelOnScreen
		{
			float2 ValuePixelOnScreen :
				req(ClipPosition as float4)
					pixel ClipPosition.XY / ClipPosition.W * 0.5f + 0.5f;
		}

		/*public block Mirror 
		{
			ClipPosition:
				req(WorldPosition as float3)
					simppafi.RenderPipeline.IsMirror ? Uno.Vector.Transform(float4(WorldPosition,1), EnvMirror.mirrorMatrix) : prev;
		}*/

		public block GammaCorrection
		{
			PixelColor : float4(Math.Sqrt(prev.XYZ), prev.W);
		}

		public block Fog
		{
			float4 fogColor : float4(0.44f,0.67f,.66f,1);

			float minFogHeight : 2f;
			float maxFogHeight : 10f;

			float fogFactor : 
				req(WorldPosition as float3)
						1.0f - Math.Clamp((WorldPosition.Y - minFogHeight) / (maxFogHeight - minFogHeight), 0.0f, 1.0f);

			PixelColor : Math.Lerp( prev*fogColor, fogColor, fogFactor ) * fogFactor;
		}

		public block MRAO
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float4 MRAO : sample(FramebufferStorage.GlobalMRAOBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
			float metallic : MRAO.X;
			float roughness : MRAO.Y;
			float ao : MRAO.Z;
		}

		public block FXPost
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float4 FXPost :
				req(PostFramebuffer as framebuffer)
					sample(PostFramebuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		}

		public block FXGlobalPost
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float4 FXGlobalPost : sample(FramebufferStorage.GlobalPostBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		}

		public block PXMask
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float Mask : sample(FramebufferStorage.GlobalMaskBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).X;
		}

		public block FXMask
		{
			apply simppafi.RenderLibrary.PXMask;
			
			//float Move : -Uno.Math.Pow( 2.0f, -10.0f * ease ) + 1.0f;
			//float ease : Uno.Math.Pow(2.0f, (10.0f * (mv*.25f - 1.0f))) - 0.001f;

			//float maskdiff : 
			//	req(MaskColor as float)
			//		Math.Max(0, Math.Abs(Mask-MaskColor) * 10f);

			//float maskease : maskdiff;//-Uno.Math.Pow( 2.0f, -10.0f * maskdiff ) + 1.0f;
			//float maskease :  Uno.Math.Pow(2.0f, (10.0f * (maskdiff*.25f - 1.0f))) - 0.001f;

			PixelColor :
				req(MaskColor as float)
					//Math.Abs(Mask-MaskColor) < .01f ? prev : float4(0,0,0,0);
					prev * (1f-Math.Max(0, Math.Abs(Mask-MaskColor) * 10f));
		}

		public block FXDeferred
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float4 FXDeferred : sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		}

		public block FXDeferredFinal
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float4 FXDeferredFinal : sample(FramebufferStorage.GlobalDeferredFinalBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		}


		public block GlobalDepthLinear
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float GlobalDepthLinear : simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).ZW);
			
		}

		public block NearCorners
		{
			float4x4 NearCorners : BasePass.NearCorners;
		}

		public block FarCorners
		{
			float4x4 FarCorners : BasePass.FarCorners;
		}

		public block FXLiquid
		{
			apply simppafi.RenderLibrary.FXPost;

			public texture2D SphereMap 	: import Uno.Graphics.Texture2D("../Assets/SphereMap2.jpg");

			//public float4 LiquidBg : float4(0,0,0,1);

			float4 FXLiquid :
			{
				//if(FXPost.W > 0.6f)
				//{
					float3 samp = sample(SphereMap, FXPost.XY).XYZ;
					float3 col = samp * samp;
					float4 px = float4(col, 1);// * Math.Min(1f, (FXPost.W-.6f)*30f), 1);
				//}else{
				//	return LiquidBg;
				//}

				return px;//LiquidBg + (px * LiquidBg) * 
			};
		}

		public block FXSSAO
		{
			///*
			float Multiplier 		: 2.65f;
			float Exponent 			: 18.0f;
			float Bias				: 0.01f;
			float Eps 				: 0.01f;
			float Radius 			: 12.0f;
			float MaxScreenRadius 	: 0.1f;
			float RandomizationFactor : .5f;
			//*/
			/*
			float Multiplier 		: 4.65f; // DARKEN
			float Exponent 			: 18.0f; // DARKEN2
			float Bias				: 0.01f; // CUTOUT
			float Eps 				: 0.01f; // ??
			float Radius 			: 8.0f;
			float MaxScreenRadius 	: 13.1f;
			float RandomizationFactor : .5f;
			*/
			
			Uno.Graphics.SamplerState samplerState : Uno.Graphics.SamplerState.LinearWrap;

			apply simppafi.RenderLibrary.NearCorners;
			apply simppafi.RenderLibrary.FarCorners;
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			apply simppafi.RenderLibrary.FXDeferred;
			
			float2 ScreenCoord : ValuePixelOnScreen;
			float2 ScreenSize : float2(BasePass.dcViewportSize.X, BasePass.dcViewportSize.Y);
			float2 PixelCoord2 : ScreenCoord * ScreenSize;
			float2 AspectScale : float2(1.0f, BasePass.dcRatio);

			//float4 Data : sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ScreenCoord, samplerState);
			float4 Data : FXDeferred;
			//float Depth : simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

			float3 ViewPosition_ : simppafi.Utils.BufferData.ReadViewPosition(Data, ScreenCoord, NearCorners, FarCorners);

			float3 ViewNormal : simppafi.Utils.BufferPacker.UnpackNormal(FXDeferred.XY);

			//float3 ViewNormal : simppafi.Utils.BufferData.ReadViewNormal(Data);

			float ScreenRadius : Math.Min(MaxScreenRadius, Radius / -ViewPosition_.Z);


			

			float FXSSAO :
				{
					const float oneOverSampleCount = 1.0f / 9.0f;
					const float twoOverSampleCount = oneOverSampleCount * 2.0f;

		       		float angularOffset = RandomizationFactor * Dot(PixelCoord2, float2(2.3734372915f, 3.58540627421f));

					float ao = 0.0f;
					for (int i = 0; i<9; i++)
					{
						///*
						float alpha = oneOverSampleCount * ((float)i + 0.5f);
						float theta = 2.0f * Math.PIf * alpha + angularOffset;
						var dir = float2(Cos(theta), Sin(theta));
						float2 spiral = dir * alpha;
						float2 sampleCoord = ScreenCoord + (spiral * ScreenRadius) * AspectScale;
						//*/
						//float alpha = oneOverSampleCount * ((float)i + 0.5f);
						//float2 sampleCoord = ScreenCoord + (AspectScale * ScreenRadius * alpha * (-.5f+sample(import Uno.Graphics.Texture2D("../Assets/bluenoise/1024_1024/LDR_RGBA_0.png"), ScreenCoord, Uno.Graphics.SamplerState.NearestWrap).XY) );
						//float4 data = sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, sampleCoord, samplerState);
						float4 data = sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, sampleCoord, samplerState);

						float3 viewSample =  simppafi.Utils.BufferData.ReadViewPosition(data, sampleCoord, NearCorners, FarCorners);
						float3 v_i = (viewSample - ViewPosition_);
						float3 n = ViewNormal;
						ao += Max(0, Dot((v_i), n) + ViewPosition_.Z * Bias)
							  / ((Dot(v_i, v_i) + Eps));
					}
					ao *= twoOverSampleCount * Multiplier;
					return Pow(Max(0, 1.0f - ao), Exponent);
				};

		}

/*
		public block FXSSAO2
		{
			float Multiplier 		: 2.65f;
			float Exponent 			: 18.0f;
			float Bias				: 0.01f;
			float Eps 				: 0.01f;
			float Radius 			: 12.0f;
			float MaxScreenRadius 	: 0.1f;

			Uno.Graphics.SamplerState samplerState : Uno.Graphics.SamplerState.LinearWrap;

			apply simppafi.RenderLibrary.NearCorners;
			apply simppafi.RenderLibrary.FarCorners;
			apply simppafi.RenderLibrary.ValuePixelOnScreen;

			float2 ScreenCoord : ValuePixelOnScreen;
			float2 ScreenSize : float2(BasePass.dcViewportSize.X, BasePass.dcViewportSize.Y);
			float2 PixelCoord2 : ScreenCoord * ScreenSize;
			float2 AspectScale : float2(1.0f, BasePass.dcRatio);

			float4 Data : sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ScreenCoord, samplerState);

			float3 ViewPosition_ : simppafi.Utils.BufferData.ReadViewPosition(Data, ScreenCoord, NearCorners, FarCorners);
			float3 ViewNormal : simppafi.Utils.BufferData.ReadViewNormal(Data);

			float ScreenRadius : Math.Min(MaxScreenRadius, Radius / -ViewPosition_.Z);

			//float RandomizationFactor : 
			//	req(TexCoord as float2)
			//		TexCoord.X;////ViewNormal.X;//10f;

			float FXSSAO2 :
				{
					const float oneOverSampleCount = 1.0f / 9.0f;
					const float twoOverSampleCount = oneOverSampleCount * 2.0f;

		       		//float angularOffset = RandomizationFactor * Dot(PixelCoord2, float2(2.3734372915f, 3.58540627421f));
		       		float angularOffset = Dot(PixelCoord2, float2(2.3734372915f, 3.58540627421f));

					float ao = 0.0f;
					for (int i = 0; i<9; i++)
					{
						float alpha = oneOverSampleCount * ((float)i + 0.5f);
						float theta = 2.0f * Math.PIf * alpha + angularOffset;
						var dir = float2(Cos(theta), Sin(theta));
						float2 spiral = dir * alpha;
						float2 sampleCoord = ScreenCoord + (spiral * ScreenRadius) * AspectScale;

						float4 data = sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, sampleCoord, samplerState);
						float3 viewSample =  simppafi.Utils.BufferData.ReadViewPosition(data, sampleCoord, NearCorners, FarCorners);
						float3 v_i = (viewSample - ViewPosition_);
						float3 n = ViewNormal;
						ao += Max(0, Dot((v_i), n) + ViewPosition_.Z * Bias)
							  / ((Dot(v_i, v_i) + Eps));
					}
					ao *= twoOverSampleCount * Multiplier;
					return Pow(Max(0, 1.0f - ao), Exponent);
				};

		}
*/

		public block CameraWorldDistance
		{
			float3 dx :
				req(CameraPosition as float3)
				req(WorldPosition as float3)
					pixel CameraPosition - WorldPosition;
			float dxist : dx.X*dx.X+dx.Y*dx.Y+dx.Z*dx.Z;
		}

		public block BlendAdd
		{
			///*
			//WriteDepth: false;
		   // DepthTestEnabled: false;
		   	//alpha
			//BlendSrc: Uno.Graphics.BlendOperand.SrcAlpha;
			//BlendDst: Uno.Graphics.BlendOperand.OneMinusSrcAlpha;
			//add
			BlendSrc: Uno.Graphics.BlendOperand.One;
			BlendDst: Uno.Graphics.BlendOperand.One;
			//premultiplied alpha
			//BlendSrc : Uno.Graphics.BlendOperand.One;
   			//BlendDst : Uno.Graphics.BlendOperand.OneMinusSrcAlpha;
		  	BlendEnabled: true;
			//CullFace: Uno.Graphics.PolygonFace.Back;
			//*/
		}

		

	}
}

/*
using Uno;
using Uno.Math;
using Uno.Vector;

namespace simppafi
{
	public class RenderLibrary
	{
		public block ValuePixelOnScreen
		{
			float2 ValuePixelOnScreen :
				req(ClipPosition as float4)
					pixel ClipPosition.XY / ClipPosition.W * 0.5f + 0.5f;
		}

		//public block Mirror 
		//{
		//	ClipPosition:
		//		req(WorldPosition as float3)
		//			simppafi.RenderPipeline.IsMirror ? Uno.Vector.Transform(float4(WorldPosition,1), EnvMirror.mirrorMatrix) : prev;
		//}

		public block FXPost
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float4 FXPost :
				req(PostFramebuffer as framebuffer)
					sample(PostFramebuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		}

		public block FXGlobalPost
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float4 FXGlobalPost : sample(FramebufferStorage.GlobalPostBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		}

		public block PXMask
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float Mask : sample(FramebufferStorage.GlobalMaskBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).X;
		}

		public block FXMask
		{
			apply simppafi.RenderLibrary.PXMask;
			PixelColor :
				req(MaskColor as float)
					//Math.Abs(Mask-MaskColor) < .01f ? prev : float4(0,0,0,0);
					//float4(prev.XYZ * (1f-Math.Max(0, Math.Abs(Mask-MaskColor) * 100f )), prev.W);
					prev * (1f-Math.Max(0, Math.Abs(Mask-MaskColor) * 100f ));
		}

		

		public block FXDeferred
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float4 FXDeferred : sample(FramebufferStorage.GlobalDeferredBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap);
		}


		public block GlobalDepthLinear
		{
			apply simppafi.RenderLibrary.ValuePixelOnScreen;
			float GlobalDepthLinear :	simppafi.Utils.BufferPacker.UnpackFloat16(sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ValuePixelOnScreen, Uno.Graphics.SamplerState.LinearWrap).ZW);
		}

		public block NearCorners
		{
			float4x4 NearCorners : BasePass.NearCorners;
		}

		public block FarCorners
		{
			float4x4 FarCorners : BasePass.FarCorners;
		}

		public block FXLiquid
		{
			apply simppafi.RenderLibrary.FXPost;

			public texture2D SphereMap 	: import Uno.Graphics.Texture2D("../Assets/SphereMap2.jpg");

			float3 LiquidColor : prev, float3(0,0,0);

			float4 FXGlobalPost : prev;
			float4 FXLiquid :
			{
				float3 samp = sample(SphereMap, FXPost.XY).XYZ * LiquidColor;
				float3 col = samp * samp;
				float4 px = float4(col, Math.Min(1f, (FXPost.W-.9f)*30f));//, 1);
				return px * Math.Floor(FXPost.W+.1f);
			};
		}

		public block FXSSAO
		{
			float Multiplier 		: 2.65f;
			float Exponent 			: 18.0f;
			float Bias				: 0.01f;
			float Eps 				: 0.01f;
			float Radius 			: 12.0f;
			float MaxScreenRadius 	: 0.1f;

			Uno.Graphics.SamplerState samplerState : Uno.Graphics.SamplerState.LinearWrap;

			apply simppafi.RenderLibrary.NearCorners;
			apply simppafi.RenderLibrary.FarCorners;
			apply simppafi.RenderLibrary.ValuePixelOnScreen;

			float2 ScreenCoord : ValuePixelOnScreen;
			float2 ScreenSize : float2(BasePass.dcViewportSize.X, BasePass.dcViewportSize.Y);
			float2 PixelCoord2 : ScreenCoord * ScreenSize;
			float2 AspectScale : float2(1.0f, BasePass.dcRatio);

			float4 Data : sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, ScreenCoord, samplerState);

			float3 ViewPosition_ : simppafi.Utils.BufferData.ReadViewPosition(Data, ScreenCoord, NearCorners, FarCorners);
			float3 ViewNormal : simppafi.Utils.BufferData.ReadViewNormal(Data);

			float ScreenRadius : Math.Min(MaxScreenRadius, Radius / -ViewPosition_.Z);


			float RandomizationFactor : 1f;

			float FXSSAO :
				{
					const float oneOverSampleCount = 1.0f / 9.0f;
					const float twoOverSampleCount = oneOverSampleCount * 2.0f;

		       		float angularOffset = RandomizationFactor * Dot(PixelCoord2, float2(2.3734372915f, 3.58540627421f));

					float ao = 0.0f;
					for (int i = 0; i<9; i++)
					{
						float alpha = oneOverSampleCount * ((float)i + 0.5f);
						float theta = 2.0f * Math.PIf * alpha + angularOffset;
						var dir = float2(Cos(theta), Sin(theta));
						float2 spiral = dir * alpha;
						float2 sampleCoord = ScreenCoord + (spiral * ScreenRadius) * AspectScale;

						float4 data = sample(FramebufferStorage.GlobalDepthBuffer.ColorBuffer, sampleCoord, samplerState);
						float3 viewSample =  simppafi.Utils.BufferData.ReadViewPosition(data, sampleCoord, NearCorners, FarCorners);
						float3 v_i = (viewSample - ViewPosition_);
						float3 n = ViewNormal;
						ao += Max(0, Dot((v_i), n) + ViewPosition_.Z * Bias)
							  / ((Dot(v_i, v_i) + Eps));
					}
					ao *= twoOverSampleCount * Multiplier;
					return Pow(Max(0, 1.0f - ao), Exponent);
				};

		}

		public block CameraWorldDistance
		{
			float3 dx :
				req(CameraPosition as float3)
				req(WorldPosition as float3)
					pixel CameraPosition - WorldPosition;
			float dxist : dx.X*dx.X+dx.Y*dx.Y+dx.Z*dx.Z;
		}

		public block BlendAdd
		{
			//WriteDepth: false;
		   // DepthTestEnabled: false;
		   	//alpha
			//BlendSrc: Uno.Graphics.BlendOperand.SrcAlpha;
			//BlendDst: Uno.Graphics.BlendOperand.OneMinusSrcAlpha;
			//add
			BlendSrc: Uno.Graphics.BlendOperand.One;
			BlendDst: Uno.Graphics.BlendOperand.One;
			//premultiplied alpha
			//BlendSrc : Uno.Graphics.BlendOperand.One;
   			//BlendDst : Uno.Graphics.BlendOperand.OneMinusSrcAlpha;
		  	BlendEnabled: true;
			//CullFace: Uno.Graphics.PolygonFace.Back;
		}

	}
}
*/