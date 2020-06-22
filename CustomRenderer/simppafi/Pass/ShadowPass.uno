namespace simppafi
{
	
	/*
	public class ShadowDepthPass : BasePass
	{
		float Depth:
			req(WorldPosition as float3)
				(Uno.Vector.Length(pixel WorldPosition - EnvShadow.lightPosition) / EnvShadow.lightDepth);

		PixelColor : simppafi.Utils.BufferPacker.PackFloat32(pixel Depth);//float4(simppafi.Utils.BufferPacker.PackFloat16(Depth), 0,0);
	}
	*/

	/*
	public class ShadowCoordPass : BasePass
	{
		float4 ShadowCoord:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4(pixel WorldPosition,1), EnvShadow.lightMatrix);
		float2 ShadowTC: (pixel ShadowCoord.XY / pixel ShadowCoord.W) * 0.5f + 0.5f;

		PixelColor : float4(simppafi.Utils.BufferPacker.PackFloat16(ShadowTC.X), simppafi.Utils.BufferPacker.PackFloat16(ShadowTC.Y));
			
	}
	*/

	/*
	private block ShadowExponential
	{
		EnvShadow _envShadow : prev;
		
		float4x4 lightMatrix : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(_envShadow.Light.Position, _envShadow.Light.Target, float3(0,1,0)), Uno.Matrix.OrthoRH(_envShadow.shadowArea.X, _envShadow.shadowArea.Y, 10, _envShadow.lightDepth));


		float4 ShadowCoord:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4( pixel WorldPosition,1), lightMatrix);
		float2 ShadowTC: (pixel ShadowCoord.XY / pixel ShadowCoord.W) * 0.5f + 0.5f;

		float Depth:
			req(WorldPosition as float3)
				(Uno.Vector.Length(pixel WorldPosition - _envShadow.Light.Position) / _envShadow.lightDepth);

		float4 ShadowMap : sample(_envShadow.shadowMap.ColorBuffer, ShadowTC, Uno.Graphics.SamplerState.LinearWrap);


		//float ShadowDepth : simppafi.Utils.BufferPacker.UnpackFloat16(ShadowMap.ZW);
		//float ShadowDepthSquared : simppafi.Utils.BufferPacker.UnpackFloat16(ShadowMap.XY);
		float ShadowDepth : simppafi.Utils.BufferPacker.UnpackFloat32(ShadowMap);

		//float ambient : _envShadow.shadowAmbient;

		float c : _envShadow.shadowC; //88f
		float ShadowValue : (ShadowTC.X < .02f || ShadowTC.X > .98f || ShadowTC.Y < .02f || ShadowTC.Y > .98f) ? 1f : Uno.Math.Clamp(Uno.Math.Exp(c * ShadowDepth) * Uno.Math.Exp(-c * Depth), 0.0f, 1.0f);
		//ShadowValue : Uno.Math.Min(1f, prev) + _envShadow.shadowAmbient;

		//if(compare > Depth || ShadowTC.X < .01f || ShadowTC.X > .99f || ShadowTC.Y < .01f || ShadowTC.Y > .99f)
	}
	*/

	/*
	private block ShadowFourExponential
	{
		EnvShadow _envShadow : prev;
		
		float4 ShadowCoord:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4( pixel WorldPosition,1), _envShadow.lightMatrix);
		float2 ShadowTC: (pixel ShadowCoord.XY / pixel ShadowCoord.W) * 0.5f + 0.5f;

		float Depth:
			req(WorldPosition as float3)
				(Uno.Vector.Length(pixel WorldPosition - _envShadow.lightPosition) / _envShadow.lightDepth);

		float4 ShadowMap : sample(_envShadow.shadowMap.ColorBuffer, ShadowTC, Uno.Graphics.SamplerState.LinearWrap);

		float ShadowDepth : simppafi.Utils.BufferPacker.UnpackFloat32(ShadowMap);

		float c : _envShadow.shadowC; //88f
		float ShadowValue : (ShadowTC.X < .02f || ShadowTC.X > .98f || ShadowTC.Y < .02f || ShadowTC.Y > .98f) ? 1f : Uno.Math.Clamp(Uno.Math.Exp(c * ShadowDepth) * Uno.Math.Exp(-c * Depth), 0.0f, 1.0f);
	}
	*/

	public class ShadowPass : BasePass
	{
		//ClipPosition : float4( prev.XY * 0.5f, prev.ZW);

		public EnvShadow _envShadow;
		float3 lPos : _envShadow.Light.Position;//*3f; 
		
		//float4x4 lightMatrix : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos, _envShadow.Light.Target, float3(0,1,0)), Uno.Matrix.OrthoRH(_envShadow.shadowArea.X, _envShadow.shadowArea.Y, 10, _envShadow.lightDepth));

		float4x4 lightMatrix : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos, _envShadow.Light.Target, float3(0,1,0)), Uno.Matrix.PerspectiveRH(_envShadow.perspective, 1f, 10, _envShadow.lightDepth));
			

		// CAN BE SAMPLED FROM GlobalShadowDepthBuffer
		float Depth:
			req(WorldPosition as float3)
				(Uno.Vector.Length(pixel WorldPosition - lPos) / _envShadow.lightDepth);

		//Depth : 0f;

		/*float3 A : 
			req(WorldPosition as float3)
				pixel WorldPosition;
		float3 B : lPos;
		float dot : Uno.Vector.Dot(B, A);
		Depth : (dot > 0f) ? 0f : prev;
*/
		float4 PackedDepth : simppafi.Utils.BufferPacker.PackFloat32(pixel Depth);

		float3 TargetPosition : lPos;
		float3 TargetScale : prev * float3(2f);

		//float3 VertexPosition : Uno.Vector.Transform(prev, lightMatrix).XYZ;
		ClipPosition:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4(WorldPosition,1), lightMatrix);
		
		//ClipPosition : float4(prev.XY * .5f, prev.ZW);
		//ClipPosition : float4(Uno.Math.Clamp(prev.X, -.5f, .5f), Uno.Math.Clamp(prev.Y, -.5f, .5f), prev.Z, prev.W);
		//ClipPosition : float4(prev.XY + float2(-.5f, .5f), prev.ZW);

		//ClipPosition : float4(Uno.Math.Clamp(prev.X, -1f, 1f), Uno.Math.Clamp(prev.Y, -1f, 1f), prev.Z, prev.W);
		
		//float4x4 ViewProjection: lightMatrix;

		//ClipPosition : float4(prev.XY * .5f, prev.ZW);

		CullFace : Uno.Graphics.PolygonFace.Back;
		PixelColor : PackedDepth;

	}

	public class ShadowFramePass : BasePass
	{
		float4 ShadowChannels : float4(0);

		public EnvShadow[] ShadowList;

		float dimmStrength : 4f; //4f

		public float3[] 		_LightPositions;
		public float3[] 		_LightTargets;
		public float2[] 		_LightShadowArea;
		public float[]  		_LightDepth;
		public float[]  		_LightShadowC;
		public framebuffer[] 	_LightShadowMap;
		public float[]  		_LightPower;
		
		/*
		
		PixelColor : 
			req(WorldPosition as float3)
		{
			var ShadowValueFinal = 1f;
			for(var i = 0; i < _LightPositions.Length; i++)
			{
				float4x4 lightMatrix1 = Uno.Matrix.Mul(Uno.Matrix.LookAtRH(_LightPositions[i], _LightTargets[i], float3(0,1,0)), Uno.Matrix.OrthoRH(_LightShadowArea[i].X, _LightShadowArea[i].Y, 10, _LightDepth[i]));

				float4 ShadowCoord1 = Uno.Vector.Transform(float4( WorldPosition,1), lightMatrix1);
				float2 ShadowTC1 = (ShadowCoord1.XY / ShadowCoord1.W) * 0.5f + 0.5f;

				float Depth1 = (Uno.Vector.Length(WorldPosition - _LightPositions[i]) / _LightDepth[i]);

				
				float4 ShadowMap1 = float4(1,1,1,1);//sample(_LightShadowMap[i].ColorBuffer, ShadowTC1, Uno.Graphics.SamplerState.LinearWrap);

				float ShadowDepth1 = simppafi.Utils.BufferPacker.UnpackFloat32(ShadowMap1);

				float c = _LightShadowC[i];
				float ShadowValue1 = (ShadowTC1.X < .02f || ShadowTC1.X > .98f || ShadowTC1.Y < .02f || ShadowTC1.Y > .98f) ? 1f : Uno.Math.Exp(c * ShadowDepth1) * Uno.Math.Exp(-c * Depth1);// + Depth1*1.5f;
				ShadowValue1 = Uno.Math.Min(1f, ShadowValue1 + Depth1*dimmStrength);

				//return ShadowValue1;
				
				ShadowValueFinal *= ShadowValue1;
			}

			return float4(ShadowValueFinal,0,0,0);
		};
		*/

		///*
		//SHADOW 1
		float3 lPos1 : ShadowList[0].Light.Position;// * 3f;
		//float4x4 lightMatrix1 : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos1, ShadowList[0].Light.Target, float3(0,1,0)), Uno.Matrix.OrthoRH(ShadowList[0].shadowArea.X, ShadowList[0].shadowArea.Y, 10, ShadowList[0].lightDepth));
		float4x4 lightMatrix1 : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos1, ShadowList[0].Light.Target, float3(0,1,0)), Uno.Matrix.PerspectiveRH(ShadowList[0].perspective, 1f, 10, ShadowList[0].lightDepth));
		

		float4 ShadowCoord1:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4( pixel WorldPosition,1), lightMatrix1);
		float2 ShadowTC1: (ShadowCoord1.XY / ShadowCoord1.W) * 0.5f + 0.5f;

		//float2 ShadowTC1 : prev * float2(.5f);// + float2(-.5f, .5f);

		float Depth1:
			req(WorldPosition as float3)
				(Uno.Vector.Length(WorldPosition - lPos1) / ShadowList[0].lightDepth);
		
		float3 A1 : 
			req(WorldPosition as float3)
				pixel WorldPosition;
		float3 B1 : lPos1;
		float3 AB1 : A1-B1;
		float dot1 : Uno.Vector.Dot(B1, AB1);
		float behind1 : (dot1 > 0f) ? 1f : 0f;

		float FrontDepth1 : Uno.Math.Min(1f, Depth1 + behind1); 

		float4 ShadowMap1 : sample(ShadowList[0].shadowMap.ColorBuffer, ShadowTC1, Uno.Graphics.SamplerState.LinearClamp);
		float ShadowDepth1 : simppafi.Utils.BufferPacker.UnpackFloat32(ShadowMap1);
		float c1 : ShadowList[0].shadowC;
		
		float ShadowValue1 : 
		(ShadowTC1.X < .02f || ShadowTC1.X > .98f || ShadowTC1.Y < .02f || ShadowTC1.Y > .98f) ? 1f : 
		Uno.Math.Exp(c1 * ShadowDepth1) * Uno.Math.Exp(-c1 * FrontDepth1);// + Depth1*1.5f;

		ShadowValue1 : Uno.Math.Max(0f, prev + behind1);
		ShadowValue1 : Uno.Math.Min(1f, prev + Depth1*dimmStrength);
		ShadowValue1 : Uno.Math.Max(0f, prev - Depth1*dimmStrength);

		



		///*
		//SHADOW 2
		float3 lPos2 : ShadowList[1].Light.Position;// * 3f;
		//float4x4 lightMatrix2 : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos2, ShadowList[1].Light.Target, float3(0,1,0)), Uno.Matrix.OrthoRH(ShadowList[1].shadowArea.X, ShadowList[1].shadowArea.Y, 10, ShadowList[1].lightDepth));
		float4x4 lightMatrix2 : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos2, ShadowList[1].Light.Target, float3(0,1,0)), Uno.Matrix.PerspectiveRH(ShadowList[1].perspective, 1f, 10, ShadowList[1].lightDepth));
		
		float4 ShadowCoord2:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4( pixel WorldPosition,1), lightMatrix2);
		float2 ShadowTC2: (ShadowCoord2.XY / ShadowCoord2.W) * 0.5f + 0.5f;

		float Depth2:
			req(WorldPosition as float3)
				(Uno.Vector.Length(WorldPosition - lPos2) / ShadowList[1].lightDepth);

		float3 A2 : 
			req(WorldPosition as float3)
				pixel WorldPosition;
		float3 B2 : lPos2;
		float3 AB2 : A2-B2;
		float dot2 : Uno.Vector.Dot(B2, AB2);
		float behind2 : (dot2 > 0f) ? 1f : 0f;

		float FrontDepth2 : Uno.Math.Min(1f, Depth2 + behind2); 

		float4 ShadowMap2 : sample(ShadowList[1].shadowMap.ColorBuffer, ShadowTC2, Uno.Graphics.SamplerState.LinearClamp);
		float ShadowDepth2 : simppafi.Utils.BufferPacker.UnpackFloat32(ShadowMap2);
		float c2 : ShadowList[1].shadowC;
		
		float ShadowValue2 : 
		(ShadowTC2.X < .02f || ShadowTC2.X > .98f || ShadowTC2.Y < .02f || ShadowTC2.Y > .98f) ? 1f : 
		Uno.Math.Exp(c2 * ShadowDepth2) * Uno.Math.Exp(-c2 * FrontDepth2);

		ShadowValue2 : Uno.Math.Max(0f, prev + behind2);
		ShadowValue2 : Uno.Math.Min(1f, prev + Depth2*dimmStrength);
		ShadowValue2 : Uno.Math.Max(0f, prev - Depth2*dimmStrength);


		//SHADOW 3
		float3 lPos3 : ShadowList[2].Light.Position;// * 3f;
		//float4x4 lightMatrix3 : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos3, ShadowList[2].Light.Target, float3(0,1,0)), Uno.Matrix.OrthoRH(ShadowList[2].shadowArea.X, ShadowList[2].shadowArea.Y, 10, ShadowList[2].lightDepth));
		float4x4 lightMatrix3 : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos3, ShadowList[2].Light.Target, float3(0,1,0)), Uno.Matrix.PerspectiveRH(ShadowList[2].perspective, 1f, 10, ShadowList[2].lightDepth));
		
		float4 ShadowCoord3:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4( pixel WorldPosition,1), lightMatrix3);
		float2 ShadowTC3: (ShadowCoord3.XY / ShadowCoord3.W) * 0.5f + 0.5f;

		float Depth3:
			req(WorldPosition as float3)
				(Uno.Vector.Length(WorldPosition - lPos3) / ShadowList[2].lightDepth);

		float3 A3 : 
			req(WorldPosition as float3)
				pixel WorldPosition;
		float3 B3 : lPos3;
		float3 AB3 : A3-B3;
		float dot3 : Uno.Vector.Dot(B3, AB3);
		float behind3 : (dot3 > 0f) ? 1f : 0f;

		float FrontDepth3 : Uno.Math.Min(1f, Depth3 + behind3); 

		float4 ShadowMap3 : sample(ShadowList[2].shadowMap.ColorBuffer, ShadowTC3, Uno.Graphics.SamplerState.LinearClamp);
		float ShadowDepth3 : simppafi.Utils.BufferPacker.UnpackFloat32(ShadowMap3);
		float c3 : ShadowList[2].shadowC;
		
		float ShadowValue3 : 
		(ShadowTC3.X < .02f || ShadowTC3.X > .98f || ShadowTC3.Y < .02f || ShadowTC3.Y > .98f) ? 1f : 
		Uno.Math.Exp(c3 * ShadowDepth3) * Uno.Math.Exp(-c3 * FrontDepth3);

		ShadowValue3 : Uno.Math.Max(0f, prev + behind3);
		ShadowValue3 : Uno.Math.Min(1f, prev + Depth3*dimmStrength);
		ShadowValue3 : Uno.Math.Max(0f, prev - Depth3*dimmStrength);



		//SHADOW 4
		float3 lPos4 : ShadowList[3].Light.Position;// * 3f;
		//float4x4 lightMatrix4 : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos4, ShadowList[3].Light.Target, float3(0,1,0)), Uno.Matrix.OrthoRH(ShadowList[3].shadowArea.X, ShadowList[3].shadowArea.Y, 10, ShadowList[3].lightDepth));
		float4x4 lightMatrix4 : Uno.Matrix.Mul(Uno.Matrix.LookAtRH(lPos4, ShadowList[3].Light.Target, float3(0,1,0)), Uno.Matrix.PerspectiveRH(ShadowList[3].perspective, 1f, 10, ShadowList[3].lightDepth));
		
		float4 ShadowCoord4:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4( pixel WorldPosition,1), lightMatrix4);
		float2 ShadowTC4: (ShadowCoord4.XY / ShadowCoord4.W) * 0.5f + 0.5f;

		float Depth4:
			req(WorldPosition as float3)
				(Uno.Vector.Length(WorldPosition - lPos4) / ShadowList[3].lightDepth);

		float3 A4 : 
			req(WorldPosition as float3)
				pixel WorldPosition;
		float3 B4 : lPos4;
		float3 AB4 : A4-B4;
		float dot4 : Uno.Vector.Dot(B4, AB4);
		float behind4 : (dot4 > 0f) ? 1f : 0f;

		float FrontDepth4 : Uno.Math.Min(1f, Depth4 + behind4); 

		float4 ShadowMap4 : sample(ShadowList[3].shadowMap.ColorBuffer, ShadowTC4, Uno.Graphics.SamplerState.LinearClamp);
		float ShadowDepth4 : simppafi.Utils.BufferPacker.UnpackFloat32(ShadowMap4);
		float c4 : ShadowList[3].shadowC;
		
		float ShadowValue4 : 
		(ShadowTC4.X < .02f || ShadowTC4.X > .98f || ShadowTC4.Y < .02f || ShadowTC4.Y > .98f) ? 1f : 
		Uno.Math.Exp(c4 * ShadowDepth4) * Uno.Math.Exp(-c4 * FrontDepth4);

		ShadowValue4 : Uno.Math.Max(0f, prev + behind4);
		ShadowValue4 : Uno.Math.Min(1f, prev + Depth4*dimmStrength);
		ShadowValue4 : Uno.Math.Max(0f, prev - Depth4*dimmStrength);


		
		float ShadowFinal : (	ShadowValue1 * _LightPower[0]+
								ShadowValue2 * _LightPower[1]+
								ShadowValue3 * _LightPower[2]+
								ShadowValue4 * _LightPower[3]) / 4f;

		
		
	}

	public block ShadowApply
	{
		//apply ShadowExponential;
		//PixelColor : float4(float3(Uno.Math.Min(prev.X, 1f), Uno.Math.Min(prev.Y, 1f), Uno.Math.Min(prev.Z, 1f)) - (1f-ShadowValue)* EnvShadow.shadowAmbient, prev.W);
		//PixelColor : simppafi.FramebufferStorage.RenderShadow ? float4(prev.XYZ * ShadowValue, prev.W) : prev;

		//PixelColor : float4(prev.XYZ * ShadowValue, prev.W);

		//PixelColor : float4(prev.XYZ - (1f-ShadowValue)* EnvShadow.shadowAmbient, prev.W);
	}

}



/*
	private block ShadowVariance
	{
		float4 ShadowCoord:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4(WorldPosition,1), EnvShadow.lightMatrix);
		float2 ShadowTC: (pixel ShadowCoord.XY / pixel ShadowCoord.W) * 0.5f + 0.5f;

		float Depth:
			req(WorldPosition as float3)
				(Uno.Vector.Length(pixel WorldPosition - EnvShadow.lightPosition) / EnvShadow.lightDepth);

		float4 ShadowMap : sample(EnvShadow.shadowMap.ColorBuffer, ShadowTC, Uno.Graphics.SamplerState.LinearClamp);


		float ShadowDepth : simppafi.Utils.BufferPacker.UnpackFloat16(ShadowMap.ZW);
		float ShadowDepthSquared : simppafi.Utils.BufferPacker.UnpackFloat16(ShadowMap.XY);

		float compare : ShadowDepth;
		float ambient : EnvShadow.shadowAmbient;

		float ShadowSoft : prev , 0.001f;//0.00005f;
		//	prev , 0.0005f;//0.0000001f;

		float ShadowValue :
		{
			if(compare > Depth || ShadowTC.X < .01f || ShadowTC.X > .99f || ShadowTC.Y < .01f || ShadowTC.Y > .99f)
			{
				return 1f;
			}else{
				// The fragment is either in shadow or penumbra. We now use chebyshev's upperBound to check
				// How likely this pixel is to be lit (p_max)
				float variance = ShadowDepthSquared - (ShadowDepth*ShadowDepth);
				variance = Uno.Math.Max(variance, ShadowSoft);

				float d = Depth - ShadowDepth;
				float p_max = variance / (variance + d*d);

				return Uno.Math.Max(ambient, p_max);
			}
		};
	}
	*/