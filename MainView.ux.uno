using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Fuse.Controls;
using Uno.Content;
using Uno.Content.Models;
using Fuse.Drawing.Primitives;

public partial class MainView
{
	public MainView()
	{
		InitializeUX();

		Fuse.Input.Keyboard.KeyPressed.AddGlobalHandler(KeyPressed);
		Fuse.Input.Keyboard.KeyReleased.AddGlobalHandler(KeyReleased);

		//DemoTimeline.ProgressChanged += OnProgressChanged;

		//MyRenderNode.DRAW_FRAME += OnDrawFrame;

		MyRenderNode.ON_SETUP += ReadyToStart;
	}
	

	private void KeyPressed(object sender, Fuse.Input.KeyPressedArgs args)
	{
		MyRenderNode.KeyPressed(sender, args);

		if(args.Key == Uno.Platform.Key.Escape)
		{
			Uno.Application.Current.Window.PointerCursor = Uno.Platform.PointerCursor.Default;
			Uno.Application.Current.Window.Fullscreen = false;
			/*
			if(Uno.Application.Current.Window.Fullscreen)
			{
				Uno.Application.Current.Window.Fullscreen = false;
			}else{
				Uno.Application.Current.Window.Close();
			}*/
		}
		else if(args.Key == Uno.Platform.Key.F)
		{
			Uno.Application.Current.Window.Fullscreen = true;
		}
		else if(args.Key == Uno.Platform.Key.Space)
		{
			//MyRenderNode.NextScene();

			//SoundVideo.Resume();
		}
		/*
		else if(args.Key == Uno.Platform.Key.J)
		{
			MyRenderNode.StartCameraSave();
		}
		else if(args.Key == Uno.Platform.Key.K)
		{
			MyRenderNode.SaveCamera();
		}
		else if(args.Key == Uno.Platform.Key.V)
		{
			MyRenderNode.DemoModeOn();
		}
		else if(args.Key == Uno.Platform.Key.B)
		{
			MyRenderNode.DemoModeOff();
		}*/
		
	}

	private void ReadyToStart()
	{
		Uno.Application.Current.Window.Fullscreen = true;
		MyRenderNode.ON_SETUP -= ReadyToStart;
		WaitTxt.Visibility = Fuse.Elements.Visibility.Collapsed;
		StartBtn.Visibility = Fuse.Elements.Visibility.Visible;
	}

	public void Start(object sender, object args)
	{
		Uno.Application.Current.Window.PointerCursor = Uno.Platform.PointerCursor.None;
		StartBtn.Visibility = Fuse.Elements.Visibility.Collapsed;
		//Play();
		///*
		timerStart = (float)Fuse.Time.FrameTime;
		UpdateManager.AddAction(WaitText1);
		//*/
	}

	private void WaitText1()
	{
		if( ((float)Fuse.Time.FrameTime - timerStart) > 4f)
		{
			soundfx.Value = false;
			soundfx.Value = true;
			timerStart = (float)Fuse.Time.FrameTime;
			UpdateManager.RemoveAction(WaitText1);
			UpdateManager.AddAction(OnText1);
		}
	}

	private bool soundPlayed = false;
	private float timerStart = 0f;
	private void OnText1()
	{
		text1.Visibility = Fuse.Elements.Visibility.Visible;
		if( ((float)Fuse.Time.FrameTime - timerStart) > 6f)
		{
			soundfx.Value = false;
			soundfx.Value = true;
			timerStart = (float)Fuse.Time.FrameTime;
			UpdateManager.RemoveAction(OnText1);
			UpdateManager.AddAction(OnText2);
		}
	}
	private void OnText2()
	{
		text1.Visibility = Fuse.Elements.Visibility.Collapsed;
		text2.Visibility = Fuse.Elements.Visibility.Visible;
		if( ((float)Fuse.Time.FrameTime - timerStart) > 6f)
		{
			soundfx.Value = false;
			soundfx.Value = true;
			timerStart = (float)Fuse.Time.FrameTime;
			UpdateManager.RemoveAction(OnText2);
			UpdateManager.AddAction(OnText3);
		}
	}
	private void OnText3()
	{
		text2.Visibility = Fuse.Elements.Visibility.Collapsed;
		text3.Visibility = Fuse.Elements.Visibility.Visible;
		if( ((float)Fuse.Time.FrameTime - timerStart) > 6f)
		{
			timerStart = (float)Fuse.Time.FrameTime;
			UpdateManager.RemoveAction(OnText3);
			UpdateManager.AddAction(OnTextDone);
		}
	}
	private void OnTextDone()
	{
		text3.Visibility = Fuse.Elements.Visibility.Collapsed;
		if( ((float)Fuse.Time.FrameTime - timerStart) > 7f)
		{
			timerStart = (float)Fuse.Time.FrameTime;
			UpdateManager.RemoveAction(OnTextDone);
			Play();
		}
	}

	private void Play()
	{
		SoundVideo.Resume();
	}
	
	private void KeyReleased(object sender, Fuse.Input.KeyReleasedArgs args)
	{
		MyRenderNode.KeyReleased(sender, args);
	}

/*
	private bool progressPosition = false;
	private void OnProgressChanged(object sender, object args)
	{
		if(!progressPosition)
		{
			SoundVideo.Position = (DemoTimeline.Value/100000) * SoundVideo.CurrentDuration;
			MyRenderNode.ResetDrumPos();
		}
		progressPosition = false;
	}
*/
	private float interval = .5f;
	private float prevTime = 0f;
	public void PositionUpdate(object sender, object args)
	{
		/*if((float)Fuse.Time.FrameTime > (prevTime+interval))
		{
			progressPosition = true;
			DemoTimeline.Value = (SoundVideo.CurrentPosition/SoundVideo.CurrentDuration) * 100000;
			prevTime = (float)Fuse.Time.FrameTime;
		}*/

		MyRenderNode.ControlDemo(SoundVideo.CurrentPosition, SoundVideo.CurrentDuration);

		/*DataPosID.Value = ""+MyRenderNode.CurrentDataPosition;

		if(SoundVideo.Position > 0.0)
		{
			var min = (int)((float)SoundVideo.Position / 60f) % 60;
			var sec = ((int)SoundVideo.Position) % 60;

			TimeVal.Value = ""+min+":"+sec;
		}*/
	}

	/*
	private float lastFrameTime = 0f;
	private int frameCount = 0;
	private float frameTime = 0f;
	private void OnDrawFrame()
	{
		var time = (float)Fuse.Time.FrameTime;
		frameTime += time-lastFrameTime;
		frameCount++;
		if(frameCount > 100)
		{
			var fps = 1f/(frameTime/100f);
			FpsCounter.Value = Math.Round(fps)+"";
			frameTime = 0f;
			frameCount = 0;
		}
		lastFrameTime = time;
*/
		//debug_log "RootViewport.PixelSize : "+RootViewport.PixelSize;
		//debug_log "RootViewport.PixelsPerPoint : "+RootViewport.PixelsPerPoint;
		//debug_log "RootViewport.Size : "+RootViewport.Size;
		//debug_log "RootViewport.AbsoluteZoom : "+RootViewport.AbsoluteZoom;

		/*
		RootViewport.PixelSize : 375, 667
		RootViewport.PixelsPerPoint : 1
		RootViewport.Size : 375, 667
		RootViewport.AbsoluteZoom : 1
		*/
		//debug_log Fuse.App.
		
		//Fuse.Elements.Viewport.

		//debug_log "RootViewport.PixelsPerPoint : "+RootViewport.PixelsPerPoint;
		//debug_log "Viewport.PixelsPerPoint : "+Viewport.PixelsPerPoint;
		//debug_log "GraphicsView.PixelsPerPoint : "+PixelsPerPoint;
		//debug_log "DrawContext.ViewportPixelsPerPoint : "+DrawContext.ViewportPixelsPerPoint;
/*
	}
*/

}