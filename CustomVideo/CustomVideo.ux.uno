using Uno.UX;

public partial class CustomVideo
{
	public CustomVideo()
	{
		MakeSureScriptClassRegistered();
		InitializeUX();

	}

	public static bool IsScriptClassRegistered = false;
	public static void MakeSureScriptClassRegistered()
	{
		if(!CustomVideo.IsScriptClassRegistered)
		{
			
			IsScriptClassRegistered = true;
		}
		
	}

	public double CurrentPosition
	{
		get {return Position;}
	}

	public double CurrentDuration
	{
		get {return Duration;}
	}

	private Fuse.Triggers.Actions.RaiseUserEvent myevent = new Fuse.Triggers.Actions.RaiseUserEvent();
	public void OnProgressChanged(object sender, ValueChangedArgs<double> args)
	{
		//var myevent = new Fuse.Triggers.Actions.RaiseUserEvent();
		myevent.EventName = "EventProgress";
		myevent.PerformFromNode(this);
	}

}