namespace simppafi
{
	public class NormalPass : BasePass
	{
		/*float3x3 TangentToView :
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
		*/

		float3 Normal : pixel prev;//Uno.Vector.Normalize((pixel prev + 1f) * .5f);

		//float3 _bump : 
		//	req(TexCoord as float2)
		//		Uno.Vector.Normalize(sample(import Uno.Graphics.Texture2D("../../Assets/1426-normal.jpg"), TexCoord).XYZ * 2.0f - 1.0f);
			
		Normal : Uno.Vector.Normalize(prev);// + _bump);
		
		PixelColor : float4(Normal, 0);
	}
}