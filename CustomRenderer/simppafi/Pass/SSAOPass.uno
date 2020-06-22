namespace simppafi
{
	public class SSAOPass : BasePass
	{
		apply simppafi.RenderLibrary.FXSSAO;

		float ssao : FXSSAO;//*FXSSAO*FXSSAO;

		PixelColor : float4(ssao,ssao,ssao,1f);
	}
}