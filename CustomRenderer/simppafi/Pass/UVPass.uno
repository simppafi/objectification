namespace simppafi
{
	public class UVPass : BasePass
	{
		apply simppafi.TexCoordPass;

		PixelColor :
				float4(simppafi.Utils.BufferPacker.PackFloat16(TexCoord.X), simppafi.Utils.BufferPacker.PackFloat16(TexCoord.Y));
	}
}