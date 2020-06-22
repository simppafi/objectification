namespace simppafi
{
	public class FinalPass : BasePass
	{
		apply simppafi.RenderLibrary.FXPost; //FXPost

		PixelColor : prev + FXPost;
	}
}