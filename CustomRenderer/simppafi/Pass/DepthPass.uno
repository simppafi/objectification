namespace simppafi
{
	public class DepthPass : BasePass
	{
		/*
		float3x3 TangentToView :
			req(ViewTangent as float3)
			req(ViewBinormal as float3)
			req(ViewNormal as float3)
				float3x3(ViewTangent, ViewBinormal, ViewNormal);

		float3 PerPixelViewNormal :
			req (TangentNormal as float3)
				Uno.Vector.Transform(TangentNormal, TangentToView),
			req(ViewNormal as float3)
				ViewNormal;
		
		float LinearDepth : pixel prev;

		PixelColor : simppafi.Utils.BufferPacker.PackNormalDepth(pixel PerPixelViewNormal, LinearDepth);
		*/

		float LinearDepth : pixel prev;
		PixelColor : simppafi.Utils.BufferPacker.PackFloat32(pixel LinearDepth);
		
	}
}