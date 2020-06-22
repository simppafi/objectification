namespace simppafi
{
	public class MRAOPass : BasePass
	{
		float metallic 		: prev;
		float roughness 	: prev;
		float ao 			: prev;

		PixelColor : float4(metallic,roughness,ao,1f);
	}
}