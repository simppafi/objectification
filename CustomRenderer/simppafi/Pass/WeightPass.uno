namespace simppafi
{
	public class WeightPass : BasePass
	{
		CullFace : Uno.Graphics.PolygonFace.Front;
		float LinearDepth : pixel prev;
		PixelColor : float4(simppafi.Utils.BufferPacker.PackFloat16(pixel LinearDepth), 1,1);
		
	}
}