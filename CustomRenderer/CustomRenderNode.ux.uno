using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Fuse.Entities;
using Fuse.Controls;
using Fuse.Drawing.Primitives;
using Uno.Content.Models;
using Fuse.Drawing.Batching;
using simppafi;

public partial class CustomRenderNode
{
	public delegate void FrameDrawEventHandler();
	public event FrameDrawEventHandler 		DRAW_FRAME;

	public delegate void SetupDoneEventHandler();
	public event SetupDoneEventHandler 		ON_SETUP;

	public Frustum CameraFrustum {get;set;}
	public Transform3D CameraTransform {get;set;}

	BaseSceneCamera CurrentSceneCamera;

	private bool CanDraw = false;

	private simppafi.DrumReader 		_drumReaderToms;
	private simppafi.DrumReader 		_drumReaderTomsLow;
	private simppafi.DrumReader 		_drumReaderSnare;
	private simppafi.DrumReader 		_drumReaderPiano;
	private simppafi.DrumReader 		_drumReaderKick;

	private simppafi.PeakReader 		_peakReader;

	private simppafi.Effect.EffectDeferred fxDeferred = new simppafi.Effect.EffectDeferred();


	public void StartCameraSave()
	{
		CurrentSceneCamera.StartValues();
	}

	public void SaveCamera()
	{
		debug_log "saveCamera";
		
		var filename = "still_cameras1.txt";

		var text = "";
		if(Uno.IO.File.Exists(filename)) 
		{
			text = Uno.IO.File.ReadAllText(filename);
		}
		
		text += CurrentSceneCamera.GetValues()+"#";
		debug_log CurrentSceneCamera.GetValues()+"#";
		Uno.IO.File.WriteAllText(filename, text);
	}

	private List<List<SceneCameraAnimation>>  camsStill = new List<List<SceneCameraAnimation>>();
	private void getCameraData()
	{
		//var filename = "still_cameras1.txt";

		var text = (import Uno.IO.BundleFile("Assets/still_cameras1.txt")).ReadAllText();//"";
		//if(Uno.IO.File.Exists(filename)) 
		//{
			//text = Uno.IO.File.ReadAllText(filename);
			var stillcams = text.Split(new [] {(char)'#'});
			debug_log "stillcams: "+stillcams.Length;

			for(var i = 0; i < 15; i++)
			{
				camsStill.Add(new List<SceneCameraAnimation>());
			}

			for(var i = 0; i < stillcams.Length-1; i++)
			{
				string str = stillcams[i];
				var json = Uno.Data.Json.JsonReader.Parse(str);
				//debug_log json["duration"].AsNumber();

				var scenePosition = (int)json["scenePosition"].AsNumber(); //integer
				var duration = (float)json["duration"].AsNumber();
				var camFrom = float3((float)json["canFrom"]["x"].AsNumber(), (float)json["canFrom"]["y"].AsNumber(), (float)json["canFrom"]["z"].AsNumber()); 
				var camTo = float3((float)json["camTo"]["x"].AsNumber(), (float)json["camTo"]["y"].AsNumber(), (float)json["camTo"]["z"].AsNumber());// + float3(-75f + 150f * rand.NextFloat(),-50f + 100f * rand.NextFloat(),-75f + 150f * rand.NextFloat()); 
				var lookatFrom = float3((float)json["lookatFrom"]["x"].AsNumber(), (float)json["lookatFrom"]["y"].AsNumber(), (float)json["lookatFrom"]["z"].AsNumber()); 
				var lookatTo = float3((float)json["lookatTo"]["x"].AsNumber(), (float)json["lookatTo"]["y"].AsNumber(), (float)json["lookatTo"]["z"].AsNumber()); 
				var fovFrom = (float)json["fovFrom"].AsNumber();
				var fovTo = (float)json["fovTo"].AsNumber();
				var startFadeFrom = (float)json["startFadeFrom"].AsNumber();
				var startFadeTo = (float)json["startFadeTo"].AsNumber();
				var endFadeFrom = (float)json["endFadeFrom"].AsNumber();
				var endFadeTo = (float)json["endFadeTo"].AsNumber();
				var fadeInDuration = (float)json["fadeInDuration"].AsNumber();
				var fadeOutDuration = (float)json["fadeOutDuration"].AsNumber();
				var bokehInNear = (float)json["bokehInNear"].AsNumber();
				var bokehOutNear = (float)json["bokehOutNear"].AsNumber();
				var bokehInFar = (float)json["bokehInFar"].AsNumber();
				var bokehOutFar = (float)json["bokehOutFar"].AsNumber();

				camsStill[scenePosition].Add(new SceneCameraAnimation(CameraFrustum, CameraTransform, scenePosition, duration, camFrom, camTo, lookatFrom, lookatTo, fovFrom, fovTo, startFadeFrom, startFadeTo, endFadeFrom, endFadeTo, fadeInDuration, fadeOutDuration, bokehInNear, bokehOutNear, bokehInFar, bokehOutFar));
			}

			for(var i = 0; i < camsStill.Count; i++)
			{
				debug_log "CAM "+i+" , count: "+camsStill[i].Count;
			}
			
		//}
	}


	public CustomRenderNode()
	{
		InitializeUX();

		//Update += Initialize;
		UpdateManager.AddAction(Initialize);
	}

	private Random 			rand = new Random(1);

	private RenderPipeline renderPipe = new RenderPipeline();
	private TexturePixelProvider 		TPProvider = new TexturePixelProvider();

	private VisualTriangulate vTriangulate;

	//private AudioPlayer _audio;

	private void Initialize()
	{
		UpdateManager.RemoveAction(Initialize);

		_drumReaderToms = new simppafi.DrumReader((import Uno.IO.BundleFile("Assets/toms-loud.txt")).ReadAllText(), 0);
		_drumReaderSnare = new simppafi.DrumReader((import Uno.IO.BundleFile("Assets/snare.txt")).ReadAllText(), 1);
		_drumReaderPiano = new simppafi.DrumReader((import Uno.IO.BundleFile("Assets/piano.txt")).ReadAllText(), 2);
		_drumReaderKick = new simppafi.DrumReader((import Uno.IO.BundleFile("Assets/kick.txt")).ReadAllText(), 3);
		_drumReaderTomsLow = new simppafi.DrumReader((import Uno.IO.BundleFile("Assets/toms-low.txt")).ReadAllText(), 4);

		//_audio = new AudioPlayer(120);
		//_audio.SetSong(import Uno.IO.BundleFile("song.mp3"));

		CurrentSceneCamera = new SceneCameraDirector(CameraFrustum, CameraTransform);
		CurrentSceneCamera.Setup(0);

		renderPipe.CameraFrustum = CameraFrustum;


		//simppafi.ParticleProvider.Init(16);//32);

		// SETUP EVERYTHING
		FramebufferStorage.RenderTransparency = false;
		FramebufferStorage.RenderLensGlow = true;
		FramebufferStorage.RenderSilhuette = false;
		FramebufferStorage.RenderLightSources = false;

		FramebufferStorage.RenderDeferred = true;
		FramebufferStorage.RenderWeight = true;
		FramebufferStorage.RenderSSR = true;//true;
		FramebufferStorage.RenderAlbedo = true;
		FramebufferStorage.RenderMRAO = true;
		FramebufferStorage.RenderSSSAO = true;//true;
		FramebufferStorage.RenderGlow = true;
		

		///* titanx
		FramebufferStorage.ResolutionSilhuette = 1f;
		FramebufferStorage.ResolutionTransparency = .1f;
		FramebufferStorage.ResolutionLightSources = .5f;

		simppafi.RenderPipeline.Resolution = 1f;
		FramebufferStorage.ResolutionDeferred = 1f;//.5f;
		FramebufferStorage.ResolutionDeferredFinal = 1f;//.5f;
		FramebufferStorage.ResolutionLensGlow = .25f;
		FramebufferStorage.ResolutionSSR = .5f;//.25f;
		FramebufferStorage.ResolutionAlbedo = 1f;
		FramebufferStorage.ResolutionMRAO = 1f;
		FramebufferStorage.ResolutionSSSAO = .5f;
		FramebufferStorage.ResolutionWeight = 1f;//.5f;
		FramebufferStorage.ResolutionGlow = .5f;
		//*/

		/* macbook
		FramebufferStorage.ResolutionSilhuette = .5f;
		FramebufferStorage.ResolutionTransparency = .1f;
		
		renderPipe.Resolution = .5f;
		FramebufferStorage.ResolutionLightSources = .5f;
		FramebufferStorage.ResolutionDeferred = .5f;
		FramebufferStorage.ResolutionDeferredFinal = .5f;
		FramebufferStorage.ResolutionLensGlow = .25f;
		FramebufferStorage.ResolutionSSR = .5f;//.25f;
		FramebufferStorage.ResolutionAlbedo = .5f;//.5f;
		FramebufferStorage.ResolutionMRAO = .5f;
		FramebufferStorage.ResolutionSSSAO = .25f;
		FramebufferStorage.ResolutionWeight = .5f;
		FramebufferStorage.ResolutionGlow = .5f;
		//*/


		//renderPipe.CurrentModifie = new simppafi.ModifieFXAA();
		renderPipe.CurrentModifie = new simppafi.ModifieDistort();
		

		//var fxTransparency = new simppafi.Effect.EffectTransparency();
		
		//var myFx = fxDeferred;

		var vLights = new VisualLightsFast();
		vLights.Effect = fxDeferred;
		renderPipe.AddLight(vLights);


		InitVisuals();
		
		SetScene1();
		
		getCameraData();

		_peakReader = new simppafi.PeakReader((import Uno.IO.BundleFile("Assets/peaks3.txt")).ReadAllText());

		// DEFERRED LIGHTING 
		var colA = simppafi.Color.ColorHexToRGB.HexToRGB(0xFFFFFF);//0xfff4b4);//0xdd9137);//0xFF0000);//0xdd9137);//0xaad6df);//fff6de);//0x788a8a);//0x788a8a);
		var colB = simppafi.Color.ColorHexToRGB.HexToRGB(0xFFFFFF);//0x5dcbff);//0x3bb3eb);//0x00FF00);//0x3bb3eb);//0xfff1de);//0xb89891);//0x788a8a);
		var colC = simppafi.Color.ColorHexToRGB.HexToRGB(0xFFFFFF);//0xb4ecff);//0x3b75eb);//0xe8c628);//0x0000FF);//0xe8c628);//0xd2bfdf);//0x11cce8);//0x788a8a);
		var colD = simppafi.Color.ColorHexToRGB.HexToRGB(0xFFFFFF);//0xFF3333);//0xffdd74);//0xebdd3b);//0x788a8a);//0x3b75eb);//0xd2aadf);//0xdef5ff);//0xe87b11);//0x788a8a);

		simppafi.RenderPipeline.Lights.Add(new simppafi.Object.ObjectLight(float3(1f, 40f, 50f), float3(0,0,0), colA, 	50f, 	1f)); //0
		simppafi.RenderPipeline.Lights.Add(new simppafi.Object.ObjectLight(float3(1f, 40f, -50f), float3(0,0,0), colB, 	50f, 	1f)); //1
		//simppafi.RenderPipeline.Lights.Add(new simppafi.Object.ObjectLight(float3(50f, 40f, 1f), float3(0,0,0), colC, 	20f, 	1f));
		//simppafi.RenderPipeline.Lights.Add(new simppafi.Object.ObjectLight(float3(-50f, 40f, 1f), float3(0,0,0), colD, 	20f, 	1f));

		simppafi.RenderPipeline.Lights.Add(new simppafi.Object.ObjectLight(float3(1f, 4000f, -50f), float3(0,0,0), colB, 	0f, 	1f)); //2
		simppafi.RenderPipeline.Lights.Add(new simppafi.Object.ObjectLight(float3(1f, 4000f, -50f), float3(0,0,0), colB, 	0f, 	1f)); //3
		simppafi.RenderPipeline.Lights.Add(new simppafi.Object.ObjectLight(float3(1f, 4000f, -50f), float3(0,0,0), colB, 	0f, 	1f)); //4
		
		//simppafi.RenderPipeline.Lights[0].Position = float3(-6f,10f,0);
		//simppafi.RenderPipeline.Lights[1].Position = float3(6f,10f,0);

		/*
		for(var i = 0; i < 64; i++)
		{
			simppafi.RenderPipeline.Lights.Add(new simppafi.Object.ObjectLight(float3(-50f, 40f, 1f), float3(0,0,0), simppafi.Color.ColorHexToRGB.HexToRGB(0x788a8a), 	30f, 	1f));
		}//*/

		/*
		for(var i = 0; i < 4; i++)
		{
			var envShadow = new EnvShadow(Lights[i]);

			envShadow.shadowAmbient = .15f;
			envShadow.lightDepth 	= 1000.0f;
			envShadow.shadowArea 	= float2(512f);//128f);
			envShadow.shadowC 		= 88f;//18f;
			envShadow.Resize(256);
			renderPipe.ShadowList.Add(envShadow);
			
			vLights.AddLight(simppafi.RenderPipeline.Lights[i], false);
		
			vLightPillars.AddLight(simppafi.RenderPipeline.Lights[i]);
		}
		*/

		/*
		// AMBIENT LIGHT
		for(var i = 0; i < 8; i++)
		{
			var rad = 200f * rand.NextFloat();
			var angle = rand.NextFloat() * 16f;

			var pos = float3(
					rad * Math.Sin(angle),
					10f + 50f * rand.NextFloat(),
					rad * Math.Cos(angle)
				);

			//pos = float3(Math.Clamp(pos.X, -240f, 240f), pos.Y, Math.Clamp(pos.Z, -240f, 205f));
			//float3(-250f + 500f * rand.NextFloat(), -10f + 170f * rand.NextFloat(), -250f + 500f * rand.NextFloat());

			vLights.AddLight(new simppafi.Object.ObjectLight(

				pos, 

				float3(0,0,0), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xd20085),// + float3(0, -.1f + .2f * rand.NextFloat(), -.1f + .2f * rand.NextFloat()), 
				100f, 
				1f));
		}
		//*/

		for(var i = 0; i < simppafi.RenderPipeline.Lights.Count; i++)
		{
			vLights.AddLight(simppafi.RenderPipeline.Lights[i], false);
			//vLightPillars.AddLight(Lights[i]);
		}

		/*
		vLights.AddLight(new simppafi.Object.ObjectLight(
				float3(0,100,0), 
				float3(0,0,0), 
				float3(1f),//simppafi.Color.ColorHexToRGB.HexToRGB(0xddcd9c), 
				200f, 
				1f));
	//*/

		LightPowerGoto = new float[simppafi.RenderPipeline.Lights.Count];

		vLights.ReBuild();
		vLights.RenderLightSources = false;
		//vLightPillars.ReBuild();


		//UpdateManager.AddAction(OnUpdate);

		// START SCENE
		//SetScene13();
		//float3 dep = float3(0.1f, .3f, .5f);
		//debug_log Uno.Vector.Normalize(dep);

		waitStart = (float)Fuse.Time.FrameTime;
		UpdateManager.AddAction(wait);
	}

	private float waitStart = 0f;
	private void wait()
	{
		if( ((float)Fuse.Time.FrameTime-waitStart) > 0.5f)
		{
			UpdateManager.RemoveAction(wait);
			UpdateManager.AddAction(SetupVisuals);
		}
	}

	private bool AllVisualsSetup = false;
	private int currentSetupVisual = 0;
	private int currentSetupScene = 0;
	private void SetupVisuals()
	{
		debug_log "SetupVisuals";
		if(!TPProvider.IsSetup)
		{
			return;
		}
		debug_log currentSetupVisual+" < "+visuals.Length;

		if(currentSetupVisual < visuals.Length)
		{
			if(!visuals[currentSetupVisual].isSetup)
			{
				debug_log "setup "+currentSetupVisual;
				visuals[currentSetupVisual].Setup();
				currentSetupVisual++;
				return;
			}
		}

		if(currentSetupScene < 13)
		{
			if(currentSetupScene == 0) {
				SetScene1();
				currentSetupScene = 1;
			}else if(currentSetupScene == 1) {
				SetScene2();
				currentSetupScene = 2;
			}else if(currentSetupScene == 2) {
				SetScene3();
				currentSetupScene = 3;
			}else if(currentSetupScene == 3) {
				SetScene4();
				currentSetupScene = 4;
			}else if(currentSetupScene == 4) {
				SetScene5();
				currentSetupScene = 5;
			}else if(currentSetupScene == 5) {
				SetScene6();
				currentSetupScene = 6;
			}else if(currentSetupScene == 6) {
				SetScene7();
				currentSetupScene = 7;
			}else if(currentSetupScene == 7) {
				SetScene8();
				currentSetupScene = 8;
			}else if(currentSetupScene == 8) {
				SetScene9();
				currentSetupScene = 9;
			}else if(currentSetupScene == 9) {
				SetScene10();
				currentSetupScene = 10;
			}else if(currentSetupScene == 10) {
				SetScene11();
				currentSetupScene = 11;
			}else if(currentSetupScene == 11) {
				SetScene12();
				currentSetupScene = 12;
			}else if(currentSetupScene == 12) {
				SetScene13();
				currentSetupScene = 13;
			}

			renderPipe.RenderDeferred(_dc);
			renderPipe.RenderLights(_dc);

			return;
		}
		
		debug_log "SETUP IS READY";
		SetScene13();
		CanDraw = true;
		UpdateManager.RemoveAction(SetupVisuals);
		UpdateManager.AddAction(OnUpdate);
		if(ON_SETUP != null)
			ON_SETUP();
		
	}


	private float3[] _LightColor = new [] {
				simppafi.Color.ColorHexToRGB.HexToRGB(0xfa3e13), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xf94913), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xf85413), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xf73313), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0xfa4413)
			};

	private float3[]  _LightColor2 = new [] {
				simppafi.Color.ColorHexToRGB.HexToRGB(0x128ff8), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x12aef6), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x1283f7), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x129bf2), 
				simppafi.Color.ColorHexToRGB.HexToRGB(0x12b4f7)
			};
	private float ColorTransformation = 0f;
	public static float3 FogColor = simppafi.Color.ColorHexToRGB.HexToRGB(0x128ff8);
	private void OnUpdate()
	{
		//simppafi.LightControl.OnUpdate();

		renderPipe.OnUpdate();

		//var _color = _LightColor;//(rand.NextFloat() > .5f) ? _LightColor : _LightColor2;
		//var _color = _LightColor
		//debug_log ColorTransformation;

		FogColor = _LightColor2[0] + (_LightColor[0] - _LightColor2[0]) * Math.Min(1f, ColorTransformation * 1.25f);
		for(var i = 0; i < 5; i++)
		{
			//simppafi.RenderPipeline.Lights[i].Power = 3f;//Math.Max(simppafi.RenderPipeline.Lights[i].Power*1.25f, .25f);
		//	simppafi.RenderPipeline.Lights[i].Scale = 50f;
			simppafi.RenderPipeline.Lights[i].Color = _LightColor2[i] + (_LightColor[i] - _LightColor2[i]) * ColorTransformation;
		}
	}

	private float starttime = 0f;

	private float[] LightPowerGoto;// = new [] {0f,0f,0f,0f};

	private Fuse.DrawContext _dc;
	protected override void OnDraw(Fuse.DrawContext dc)
	{
		_dc = dc;
		//debug_log "dc.Viewport.PixelsPerPoint : "+dc.Viewport.PixelsPerPoint;
		//debug_log "dc.GLViewportPointSize : "+dc.GLViewportPointSize;
		//debug_log "dc.GLViewportPixelSize : "+dc.GLViewportPixelSize;
		//debug_log "dc.ViewportPixelsPerPoint : "+dc.ViewportPixelsPerPoint;
				/*
		with video
		dc.Viewport.PixelsPerPoint : 1
		dc.GLViewportPointSize : 375, 667
		dc.GLViewportPixelSize : 375, 667
		dc.ViewportPixelsPerPoint : 1
		RootViewport.PixelsPerPoint : 1
		*/

		/*
		without video
		RootViewport.PixelsPerPoint : 1
		dc.Viewport.PixelsPerPoint : 1
		dc.GLViewportPointSize : 375, 667
		dc.GLViewportPixelSize : 375, 667
		dc.ViewportPixelsPerPoint : 1
		*/

		//debug_log dc.RenderTarget.Size +" "+simppafi.RenderPipeline.Resolution;
		if(dc.RenderTarget.Size.X > 1920) //2880
		{
			simppafi.RenderPipeline.Resolution = 1920f / dc.RenderTarget.Size.X;
			//debug_log "scale down to: "+dc.RenderTarget.Size +" "+simppafi.RenderPipeline.Resolution;
		}

		if(!TPProvider.IsSetup)
		{
			TPProvider.Setup(dc);
			return;
		}

		if(!CanDraw)
		{
			return;
		}

		if(!renderPipe.AllIsSetup)
		{
			debug_log "INITIALIZE renderPipe";
			return;
		}

		if(vTriangulate != null)
		{
			if(vTriangulate.OrgImage == null)
			{
				vTriangulate.OrgImage = OrgImage.CaptureRegion(dc, new Uno.Rect(0,0,1024,1024), float2(0,0));
				vTriangulate.HeightImage = HeightImage.CaptureRegion(dc, new Uno.Rect(0,0,1024,1024), float2(0,0));
				return;
			}
		}

		if(starttime == 0f)
		{
			starttime = (float)Fuse.Time.FrameTime;
		}

		/*
		// CAMERA
		var _camAngle = (float)Fuse.Time.FrameTime * .1f + CamAngle;

		CameraFrustum.FovRadians = Math.PIf/3f;
		CameraTransform.Position = float3(CamRadius * Math.Sin(_camAngle), CamMoveY, CamRadius * Math.Cos(_camAngle));
		CameraTransform.LookAt(float3(0,0,0), float3(0,1,0));
		*/



		var time = Math.Max(0f, (float)Fuse.Time.FrameTime-starttime);
		var ftime = time+Math.Sin(time*.05f)*2f;
		var gtime = time+Math.Sin(time*.035f);
		CurrentSceneCamera.Update(time, ftime, gtime);

		
		// LIGHT ANIMATION
		int i;
		var l = simppafi.RenderPipeline.Lights.Count;

		var timeInterval = (float)Fuse.Time.FrameInterval;
		var div = 0f;
		/*
		for(i = 0; i < l; i++)
		{
			div = (float)i/(float)l;

			var angle = div * Math.PIf * 2f + Math.Sin(time*.1f) * 10f;
			var rad = 30f * Math.Sin(time*.2f+i);
			var pos = float3(
								Math.Sin(angle) * rad,
								//Lights[i].Position.Y,
								20f + 15f * Math.Sin(angle*.8f+div),
								Math.Cos(angle) * rad
								);

			simppafi.RenderPipeline.Lights[i].Position = pos;
*/
			/*if(rand.NextFloat() > .99f)
			{
				LightPowerGoto[i] = (LightPowerGoto[i] == 0f) ? 3f : 0f; //*rand.NextFloat()
			}

			//LightPowerGoto[i] = 2f;

			simppafi.RenderPipeline.Lights[i].Power = simppafi.RenderPipeline.Lights[i].Power + (LightPowerGoto[i] - simppafi.RenderPipeline.Lights[i].Power) * .1f;
			*/
/*			
		}
*/
		//if(rand.NextFloat() > .9f)
		//{
		//	RenderPipeline.Glitch = !RenderPipeline.Glitch;
		//}

		//simppafi.RenderPipeline.Lights[0].Power = 1f;
		//simppafi.RenderPipeline.Lights[1].Power = 1f;
		//simppafi.RenderPipeline.Lights[2].Power = 1f;
		//simppafi.RenderPipeline.Lights[3].Power = 1f;

		/*
		simppafi.RenderPipeline.Lights[0].Power = 1f;
		simppafi.RenderPipeline.Lights[1].Power = 1f;
		simppafi.RenderPipeline.Lights[2].Power = 3f;
		simppafi.RenderPipeline.Lights[3].Power = 0f;

		simppafi.RenderPipeline.Lights[1].Position = float3(20f,10f,35f);

		simppafi.RenderPipeline.Lights[2].Position = float3(-20f,10f,-150f);
*/

		// RENDER
		//simppafi.RenderPipeline.RenderMode = CurrentScene.RenderMode;

		//if(CurrentScene.RenderMode == simppafi.RenderPipeline.RenderingMode.DEFERRED)
		//{
			renderPipe.RenderDeferred(dc);
			renderPipe.RenderLights(dc);
		//}
		//else if(CurrentScene.RenderMode == simppafi.RenderPipeline.RenderingMode.FORWARD)
		//{
			//renderPipe.RenderPost(dc);
			//renderPipe.RenderFinal(dc);
		//}


		if(DRAW_FRAME != null)
			DRAW_FRAME();

		/*
		if(!_audio.IsPlaying)
		{
			_audio.Resume();
		}

		if(_audio.HasSound)
		{
			//debug_log _audio.IsPlaying+" "+_audio.Position;
		}else{
			_audio.Resume();
			debug_log "start sound";
		}*/

		/*
		var myevent = new Fuse.Triggers.Actions.RaiseUserEvent();
			myevent.EventName = "EventStartDemo";
			myevent.PerformFromNode(this);
		*/


		/*
		draw Fuse.Drawing.Primitives.Quad
		{
			DepthTestEnabled: false;
			CullFace: Uno.Graphics.PolygonFace.None;
			float2 uv :	ClipPosition.XY * 0.5f + 0.5f;

			//PixelColor : sample(simppafi.FramebufferStorage.GlobalLightSourcesBuffer.ColorBuffer, uv);

			//PixelColor : sample(simppafi.FramebufferStorage.GlobalShadowBuffer.ColorBuffer, uv);
			
			PixelColor : sample(renderPipe.ShadowList[0].shadowMap.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearClamp);

			//PixelColor : sample(simppafi.FramebufferStorage.GlobalShadowMapAtlasBuffer.ColorBuffer, uv);

			//PixelColor : sample(simppafi.FramebufferStorage.GlobalNormalBuffer.ColorBuffer, uv);

			//apply simppafi.RenderLibrary.FXDeferred;
			//float _depth :	simppafi.Utils.BufferPacker.UnpackFloat16(FXDeferred.ZW);
			//PixelColor : float4(_depth,_depth,_depth,1f);

			//apply simppafi.RenderLibrary.FXDeferred;
			//float3 _normal : simppafi.Utils.BufferPacker.UnpackNormal(FXDeferred.XY);

			//PixelColor : float4(_normal.XYZ,1f);

			//PixelColor : sample(simppafi.FramebufferStorage.GlobalSSAOBuffer.ColorBuffer, uv);

			//PixelColor : sample(simppafi.FramebufferStorage.GlobalShadowBuffer.ColorBuffer, uv);
		};
		//*/
	}

	private BaseVisual[] visuals = new [] {
		
		new VisualRoomStatic2() as BaseVisual,
		new VisualRoomStaticTunnel() as BaseVisual,

		new VisualBodyGrill2LO() as BaseVisual,
		new VisualBodyGrill2Obj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();

		new VisualBodyGrill1LO() as BaseVisual,
		new VisualBodyGrill1Obj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();
		
		new VisualHandsUpLO() as BaseVisual,
		new VisualHandsUpObj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();
		
		new VisualCircleLO() as BaseVisual,
		new VisualCircleObj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();
		
		new VisualBrokenSphereLO() as BaseVisual,
		new VisualBrokenSphereObj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();
		
		new VisualDoorsLO() as BaseVisual,
		new VisualDoorsObj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();
		
		new VisualBoxesLO() as BaseVisual,
		new VisualBoxesObj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();
		
		new VisualPeepsLO() as BaseVisual,
		new VisualPeepsObj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();
		
		new VisualHandsLO() as BaseVisual,
		new VisualHandsObj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStatic2();
		
		new VisualHeadLO() as BaseVisual,
		new VisualHeadObj() as BaseVisual,
		//var vRoom2 = new VisualRoomStatic2();
		
		new VisualBallsLO() as BaseVisual,
		new VisualBallsObj() as BaseVisual,
		//var vRoomTunnel = new VisualRoomStaticTunnel();
		
		new VisualRoadLO() as BaseVisual,
		new VisualRoadObj() as BaseVisual,
		//var vRoom2 = new VisualRoomStatic2();
		
		new VisualSplitLO() as BaseVisual,
		new VisualSplitObj() as BaseVisual,
		//var vRoom2 = new VisualRoomStatic2();
		
		//new VisualParticleLO() as BaseVisual
		/* NOT GOOD
		var vAngelObj = new VisualAngelObj();
		var vAngelLO = new VisualAngelLO();
		var vRoomTunnel = new VisualRoomStatic2();
		*/
		
	};

	private void InitVisuals()
	{
		for(var i = 0; i < visuals.Length; i++)
		{
			visuals[i].Effect = fxDeferred;
		}
	}


	private BaseVisual prevLo;
	private BaseVisual prevObj;
	private BaseVisual prevBg;
	//private bool particlesAdded = false;

	private void delPrev()
	{
		if(prevLo != null){renderPipe.RemoveGlowChild(prevLo);}
		if(prevObj != null){renderPipe.RemoveChild(prevObj);}
		if(prevBg != null){renderPipe.RemoveChild(prevBg);}

		/*if(!particlesAdded)
		{
			renderPipe.AddGlowChild(visuals[28]); 		//new VisualBodyGrill2LO();
			particlesAdded = true;
		}*/
	}
	private void SetScene1()
	{
		debug_log "SetScene1";
		debug_log "VisualBodyGrill2LO VisualBodyGrill2Obj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 0;
		renderPipe.AddGlowChild(prevLo = visuals[2]); 		//new VisualBodyGrill2LO();
		renderPipe.AddChild(prevObj = visuals[3]); 			//new VisualBodyGrill2Obj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene2()
	{
		debug_log "SetScene2";
		debug_log "VisualBodyGrill1LO VisualBodyGrill1Obj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 1;
		renderPipe.AddGlowChild(prevLo = visuals[4]); 		//new VisualBodyGrill1LO();
		renderPipe.AddChild(prevObj = visuals[5]); 			//new VisualBodyGrill1Obj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene3()
	{
		debug_log "SetScene3";
		debug_log "VisualHandsUpLO VisualHandsUpObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 2;
		renderPipe.AddGlowChild(prevLo = visuals[6]); 		//new VisualHandsUpLO();
		renderPipe.AddChild(prevObj = visuals[7]); 			//new VisualHandsUpObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene4()
	{
		debug_log "SetScene4";
		debug_log "VisualCircleLO VisualCircleObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 3;
		renderPipe.AddGlowChild(prevLo = visuals[8]); 		//new VisualCircleLO();
		renderPipe.AddChild(prevObj = visuals[9]); 			//new VisualCircleObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene5()
	{
		debug_log "SetScene5";
		debug_log "VisualBrokenSphereLO VisualBrokenSphereObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 4;
		renderPipe.AddGlowChild(prevLo = visuals[10]); 		//new VisualBrokenSphereLO();
		renderPipe.AddChild(prevObj = visuals[11]); 		//new VisualBrokenSphereObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene6()
	{
		debug_log "SetScene6";
		debug_log "VisualDoorsLO VisualDoorsObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 5;
		renderPipe.AddGlowChild(prevLo = visuals[12]); 		//new VisualDoorsLO();
		renderPipe.AddChild(prevObj = visuals[13]); 		//new VisualDoorsObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene7()
	{
		debug_log "SetScene7";
		debug_log "VisualBoxesLO VisualBoxesObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 6;
		renderPipe.AddGlowChild(prevLo = visuals[14]); 		//new VisualBoxesLO();
		renderPipe.AddChild(prevObj = visuals[15]); 		//new VisualBoxesObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene8()
	{
		debug_log "SetScene8";
		debug_log "VisualPeepsLO VisualPeepsObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 7;
		renderPipe.AddGlowChild(prevLo = visuals[16]); 		//new VisualPeepsLO();
		renderPipe.AddChild(prevObj = visuals[17]); 		//new VisualPeepsObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene9()	
	{
		debug_log "SetScene9";
		debug_log "VisualHandsLO VisualHandsObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 8;
		renderPipe.AddGlowChild(prevLo = visuals[18]); 		//new VisualHandsLO();
		renderPipe.AddChild(prevObj = visuals[19]); 		//new VisualHandsObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene10()	
	{
		debug_log "SetScene10";
		debug_log "VisualHeadLO VisualHeadObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 9;
		renderPipe.AddGlowChild(prevLo = visuals[20]); 		//new VisualHeadLO();
		renderPipe.AddChild(prevObj = visuals[21]); 		//new VisualHeadObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene11()	
	{
		debug_log "SetScene11";
		debug_log "VisualBallsLO VisualBallsObj VisualRoomStaticTunnel";
		delPrev();
		CurrentSceneCamera.scenePosition = 10;
		renderPipe.AddGlowChild(prevLo = visuals[22]); 		//new VisualBallsLO();
		renderPipe.AddChild(prevObj = visuals[23]); 		//new VisualBallsObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStaticTunnel();
	}
	private void SetScene12()
	{
		debug_log "SetScene12";
		debug_log "VisualRoadLO VisualRoadObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 11;
		renderPipe.AddGlowChild(prevLo = visuals[24]); 		//new VisualRoadLO();
		renderPipe.AddChild(prevObj = visuals[25]); 		//new VisualRoadObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	private void SetScene13()
	{
		debug_log "SetScene13";
		debug_log "VisualSplitLO VisualSplitObj VisualRoomStatic2";
		delPrev();
		CurrentSceneCamera.scenePosition = 12;
		renderPipe.AddGlowChild(prevLo = visuals[26]); 		//new VisualSplitLO();
		renderPipe.AddChild(prevObj = visuals[27]); 		//new VisualSplitObj();
		renderPipe.AddChild(prevBg = visuals[0]);			//new VisualRoomStatic2();
	}
	
	private bool demoMode = true;
	public void DemoModeOff()
	{
		demoMode = false;
	}

	public void DemoModeOn()
	{
		demoMode = true;
	}

	public static float peakPower = 0f;
	public string CurrentDataPosition = "";
	private int camId = 0;
	private float cameraAngleChangeTime = 0f;
	private float cameraAngleChangeInterval = 2f;
	private int prevCamId = -1;
	private int prevScenePosition = -1;
	public void ControlDemo(double Position, double Duration)
	{
		if(!CanDraw)
		{
			return;
		}
		var _pos = Position * 1000.0;
		var drumDataToms = _drumReaderToms.GetDrum(_pos);
		var drumDataSnare = _drumReaderSnare.GetDrum(_pos);
		var drumDataKick = _drumReaderKick.GetDrum(_pos);
		var drumDataPiano = _drumReaderPiano.GetDrum(_pos);
		var drumDataTomsLow = _drumReaderTomsLow.GetDrum(_pos);

		var gotHit = false;
		ColorTransformation = (float)(Position/Duration);

		//debug_log Position;
		/*
		1 0:00.000 (kaksi tolppaa) setScene13
		2 0:10.672 (pikkutolpat) setScene12
		3 0:21.408 (ihmis ryhmä)  setScene8
		4 0:32.882 (pää räjähdys) setScene5
		5 0:44.709 (huoneet) setScene7
		6 1:10.476 (short kaksi tolppaa) setScene13
		7 1:16.368 (ihmispalaset) setScene6
		8 1:39.952 (android pää) setScene10
		9 1:48.613 (android pää) setScene10
		9 2:09.353 (makaava androidi) setScene11
		10 2:28.172 (mies grilli 1) setScene1
		11 2:40.344 (mies grilli 2) setScene2
		12 2:46.725 (pyörivä nyrkki) setScene4
		12 2:59.647 (kädet ja pallo) setScene3
		13 3:16.158 (kaksi tolppaa)  setScene13
		*/
		if(demoMode)
		{
			//1 0:00.000 (kaksi tolppaa) setScene13
			if(Position < 10.672 && CurrentSceneCamera.scenePosition != 12)
			{
				debug_log Position;
				SetScene13();
			}
			//2 0:10.672 (pikkutolpat) setScene12
			if(Position > 10.672 && Position < 21.408 && CurrentSceneCamera.scenePosition != 11)
			{
				debug_log Position;
				SetScene12();
			}
			//3 0:21.408 (ihmis ryhmä)  setScene8
			if(Position > 21.408 && Position < 32.882 && CurrentSceneCamera.scenePosition != 7)
			{
				debug_log Position;
				SetScene8();
			}
			//4 0:32.882 (pää räjähdys) setScene5
			if(Position > 32.882 && Position < 44.709 && CurrentSceneCamera.scenePosition != 6)
			{

				debug_log Position;
				SetScene7();
			}
			//5 0:44.709 (huoneet) setScene7
			if(Position > 44.709 && Position < 70.476 && CurrentSceneCamera.scenePosition != 4)
			{
				debug_log Position;
				SetScene5();
			}
			//6 1:10.476 (short kaksi tolppaa) setScene13
			if(Position > 70.476 && Position < 76.668 && CurrentSceneCamera.scenePosition != 12)
			{
				debug_log Position;
				SetScene13();
			}
			//7 1:16.368 (ihmispalaset) setScene6 //76.368
			if(Position > 76.668 && Position < 96.952 && CurrentSceneCamera.scenePosition != 5)
			{
				debug_log Position;
				SetScene6();
			}
			//8 1:36.952 (android pää) setScene10 //1:48.583
			if(Position > 96.952 && Position < 108.613 && CurrentSceneCamera.scenePosition != 9)
			{
				debug_log Position;
				SetScene9(); 
			}
			//9 1:48.613 (android pää) setScene10
			if(Position > 108.613 && Position < 126.353 && CurrentSceneCamera.scenePosition != 9)
			{
				debug_log Position;
				SetScene10();
			}
			//9 2:09.353 (makaava androidi) setScene11
			if(Position > 126.353 && Position < 152.172 && CurrentSceneCamera.scenePosition != 10)
			{
				debug_log Position;
				SetScene11();
			}
			//10 2:28.172 (mies grilli 1) setScene1
			if(Position > 152.172 && Position < 160.344 && CurrentSceneCamera.scenePosition != 0)
			{
				debug_log Position;
				SetScene1();
			}
			//11 2:40.344 (mies grilli 2) setScene2
			if(Position > 160.344 && Position < 166.725 && CurrentSceneCamera.scenePosition != 3)
			{
				debug_log Position;
				SetScene4();
			}
			//12 2:46.725 (pyörivä nyrkki) setScene4
			if(Position > 166.725 && Position < 176.647 && CurrentSceneCamera.scenePosition != 1)
			{
				debug_log Position;
				SetScene2();
			}
			//12 2:59.647 (kädet ja pallo) setScene3 
			if(Position > 176.647 && Position < 203.100 && CurrentSceneCamera.scenePosition != 2)
			{
				debug_log Position;
				SetScene3();
			}
			//13 3:16.158 (kaksi tolppaa)  setScene13
			if(Position > 203.100 && CurrentSceneCamera.scenePosition != 12)
			{
				debug_log Position;
				SetScene13();
			}
		}



		if(drumDataToms != null)
		{
			gotHit = true;
			//debug_log "tom";
			renderPipe.Hit(0f);
			CurrentDataPosition = "tom "+_pos;
		}
		if(drumDataSnare != null)
		{
			gotHit = true;
			//debug_log drumDataSnare.pos;

			//debug_log "snare";
			renderPipe.Hit(1f);
			CurrentDataPosition = "snare "+_pos;
		}
		if(drumDataKick != null)
		{
			gotHit = true;

			//debug_log "kick";
			renderPipe.Hit(2f);
			CurrentDataPosition = "kick "+_pos;
		}
		if(drumDataPiano != null)
		{
			gotHit = true;
			//debug_log drumDataPiano.pos;
			//debug_log "piano";
			renderPipe.Hit(3f);

			//renderPipe.Hit(0f);
			//renderPipe.Hit(0f);
			//renderPipe.Hit(0f);
			//renderPipe.Hit(0f);
			//renderPipe.Hit(1f);
			//renderPipe.Hit(2f);
			//renderPipe.Hit(4f);
			//renderPipe.Hit(4f);
			//renderPipe.Hit(4f);
			//renderPipe.Hit(4f);
			CurrentDataPosition = "piano "+_pos;
		}
		if(drumDataTomsLow != null)
		{
			gotHit = true;
			renderPipe.Hit(4f);
			CurrentDataPosition = "tom2 "+_pos;
		}

		var peakData = _peakReader.GetPeak(_pos);
		if(peakData != null)
		{
			if(peakPower < .4f)
			{
				peakPower += peakData.power*peakData.power*.5f;
			}
			//debug_log "peak hit "+peakData.power;
		}
		var ease = (float)Fuse.Time.FrameInterval * 7f;//2f;
		//debug_log ease;
		if(ease > 0.9f)
		{
			ease = 0.9f;
		}

		peakPower = peakPower + (0f - peakPower) * ease;
		if(peakPower > 0f)
		{
			//debug_log peakPower;
			renderPipe.Peak(peakPower);
		}

		// CAMERA ANGLES
		///*
		if(gotHit && ((float)Fuse.Time.FrameTime - cameraAngleChangeTime) > cameraAngleChangeInterval)
		{
			camId = (int)(camsStill[CurrentSceneCamera.scenePosition].Count * rand.NextFloat());
			if(camId > camsStill[CurrentSceneCamera.scenePosition].Count-1)
			{
				camId = camsStill[CurrentSceneCamera.scenePosition].Count-1;
			}
			if(camId != prevCamId || CurrentSceneCamera.scenePosition != prevScenePosition)
			{
				prevCamId = camId;
				prevScenePosition = CurrentSceneCamera.scenePosition;
				CurrentSceneCamera = camsStill[CurrentSceneCamera.scenePosition][camId]; 
				CurrentSceneCamera.SetEndFades(0f,0f,1f,15f); //10f
				CurrentSceneCamera.Setup(Math.Max(0f, (float)Fuse.Time.FrameTime - starttime));

				cameraAngleChangeTime = (float)Fuse.Time.FrameTime;
			}
		}
		//*/
	}

	public void ResetDrumPos()
	{
		_drumReaderToms.Reset();
		_drumReaderSnare.Reset();
		_drumReaderKick.Reset();
		_drumReaderPiano.Reset();
		_drumReaderTomsLow.Reset();
	}



	// POINTER CONTROLS FOR DEBUG AND DESIGN
	public void PointerPressed(object sender, Fuse.Input.PointerPressedArgs args)
	{
		if(CurrentSceneCamera != null)
		{
			CurrentSceneCamera.PointerPressed(sender, args);
		}
	}
	public void PointerReleased(object sender, Fuse.Input.PointerReleasedArgs args)
	{
		if(CurrentSceneCamera != null)
		{
			CurrentSceneCamera.PointerReleased(sender, args);
		}
	}
	public void PointerMoved(object sender, Fuse.Input.PointerMovedArgs args)
	{
		if(CurrentSceneCamera != null)
		{
			CurrentSceneCamera.PointerMoved(sender, args);
		}
	}
	public void PointerWheelMoved(object sender, Fuse.Input.PointerWheelMovedArgs args)
	{
		if(CurrentSceneCamera != null)
		{
			CurrentSceneCamera.PointerWheelMoved(sender, args);
		}
	}
	public void KeyPressed(object sender, Fuse.Input.KeyPressedArgs args)
	{
		if(CurrentSceneCamera != null)
		{
			CurrentSceneCamera.KeyPressed(sender, args);
		}
	}
	public void KeyReleased(object sender, Fuse.Input.KeyReleasedArgs args)
	{
		if(CurrentSceneCamera != null)
		{
			CurrentSceneCamera.KeyReleased(sender, args);
		}

		if(args.Key == Uno.Platform.Key.D1) {
			SetScene1();
		}else if(args.Key == Uno.Platform.Key.D2) {
			SetScene2();
		}else if(args.Key == Uno.Platform.Key.D3) {
			SetScene3();
		}else if(args.Key == Uno.Platform.Key.D4) {
			SetScene4();
		}else if(args.Key == Uno.Platform.Key.D5) {
			SetScene5();
		}else if(args.Key == Uno.Platform.Key.D6) {
			SetScene6();
		}else if(args.Key == Uno.Platform.Key.D7) {
			SetScene7();
		}else if(args.Key == Uno.Platform.Key.D8) {
			SetScene8();
		}else if(args.Key == Uno.Platform.Key.D9) {
			SetScene9();
		}else if(args.Key == Uno.Platform.Key.D0) {
			SetScene10();
		}else if(args.Key == Uno.Platform.Key.NumPad1) {
			SetScene11();
		}else if(args.Key == Uno.Platform.Key.NumPad2) {
			SetScene12();
		}else if(args.Key == Uno.Platform.Key.NumPad3) {
			SetScene13();
		}

	}



	/*
	private float CamMoveY = 0f;
	private float CamAngle = 0f;
	private float CamRadius = 100f;
	private bool PointerIsDown = false;
	private float2 PointerDelta = float2(0);
	private float2 PointerPrevPoint = float2(0);

	public void PointerPressed(object sender, Fuse.Input.PointerPressedArgs args)
	{
		PointerPrevPoint = args.WindowPoint;
		PointerIsDown = true;

		
	}
	public void PointerReleased(object sender, Fuse.Input.PointerReleasedArgs args)
	{
		PointerIsDown = false;
		
		// TO CLICK ON 3D OBJECT
		//var CursorRay = Viewport.PointToWorldRay(args.WindowPoint);
		//var dist = Uno.Geometry.Distance.RayPoint(CursorRay, float3(0,150,0));
		//if(dist < 75)
		//{
		//	
		//}

	}
	public void PointerMoved(object sender, Fuse.Input.PointerMovedArgs args)
	{
		if(PointerIsDown)
		{
			PointerDelta = (args.WindowPoint - PointerPrevPoint);
			PointerPrevPoint = args.WindowPoint;
			
			CamAngle -= PointerDelta.X * .005f;
			CamMoveY += PointerDelta.Y;

		}
	}
	public void PointerWheelMoved(object sender, Fuse.Input.PointerWheelMovedArgs args)
	{
		CamRadius += args.WheelDelta.Y;
	}
	*/

	/*
	public int2 GetSize(float resolution, DrawContext dc)
	{
		return int2((int)( Uno.Math.Max(2, dc.RenderTarget.Size.X * resolution)), (int)( Uno.Math.Max(2, dc.RenderTarget.Size.Y * resolution)));
	}
	*/


	

}

