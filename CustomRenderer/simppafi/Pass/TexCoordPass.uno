namespace simppafi
{
	public class TexCoordPass : BasePass
	{
		float2 TexCoord : pixel prev;//pixel prev;
		float2 TexCoordFull : prev TexCoord;
		TexCoord : 
			req(UVStart as float2)
				(prev * .49f) + (UVStart+.005f);
	}
}