using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse.Entities;
using Uno.Content;
using Uno.Content.Models;
using Uno.Math;
using Uno.Vector;

namespace simppafi.Utils
{
	public static class BufferData
	{
		public static float3 ReadViewNormal(float4 packedData)
		{
			return BufferPacker.UnpackNormal(packedData.XY);
		}

		public static float3 ReadViewPosition(float4 packedData, float2 texCoord, float4x4 near, float4x4 far)
		{
			var linearDepth = BufferPacker.UnpackFloat16(packedData.ZW);
			return ToViewSpace(float3(texCoord,linearDepth), near, far);
		}

		public static float3 ToViewSpace(float3 imagePosition, float4x4 near, float4x4 far)
		{
			float3 farTL = far[0].XYZ; float3 farTR = far[1].XYZ; float3 farBL = far[2].XYZ;
			float3 nearTL = near[0].XYZ;

			float farZ = farTL.Z;
			float nearZ = nearTL.Z;
			float ratio = nearZ/farZ;

			var linearDepth = imagePosition.Z;
			var linearDist = (1f - ratio) * linearDepth + ratio;

			var farDiag = farTR.XY - farBL.XY;
			var farPos = farBL + float3(farDiag * imagePosition.XY,0);

			return farPos * linearDist;
		}

	}
	public static class BufferPacker
	{
		public static float4 PackNormalDepth(float3 normal, float linearDepth)
		{
			return float4(PackNormal(normal), PackFloat16(linearDepth));
		}

		public static float2 PackNormal(float3 n)
		{
			var f = Sqrt(8 * n.Z + 8);
			return n.XY / f + 0.5f;
		}

		public static float3 UnpackNormal(float2 enc)
		{
			var fenc = enc * 4 - 2;
			var f = Dot(fenc,fenc);
			var g = Sqrt(1 - f/4);
			return float3(fenc * g, 1 - f/2);
		}

		public static float4 PackFloat32( float v ) {
		  float4 enc = float4(1.0f, 255.0f, 65025.0f, 160581375.0f) * v;
		  enc = Frac(enc);
		  enc -= enc.YZWW * float4(1.0f/255.0f,1.0f/255.0f,1.0f/255.0f,0.0f);
		  return enc;
		}
		
		public static float UnpackFloat32( float4 rgba ) {
		  return Vector.Dot( rgba, float4(1.0f, 1f/255.0f, 1f/65025.0f, 1f/160581375.0f) );
		}


		public static float UnpackFloat16(float2 rg_depth)
		{
			return rg_depth.X + rg_depth.Y * 0.00392156862f;
		}

		public static float2 PackFloat16(float depth)
		{
			var enc = float2(1.0f, 255.0f) * depth;
			enc = float2(Frac(enc.X), Frac(enc.Y));
			enc -= float2(enc.Y * 0.00392156862f, 0);
			return enc;
		}

		public static float PackTwoFloats(float lo, float hi)
		{
			return (Floor(lo * 15.0f) + Floor(hi * 15.0f) * 16.0f) / 255.0f;
		}

		public static float2 UnpackTwoFloats(float d)
		{
			var k = d * 255.0f;
			var msn = Floor(k/16.0f);
			var lsn = k - msn * 16.0f;

			return float2(lsn/15.0f,msn/15.0f);// lsn/16.0f);
		}

		public static float4 Frac(float4 f)
		{
			return float4(Frac(f.X),Frac(f.Y),Frac(f.Z),Frac(f.W));
		}

		public static float3 Frac(float3 f)
		{
			return float3(Frac(f.X),Frac(f.Y),Frac(f.Z));
		}

		public static float2 Frac(float2 f)
		{
			return float2(Frac(f.X),Frac(f.Y));
		}

		public static float Frac(float f)
		{
			return f - Floor(f);
		}



		public static float PackFloat2(float2 src)
		{
			return Math.Floor((src.X+1)*0.5f * 100.0f)+((src.Y+1)*0.4f);
		}

		public static float2 UnpackFloat2(float src)
		{
			float2 o;
			float fFrac = src - Floor(src);
			o.Y = (fFrac-0.4f)*2.5f;
			o.X = ((src-fFrac)/100.0f-0.5f)*2;
			return o;
		}


		public static float PackFloat3(float3 c)
		{
			var a = (c + float3(1f)) * .5f;
		    return (1f / Vector.Dot(Round(a * 255), float3(65536, 256, 1))) * 10000000f;
		}

		public static float3 UnpackFloat3(float f)
		{
			f /= 10000000f;
			f = 1f/f;
			var a = Frac(f / float3(16777216, 65536, 256));
			return a * 2 - 1f;
		}

	}
}