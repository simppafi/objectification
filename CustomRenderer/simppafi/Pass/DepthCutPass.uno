namespace simppafi
{
	public class DepthCutPass : BasePass
	{
		apply simppafi.RenderLibrary.FXDeferred;
		float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);

		float LinearDepth : pixel prev;

		float depthDif : _depth - LinearDepth;
		float cut : Uno.Math.Abs(depthDif) > .001f ? (depthDif + 1f) * .5f : 1f;

		PixelColor : prev * Uno.Math.Round(cut);
	}
}