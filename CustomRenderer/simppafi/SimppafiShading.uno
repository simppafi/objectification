using Uno;
using Uno.Geometry;
using Uno.Math;
using Uno.Vector;
using Uno.Matrix;

namespace simppafi
{
	public block SimppafiShading 
	{
		float2 UVStart: 
			req(UVCoord as float2)
				UVCoord, float2(0,0);

		float2 ReflectionUVStart:
			req(ReflectionCoord as float2)
				ReflectionCoord, float2(0,0);

		float3 albedo : float3(0f);
		float metallic : 0f;
		float roughness : 1f;
		float ao : 1f;


		//float3 VertexPosition : Uno.Vector.Transform(prev, Uno.Quaternion.RotationY(-(float)Fuse.Time.FrameTime * .1f));

	}
}