using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse.Entities;
using Uno.Content;
using Uno.Content.Models;
using Uno.Vector;
namespace simppafi.Utils
{

	public struct FrustumCorners
	{
		public readonly float3 NearTL;
		public readonly float3 NearTR;
		public readonly float3 NearBL;
		public readonly float3 NearBR;
		public readonly float3 FarTL;
		public readonly float3 FarTR;
		public readonly float3 FarBL;
		public readonly float3 FarBR;

		public readonly float2 NearTLBR;
		public readonly float2 FarTLBR;
		public FrustumCorners(float4x4 invProj)
		{
			var bl = Transform(float4(-1,-1,-1, 1), invProj);
			var br = Transform(float4( 1,-1,-1, 1), invProj);
			var tl = Transform(float4(-1, 1,-1, 1), invProj);
			var tr = Transform(float4( 1, 1,-1, 1), invProj);

			NearTL = tl.XYZ / tl.W;
			NearTR = tr.XYZ / tr.W;
			NearBL = bl.XYZ / bl.W;
			NearBR = br.XYZ / br.W;

			var fbl = Transform(float4(-1,-1, 1, 1), invProj);
			var fbr = Transform(float4( 1,-1, 1, 1), invProj);
			var ftl = Transform(float4(-1, 1, 1, 1), invProj);
			var ftr = Transform(float4( 1, 1, 1, 1), invProj);

			FarTL = ftl.XYZ / ftl.W;
			FarTR = ftr.XYZ / ftr.W;
			FarBL = fbl.XYZ / fbl.W;
			FarBR = fbr.XYZ / fbr.W;

			NearTLBR = NearBR.XY - NearTL.XY;
			FarTLBR = FarBR.XY - FarTL.XY;
		}

		public float4x4 NearCorners
		{
			get
			{
				return float4x4(float4(NearTL, 1), float4(NearTR, 1), float4(NearBL, 1), float4(NearBR, 1));
			}
		}
		public float4x4 FarCorners
		{
			get
			{
				return float4x4(float4(FarTL, 1), float4(FarTR, 1), float4(FarBL, 1), float4(FarBR, 1));
			}
		}

	}
}