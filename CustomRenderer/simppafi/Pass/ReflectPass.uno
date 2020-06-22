namespace simppafi
{
	public class ReflectPass : BasePass
	{
		float2 refl :
			req(ReflectedViewDirection as float3)
				req(View as float4x4)
					Uno.Vector.Normalize(Uno.Vector.Transform(ReflectedViewDirection, View).XYZ).XY * .5f + .5f;
		refl : 
			req(ReflectionUVStart as float2)
				(prev * .49f) + (ReflectionUVStart+.005f);

		PixelColor :
				float4(simppafi.Utils.BufferPacker.PackFloat16(refl.X), simppafi.Utils.BufferPacker.PackFloat16(refl.Y));
	}
}